# Setup SBT Action

Generic GitHub Action to setup SBT environment with Java, repositories configuration, and Artifactory credentials.

## Features

- ✅ **Java Setup**: Configures Java with specified version and distribution
- ✅ **SBT Installation**: Downloads and installs SBT from GitHub or custom URL
- ✅ **Flexible Repositories**: Supports Maven Central, private Artifactory, or custom configuration
- ✅ **Credentials Management**: Configures Artifactory credentials from environment variables
- ✅ **Smart Caching**: Caches ivy2, SBT, and Coursier for faster builds
- ✅ **Multiple Sources**: Download SBT from GitHub releases or custom Artifactory

## Usage

### Basic Usage (Public Repositories)

```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'
    scala-version: '3.3.1'
    java-version: '21'
```

This will:
- Install Java 21
- Download SBT 1.10.4 from GitHub
- Configure Maven Central as the default repository
- Enable caching for faster subsequent builds

### With Private Artifactory (Inline Configuration)

```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'
    scala-version: '3.3.1'
    java-version: '21'
    credentials-host: 'artifacts.example.com'
    repositories-content: |
      [repositories]
      local
      maven: https://artifacts.example.com/maven-virtual/
      sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
  env:
    ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
    ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
```

### With Private Artifactory (External File)

```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'
    scala-version: '3.3.1'
    java-version: '21'
    credentials-host: 'artifacts.example.com'
    repositories-file: 'config/repositories'
  env:
    ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
    ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
```

### With Custom SBT Download URL

```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'
    java-version: '21'
    download-sbt-from: 'custom-url'
    sbt-download-url: 'https://artifacts.example.com/tools/sbt-1.10.4.zip'
  env:
    ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
    ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
```

## Inputs

### Version Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `sbt-version` | SBT version to install | Yes | `1.10.4` |
| `scala-version` | Scala version (for documentation) | No | `3.3.1` |
| `java-version` | Java version to setup | Yes | `21` |
| `java-distribution` | Java distribution (temurin, zulu, adopt, etc.) | No | `temurin` |

### Repositories Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `repositories-file` | Path to custom repositories file | No | `''` |
| `repositories-content` | Inline repositories configuration | No | `''` |

**Priority:**
1. If `repositories-file` is provided → uses the file
2. If `repositories-content` is provided → uses inline content
3. Otherwise → uses Maven Central

### Credentials Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `credentials-realm` | Artifactory realm | No | `Artifactory Realm` |
| `credentials-host` | Artifactory host (e.g., artifacts.example.com) | No | `''` |

**Note:** If `credentials-host` is empty, credentials will not be configured.

**Required Environment Variables (when using credentials):**
- `ARTIFACTORY_USER`: Username for Artifactory
- `ARTIFACTORY_API_KEY` or `ARTIFACTORY_PASSWORD`: API key or password

### Cache Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `enable-cache` | Enable SBT caching | No | `true` |
| `cache-key-prefix` | Prefix for cache keys | No | `sbt` |

### SBT Download Configuration

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `download-sbt-from` | Where to download SBT: `github` or `custom-url` | No | `github` |
| `sbt-download-url` | Custom URL to download SBT | No | `''` |

### Advanced Options

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `sbt-opts` | Additional SBT options | No | `-Dsbt.override.build.repos=true -Dsbt.log.noformat=true` |
| `working-directory` | Working directory | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `sbt-version` | Installed SBT version |
| `sbt-path` | Path to SBT installation |
| `cache-hit` | Whether cache was restored |

## Environment Variables

### Required (for private Artifactory)

- `ARTIFACTORY_USER`: Username for Artifactory authentication
- `ARTIFACTORY_API_KEY` or `ARTIFACTORY_PASSWORD`: API key or password for authentication

These should be provided from:
- GitHub Secrets
- HashiCorp Vault (via `hashicorp/vault-action`)
- Other secret management systems

## Examples

