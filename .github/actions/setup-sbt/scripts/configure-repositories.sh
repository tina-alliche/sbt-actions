#!/bin/bash
set -e

# ========================================
# Configure SBT Repositories Script
# ========================================
# This script configures SBT repositories
# Supports:
# - Custom file (repositories-file input)
# - Inline content (repositories-content input)
# - Default (Maven Central only)
# ========================================

echo "=== Configuring SBT Repositories ==="

# Get parameters from environment
REPOSITORIES_FILE="${REPOSITORIES_FILE:-}"
REPOSITORIES_CONTENT="${REPOSITORIES_CONTENT:-}"

# SBT repositories file location
SBT_REPOSITORIES="$HOME/.sbt/repositories"

echo "Target file: $SBT_REPOSITORIES"
echo ""

# Create .sbt directory if it doesn't exist
mkdir -p "$HOME/.sbt"

# ========================================
# Priority 1: Custom file
# ========================================
if [ -n "$REPOSITORIES_FILE" ] && [ -f "$REPOSITORIES_FILE" ]; then
  echo "=== Using Custom Repositories File ==="
  echo "Source: $REPOSITORIES_FILE"
  
  # Copy the file
  cp "$REPOSITORIES_FILE" "$SBT_REPOSITORIES"
  
  echo "✓ Repositories file copied successfully"
  echo ""
  echo "Configuration:"
  cat "$SBT_REPOSITORIES"
  echo ""
  echo "✓✓✓ SBT repositories configured from file ✓✓✓"
  exit 0
fi

# ========================================
# Priority 2: Inline content
# ========================================
if [ -n "$REPOSITORIES_CONTENT" ]; then
  echo "=== Using Inline Repositories Content ==="
  
  # Write the content
  echo "$REPOSITORIES_CONTENT" > "$SBT_REPOSITORIES"
  
  echo "✓ Repositories content written successfully"
  echo ""
  echo "Configuration:"
  cat "$SBT_REPOSITORIES"
  echo ""
  echo "✓✓✓ SBT repositories configured from inline content ✓✓✓"
  exit 0
fi

# ========================================
# Priority 3: Default configuration (Maven Central)
# ========================================
echo "=== Using Default Repositories Configuration ==="
echo "No custom repositories provided, using Maven Central"
echo ""

cat > "$SBT_REPOSITORIES" <<'EOF'
[repositories]
local
maven-central
EOF

echo "✓ Default repositories configuration created"
echo ""
echo "Configuration:"
cat "$SBT_REPOSITORIES"
echo ""
echo "✓✓✓ SBT repositories configured with defaults ✓✓✓"
echo ""
echo "Note: To use a custom Artifactory or private repository,"
echo "      provide either 'repositories-file' or 'repositories-content' input"
