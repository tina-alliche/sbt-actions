# Generic SBT GitHub Actions

![Test Setup SBT](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Setup%20SBT/badge.svg)
![Test Setup SBT - Enterprise](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Setup%20SBT%20-%20Enterprise/badge.svg)
![Test Build and Test - Public](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Build%20and%20Test%20SBT%20-%20Public/badge.svg)
![Test Build and Test - Enterprise](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Build%20and%20Test%20SBT%20-%20Enterprise/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

**Reusable GitHub Actions for SBT projects** - Works with public repositories (Maven Central) and private Artifactory instances.

## 🎯 Features

- ✅ **Generic and Reusable**: Works with any Artifactory or public repositories
- ✅ **Flexible Configuration**: Inline, file-based, or default configurations
- ✅ **Smart Caching**: Fast builds with intelligent caching of ivy2, SBT, and Coursier
- ✅ **Multiple Java/SBT Versions**: Configurable Java and SBT versions
- ✅ **Credentials Management**: Secure credential handling via environment variables
- ✅ **Integrated Build & Test**: Complete build, test, and artifact management
- ✅ **Open Source Friendly**: No hard-coded private configurations

## 📦 Actions

### 1. `setup-sbt`

Setup SBT environment with Java, repositories, and credentials.

[→ Full Documentation](./.github/actions/setup-sbt/README.md)

**Quick Example:**
```yaml
- name: Setup SBT
  uses: ./.github/actions/setup-sbt
  with:
    sbt-version: '1.10.4'
    scala-version: '3.3.1'
    java-version: '21'
```

---

### 2. `build-and-test-sbt` ✨

Build, test, and upload artifacts for SBT projects. **Includes automatic SBT setup** - no separate setup step needed!

[→ Full Documentation](./.github/actions/build-and-test-sbt/README.md)

**Quick Example:**
```yaml
- name: Build and Test
  uses: ./.github/actions/build-and-test-sbt
  with:
    sbt-version: '1.10.4'
    scala-version: '3.3.1'
    java-version: '21'
    sbt-commands: 'clean compile test'
```

**With Artifactory:**
```yaml
- name: Build and Test
  uses: ./.github/actions/build-and-test-sbt
  with:
    sbt-version: '1.10.4'
    java-version: '21'
    artifactory-host: 'artifacts.example.com'
    repositories-file: 'config/repositories'
    sbt-commands: 'clean compile jacocoAggregate dist'
  env:
    ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
    ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
```

---

### 3. `static-analysis-sbt` *(Coming Soon)*

Run static analysis with coverage, dependency-check, and SonarQube.

---

## 🚀 Quick Start

### Basic Build (Public Repository)

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and Test
        uses: ./.github/actions/build-and-test-sbt
        with:
          sbt-version: '1.10.4'
          java-version: '21'
          sbt-commands: 'clean compile test'
```

### Complete Pipeline with Artifacts

```yaml
name: CI Pipeline

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact-name: ${{ steps.build.outputs.action-artifact-name }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and Test
        id: build
        uses: ./.github/actions/build-and-test-sbt
        with:
          sbt-version: '1.10.4'
          scala-version: '3.3.1'
          java-version: '21'
          sbt-commands: 'clean compile test package'
  
  deploy:
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: ${{ needs.build.outputs.artifact-name }}
      
      # Deploy your artifacts...
```

### With Private Artifactory

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and Test
        uses: ./.github/actions/build-and-test-sbt
        with:
          sbt-version: '1.10.4'
          java-version: '21'
          artifactory-host: 'artifacts.example.com'
          repositories-content: |
            [repositories]
            local
            maven: https://artifacts.example.com/maven-virtual/
            sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
          sbt-commands: 'clean compile test'
        env:
          ARTIFACTORY_USER: ${{ secrets.ARTIFACTORY_USER }}
          ARTIFACTORY_API_KEY: ${{ secrets.ARTIFACTORY_API_KEY }}
```

---

## 📚 Documentation

- [Setup SBT Action](./.github/actions/setup-sbt/README.md)
- [Build and Test SBT Action](./.github/actions/build-and-test-sbt/README.md)
- [Examples](./examples/) - Example configurations

---

## 📁 Repository Structure

```
.github/
├── actions/
│   ├── setup-sbt/           # Setup SBT action
│   ├── build-and-test-sbt/  # Build and test action
│   └── static-analysis-sbt/ # (Coming soon)
├── workflows/
│   ├── test-setup-sbt.yml
│   ├── test-setup-sbt-enterprise.yml
│   ├── test-build-and-test-public.yml
│   └── test-build-and-test-enterprise.yml

examples/
├── public/                   # Examples for public projects
└── enterprise/               # Examples for enterprise setup

test-configs/                 # Test configurations
```

---

## 🔧 Usage Modes

### Mode 1: Public Projects (Maven Central)

Use Maven Central and other public repositories. No configuration needed.

```yaml
- uses: ./.github/actions/build-and-test-sbt
  with:
    sbt-commands: 'clean compile test'
```

### Mode 2: Private Artifactory (Inline Config)

Provide repository configuration inline in the workflow.

```yaml
- uses: ./.github/actions/build-and-test-sbt
  with:
    artifactory-host: 'artifacts.example.com'
    repositories-content: |
      [repositories]
      local
      maven: https://artifacts.example.com/maven-virtual/
```

### Mode 3: Private Artifactory (External File)

Use an external repositories file (recommended for complex setups).

```yaml
- uses: ./.github/actions/build-and-test-sbt
  with:
    artifactory-host: 'artifacts.example.com'
    repositories-file: 'config/repositories'
```

### Mode 4: Enterprise with Vault

Integrate with HashiCorp Vault for secret management.

```yaml
- uses: hashicorp/vault-action@v3
  with:
    url: ${{ secrets.VAULT_URL }}
    secrets: |
      secret/data/artifactory user | ARTIFACTORY_USER ;
      secret/data/artifactory api-key | ARTIFACTORY_API_KEY ;
    exportEnv: true

- uses: ./.github/actions/build-and-test-sbt
  with:
    artifactory-host: 'artifacts.example.com'
    repositories-file: 'config/repositories'
```

---

## 🔐 Security

### Credentials

Credentials are provided via environment variables:
- `ARTIFACTORY_USER`: Username
- `ARTIFACTORY_API_KEY` or `ARTIFACTORY_PASSWORD`: API key or password

These should come from:
- GitHub Secrets
- HashiCorp Vault
- Other secret management systems

### Configuration Separation

- **Public repo**: Generic actions, no private configs
- **Local config**: Private configurations in `config/` (gitignored)

---

## 🏢 Enterprise Setup

For enterprise setup with private Artifactory:

1. **Clone this repository**
2. **Create local configuration** (gitignored):
   ```bash
   mkdir -p config/company
   # Add your repositories configuration
   ```
3. **Configure GitHub secrets** for credentials
4. **Use in your workflows**

---

## 📊 Current Status

| Action | Status | Documentation |
|--------|--------|---------------|
| `setup-sbt` | ✅ Complete | [README](./.github/actions/setup-sbt/README.md) |
| `build-and-test-sbt` | ✅ Complete | [README](./.github/actions/build-and-test-sbt/README.md) |
| `static-analysis-sbt` | 📋 Planned | Coming soon |

---

## 🛣️ Roadmap

### Phase 1: Foundation ✅
- [x] `setup-sbt` action
- [x] Basic caching
- [x] Credentials management
- [x] Repository configuration

### Phase 2: Build & Test ✅
- [x] `build-and-test-sbt` action
- [x] Integrated SBT setup
- [x] Environment variables support
- [x] Artifact upload to GitHub Actions
- [x] Smart artifact naming
- [x] Production-ready testing

### Phase 3: Static Analysis 📋
- [ ] `static-analysis-sbt` action
- [ ] Coverage (Jacoco/Scoverage)
- [ ] Dependency check
- [ ] SonarQube integration

---

## 🎉 Key Features

### Smart Caching
- Caches ivy2, SBT, and Coursier dependencies
- 50-70% faster builds after first run
- Automatic cache key generation

### Flexible Artifact Management
- Upload to GitHub Actions
- Automatic artifact naming with random suffix
- Configurable retention periods
- Support for any file pattern

### Environment Variables
- Pass custom environment variables via YAML
- Support for timezone (TZ), locale (LANG), and custom vars
- Clean, readable configuration

### Production-Ready
- Tested with real-world commands (`dist`, `jacocoAggregate`)
- Support for sbt-native-packager
- Support for sbt-jacoco
- Enterprise-grade reliability

---

## 🤝 Contributing

Contributions are welcome! This project is designed to be generic and reusable.

### Guidelines

- Keep actions generic (no hard-coded private configs)
- Document all inputs and outputs
- Provide examples for common use cases
- Write clear error messages
- Test with both public and enterprise configurations

---

## 📝 License

MIT License

---

## 🙏 Acknowledgments

Built with ❤️ by Tina Alliche for enterprise and open-source use with flexibility in mind.

---

**Need help?** Check the [documentation](./.github/actions/) or open an issue.