### Example 1: Simple Public Project

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup SBT
        uses: ./.github/actions/setup-sbt
        with:
          sbt-version: '1.10.4'
          scala-version: '3.3.1'
          java-version: '21'
      
      - name: Compile
        run: sbt compile
```

### Example 2: With Private Artifactory

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup SBT
        uses: ./.github/actions/setup-sbt
        with:
          sbt-version: '1.10.4'
          scala-version: '3.3.1'
          java-version: '21'
          credentials-host: 'artifacts.example.com'
          repositories-content: |
            [repositories]
            local
            maven: https://artifacts.example.com/maven-virtual/
            sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
        env:
          ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
          ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
      
      - name: Build
        run: sbt clean compile test
```

### Example 3: With HashiCorp Vault

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Import Secrets from Vault
        uses: hashicorp/vault-action@v3
        with:
          url: ${{ secrets.VAULT_URL }}
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          secrets: |
            secret/data/artifactory user | ARTIFACTORY_USER ;
            secret/data/artifactory api-key | ARTIFACTORY_API_KEY ;
          exportEnv: true
      
      - name: Setup SBT
        uses: ./.github/actions/setup-sbt
        with:
          sbt-version: '1.10.4'
          scala-version: '3.3.1'
          java-version: '21'
          credentials-host: 'artifacts.example.com'
          repositories-file: 'config/repositories'
      
      - name: Build
        run: sbt clean compile test
```

## Repositories Configuration

### Maven Central (Default)

If no repositories are configured, the action uses Maven Central:

```properties
[repositories]
local
maven-central
```

### Custom Artifactory

Create a `repositories` file or use inline configuration:

```properties
[repositories]
local
maven: https://artifacts.example.com/maven-virtual/
sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
```

### Multiple Repositories

```properties
[repositories]
local
company-maven: https://artifacts.example.com/maven-virtual/
company-sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
maven-central
```

## Caching

The action caches the following directories for faster subsequent builds:

- `~/.ivy2/cache` - Ivy2 dependency cache
- `~/.ivy2/local` - Local Ivy2 repository
- `~/.sbt` - SBT global cache
- `~/.cache/coursier` - Coursier cache
- `sbt-install/{version}` - SBT installation

Cache keys are based on:
- Operating system
- Hash of `build.sbt` and `plugins.sbt` files
- Cache key prefix

To disable caching:

```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    enable-cache: 'false'
```

## Credentials

The action creates two credential files:

1. **Ivy2 credentials** (`~/.ivy2/.credentials`):
   ```properties
   realm=Artifactory Realm
   host=artifacts.example.com
   user=${ARTIFACTORY_USER}
   password=${ARTIFACTORY_API_KEY}
   ```

2. **SBT credentials** (`~/.sbt/1.0/plugins/credentials.sbt`):
   ```scala
   credentials += Credentials(
     "Artifactory Realm",
     "artifacts.example.com",
     sys.env.getOrElse("ARTIFACTORY_USER", ""),
     sys.env.getOrElse("ARTIFACTORY_API_KEY", "")
   )
   ```

## Troubleshooting

### Issue: SBT not found after setup

**Solution:** The SBT executable is added to PATH. Make sure to use it in subsequent steps:

```yaml
- name: Verify SBT
  run: |
    which sbt
    sbt sbtVersion
```

### Issue: Credentials not working

**Solution:** Check that environment variables are set:

```yaml
- name: Debug credentials
  run: |
    echo "User: ${ARTIFACTORY_USER:-NOT_SET}"
    echo "API Key: ${ARTIFACTORY_API_KEY:+SET}"
```

### Issue: Repository not found

**Solution:** Verify your repositories configuration:

```yaml
- name: Check repositories
  run: cat ~/.sbt/repositories
```

### Issue: Cache not working

**Solution:** Check cache outputs:

```yaml
- name: Setup SBT
  id: setup-sbt
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'

- name: Check cache
  run: echo "Cache hit: ${{ steps.setup-sbt.outputs.cache-hit }}"
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

[Your License Here]
