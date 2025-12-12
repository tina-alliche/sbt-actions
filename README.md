# Generic SBT GitHub Actions

![Test Public](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Setup%20SBT/badge.svg)
![Test Enterprise](https://github.com/tina-alliche/sbt-actions/workflows/Test%20Setup%20SBT%20-%20Enterprise/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

**Reusable GitHub Actions for SBT projects** - Works with public repositories (Maven Central) and private Artifactory instances.
## 🎯 Features

- ✅ **Generic and Reusable**: Works with any Artifactory or public repositories
- ✅ **Flexible Configuration**: Inline, file-based, or default configurations
- ✅ **Smart Caching**: Fast builds with intelligent caching of ivy2, SBT, and Coursier
- ✅ **Multiple Java/SBT Versions**: Configurable Java and SBT versions
- ✅ **Credentials Management**: Secure credential handling via environment variables
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

### 2. `build-and-test-sbt` *(Coming Soon)*

Compile and test SBT projects.

### 3. `static-analysis-sbt` *(Coming Soon)*

Run static analysis with coverage, dependency-check, and SonarQube.

## 🚀 Quick Start

### For Public Projects (Maven Central)

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
          java-version: '21'
      
      - name: Build
        run: sbt clean compile test
```

### For Private Artifactory

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

## 📚 Documentation

- [Setup SBT Action](./.github/actions/setup-sbt/README.md)
- [Examples](./examples/public/) - Example configurations

## 📁 Repository Structure

```
.github/
├── actions/
│   ├── setup-sbt/           # Setup SBT action
│   ├── build-and-test-sbt/  # (Coming soon)
│   └── static-analysis-sbt/ # (Coming soon)

examples/
└── public/                   # Examples for public projects

docs/                         # (Coming soon)
```

## 🔧 Usage Modes

### Mode 1: Public Projects

Use Maven Central and other public repositories. No configuration needed.

**Example:** See [examples/public/workflow-public.yml](./examples/public/workflow-public.yml)

### Mode 2: Private Artifactory (Inline Config)

Provide repository configuration inline in the workflow.

**Example:**
```yaml
repositories-content: |
  [repositories]
  local
  maven: https://artifacts.example.com/maven-virtual/
```

### Mode 3: Private Artifactory (External File)

Use an external repositories file (recommended for complex setups).

**Example:**
```yaml
repositories-file: 'config/repositories'
```

### Mode 4: Enterprise with Vault

Integrate with HashiCorp Vault for secret management.

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

## 📊 Current Status

| Action | Status | Documentation |
|--------|--------|---------------|
| `setup-sbt` | ✅ Complete | [README](./.github/actions/setup-sbt/README.md) |
| `build-and-test-sbt` | 🚧 In Progress | Coming soon |
| `static-analysis-sbt` | 📋 Planned | Coming soon |

## 🛣️ Roadmap

### Phase 1: Foundation ✅
- [x] `setup-sbt` action
- [x] Basic caching
- [x] Credentials management
- [x] Repository configuration

### Phase 2: Build & Test 🚧
- [ ] `build-and-test-sbt` action
- [ ] Test report collection
- [ ] Artifact upload

### Phase 3: Static Analysis 📋
- [ ] `static-analysis-sbt` action
- [ ] Coverage (Jacoco/Scoverage)
- [ ] Dependency check
- [ ] SonarQube integration

## 🤝 Contributing

Contributions are welcome! This project is designed to be generic and reusable.

### Guidelines

- Keep actions generic (no hard-coded private configs)
- Document all inputs and outputs
- Provide examples for common use cases
- Write clear error messages

## 📝 License

MIT License

## 🙏 Acknowledgments

Built for enterprise and open-source use with flexibility in mind.

---

**Need help?** Check the [documentation](./.github/actions/setup-sbt/README.md) or open an issue.
