#!/bin/bash
set -e

# ========================================
# Setup SBT Installation Script
# ========================================
# This script downloads and installs SBT
# Supports downloading from GitHub or custom URL
# ========================================

echo "=== SBT Installation Setup ==="

# Get parameters from environment
SBT_VERSION="${SBT_VERSION:-1.10.4}"
DOWNLOAD_FROM="${DOWNLOAD_FROM:-github}"
CUSTOM_URL="${CUSTOM_URL:-}"
WORKING_DIR="${WORKING_DIR:-.}"

echo "SBT Version: $SBT_VERSION"
echo "Download from: $DOWNLOAD_FROM"
echo "Working directory: $WORKING_DIR"
echo ""

# Navigate to working directory
cd "$WORKING_DIR"

# Define installation directory
INSTALL_DIR="sbt-install/${SBT_VERSION}"
SBT_DIR="${INSTALL_DIR}/sbt"

# Check if SBT is already installed (from cache)
if [ -d "$SBT_DIR" ] && [ -f "$SBT_DIR/bin/sbt" ]; then
  echo "✓ SBT $SBT_VERSION already installed (from cache)"
  echo "Installation directory: $(pwd)/$INSTALL_DIR"
  
  # Verify it works
  if "$SBT_DIR/bin/sbt" --version &> /dev/null; then
    echo "✓ SBT installation verified"
    exit 0
  else
    echo "⚠ Cached SBT installation appears corrupted, reinstalling..."
    rm -rf "$INSTALL_DIR"
  fi
fi

# Create installation directory
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Download SBT
echo ""
echo "=== Downloading SBT ==="

ZIP_FILE="sbt-${SBT_VERSION}.zip"

if [ "$DOWNLOAD_FROM" = "custom-url" ]; then
  # Download from custom URL
  if [ -z "$CUSTOM_URL" ]; then
    echo "ERROR: custom-url specified but CUSTOM_URL is empty"
    exit 1
  fi
  
  echo "Downloading from custom URL: $CUSTOM_URL"
  
  if ! curl -L -f -o "$ZIP_FILE" "$CUSTOM_URL"; then
    echo "ERROR: Failed to download SBT from custom URL"
    exit 1
  fi
  
elif [ "$DOWNLOAD_FROM" = "github" ]; then
  # Download from GitHub releases
  GITHUB_URL="https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.zip"
  
  echo "Downloading from GitHub: $GITHUB_URL"
  
  if ! curl -L -f -o "$ZIP_FILE" "$GITHUB_URL"; then
    echo "ERROR: Failed to download SBT from GitHub"
    echo "URL: $GITHUB_URL"
    exit 1
  fi
  
else
  echo "ERROR: Unknown download source: $DOWNLOAD_FROM"
  echo "Supported values: 'github', 'custom-url'"
  exit 1
fi

echo "✓ SBT downloaded successfully"

# Verify download
if [ ! -f "$ZIP_FILE" ]; then
  echo "ERROR: Downloaded file not found: $ZIP_FILE"
  exit 1
fi

FILE_SIZE=$(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null)
echo "Downloaded file size: $FILE_SIZE bytes"

if [ "$FILE_SIZE" -lt 1000000 ]; then
  echo "ERROR: Downloaded file seems too small (less than 1MB)"
  echo "The download may have failed"
  exit 1
fi

# Extract SBT
echo ""
echo "=== Extracting SBT ==="
echo "Extracting to: $(pwd)/$INSTALL_DIR"

if ! unzip -q "$ZIP_FILE" -d "$INSTALL_DIR"; then
  echo "ERROR: Failed to extract SBT archive"
  exit 1
fi

echo "✓ SBT extracted successfully"

# Verify extraction
if [ ! -d "$SBT_DIR" ]; then
  echo "ERROR: SBT directory not found after extraction: $SBT_DIR"
  echo "Contents of $INSTALL_DIR:"
  ls -la "$INSTALL_DIR"
  exit 1
fi

if [ ! -f "$SBT_DIR/bin/sbt" ]; then
  echo "ERROR: SBT executable not found: $SBT_DIR/bin/sbt"
  echo "Contents of $SBT_DIR:"
  ls -la "$SBT_DIR"
  exit 1
fi

# Make sbt executable
chmod +x "$SBT_DIR/bin/sbt"

# Cleanup
echo ""
echo "=== Cleanup ==="
rm -f "$ZIP_FILE"
echo "✓ Temporary files cleaned up"

# Final verification
echo ""
echo "=== Verification ==="
echo "SBT installation directory: $(pwd)/$INSTALL_DIR"
echo "SBT executable: $(pwd)/$SBT_DIR/bin/sbt"

if [ -x "$SBT_DIR/bin/sbt" ]; then
  echo "✓ SBT executable is ready"
else
  echo "ERROR: SBT executable is not executable"
  exit 1
fi

echo ""
echo "✓✓✓ SBT $SBT_VERSION installed successfully ✓✓✓"
