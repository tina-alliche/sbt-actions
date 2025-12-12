# Enterprise Examples

Generic templates for using these SBT actions in an enterprise environment with private Artifactory.

## ⚠️ IMPORTANT

**These are TEMPLATES** - Replace all company-specific information with your own:
- URLs (artifacts.yourcompany.com → your actual URL)
- Vault paths (secret/data/artifactory → your vault structure)
- Repository names and paths

## 📁 Files

### `repositories.template`

Generic Artifactory repositories configuration.

**How to use:**
```bash
# Create local config directory (gitignored)
mkdir -p config/company

# Copy and customize
cp examples/enterprise/repositories.template config/company/repositories

# Edit with your company's URLs
vim config/company/repositories
```

### `workflow-vault.yml.template`

Workflow example with HashiCorp Vault integration.

**How to use:**
```bash
# Copy to workflows
cp examples/enterprise/workflow-vault.yml.template .github/workflows/sbt-ci.yml

# Customize:
# - ARTIFACTORY_URL
# - VAULT_URL
# - Vault secret paths
# - SBT/Scala/Java versions
```

## 🔧 Setup Guide

### Step 1: Clone Repository

```bash
git clone <your-fork-of-this-repo>
cd <repo>
```

### Step 2: Create Company Configuration

```bash
# Create config directory (this will be gitignored)
mkdir -p config/company

# Copy template
cp examples/enterprise/repositories.template config/company/repositories

# Edit with your Artifactory URLs
vim config/company/repositories
```

**Example:**
```properties
[repositories]
local
maven: https://artifacts.acme.com/artifactory/maven-virtual/
sbt: https://artifacts.acme.com/artifactory/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
```

### Step 3: Create Workflow

```bash
# Copy template
cp examples/enterprise/workflow-vault.yml.template .github/workflows/sbt-ci.yml

# Customize for your company
vim .github/workflows/sbt-ci.yml
```

**What to customize:**
- `ARTIFACTORY_URL`: Your Artifactory URL
- `VAULT_URL`: Your Vault server URL
- Vault secret paths (adapt to your Vault structure)
- `repositories-file` path
- SBT/Scala/Java versions

### Step 4: Configure GitHub Secrets

In your GitHub repository settings:
- `VAULT_ROLE_ID`: AppRole role ID for Vault
- `VAULT_SECRET_ID`: AppRole secret ID for Vault

### Step 5: Verify .gitignore

Make sure `config/` is gitignored:

```gitignore
config/*/
!config/.gitkeep
```

### Step 6: Test

```bash
# Commit workflow (NOT the config files)
git add .github/workflows/sbt-ci.yml
git commit -m "Add SBT CI workflow"
git push

# Check Actions tab in GitHub
```

## 📋 Customization Checklist

- [ ] Replace `artifacts.yourcompany.com` with actual URL
- [ ] Replace `vault.yourcompany.com` with actual URL
- [ ] Update Vault secret paths to match your structure
- [ ] Set SBT version for your project
- [ ] Set Scala version for your project
- [ ] Set Java version for your project
- [ ] Configure GitHub secrets (VAULT_ROLE_ID, VAULT_SECRET_ID)
- [ ] Test workflow on a branch first

## 🔐 Vault Configuration

Your Vault structure might look like:

```
secret/data/artifactory/
  ├── user
  └── api-key

secret/data/sonarqube/
  ├── url
  └── token
```

Adapt the `secrets:` section in the workflow to match your structure.

## 💡 Tips

1. **Start Simple**: Begin with just Artifactory, add other integrations later
2. **Test Locally**: Use `config/company/` for company-specific configs
3. **Version Control**: Only commit generic files, never company secrets
4. **Documentation**: Document your company's specific setup in a separate internal wiki

## 🆘 Troubleshooting

**Problem: Secrets not found in Vault**
- Check Vault paths match your organization's structure
- Verify VAULT_ROLE_ID and VAULT_SECRET_ID have correct permissions

**Problem: Artifactory authentication fails**
- Verify credentials-host matches your Artifactory hostname
- Check ARTIFACTORY_USER and ARTIFACTORY_API_KEY are exported correctly

**Problem: Repository not found**
- Verify repository URLs in your config file
- Check that your Artifactory virtual repositories exist

## 📞 Support

This is a generic template. For company-specific support:
- Contact your DevOps team
- Check your company's internal documentation
- Consult your Artifactory/Vault administrators
