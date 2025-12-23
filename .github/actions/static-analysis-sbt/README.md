# Static Analysis SBT Action

**Action GitHub pour l'analyse statique de projets SBT** - Génération de rapports Jacoco, Dependency Check, et intégration SonarQube.

## 🎯 Fonctionnalités

### Phase 1 : Jacoco Coverage ✅
- ✅ Génération automatique des rapports Jacoco
- ✅ Support mono-module et multi-module
- ✅ Extraction automatique du pourcentage de couverture
- ✅ Upload des rapports vers GitHub Artifacts
- ✅ Setup SBT intégré

### Phase 2 : Dependency Check (À venir)
- 🚧 Scan des vulnérabilités CVE
- 🚧 Rapports HTML et JSON

### Phase 3 : SonarQube (À venir)
- 🚧 Upload vers SonarQube
- 🚧 Intégration des rapports Jacoco
- 🚧 Intégration des rapports Dependency Check

---

## 📦 Prérequis

### Dans Votre Projet SBT

**Plugin Jacoco requis :**

```scala
// project/plugins.sbt
addSbtPlugin("com.github.sbt" % "sbt-jacoco" % "3.4.0")
```

**Configuration (optionnelle) :**

```scala
// build.sbt
jacocoReportSettings := JacocoReportSettings(
  "Jacoco Coverage Report",
  None,
  JacocoThresholds(),
  Seq(JacocoReportFormats.ScalaHTML, JacocoReportFormats.XML),
  "utf-8"
)
```

---

## 🚀 Usage

### Exemple Simple (Mono-Module)

```yaml
name: Static Analysis

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
        uses: your-org/sbt-actions/.github/actions/build-and-test-sbt@v1
        with:
          sbt-version: '1.10.4'
          java-version: '21'
          sbt-commands: 'clean compile test package'
  
  static-analysis:
    needs: [build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Static Analysis
        uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
        with:
          component-name: 'my-service'
          build-version: '1.0.0'
          multi-module: false
          enable-jacoco: true
          upload-reports: true
```

---

### Exemple avec Artifactory Privé

```yaml
- name: Import Secrets from Vault
  uses: hashicorp/vault-action@v3
  with:
    url: ${{ secrets.VAULT_URL }}
    method: approle
    roleId: ${{ secrets.ROLEID }}
    secretId: ${{ secrets.SECRETID }}
    path: jenkins
    secrets: |
      artifactory/user value | ARTIFACTORY_USER ;
      artifactory/api-key value | ARTIFACTORY_API_KEY ;
    exportEnv: true

- name: Static Analysis
  uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
  with:
    component-name: 'my-service'
    build-version: '1.0.0'
    artifactory-host: 'artifacts.example.com'
    repositories-file: 'custom'
    multi-module: false
    enable-jacoco: true
    upload-reports: true
```

---

### Exemple Multi-Module

```yaml
- name: Static Analysis (Multi-Module)
  uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
  with:
    component-name: 'my-monorepo'
    build-version: '2.0.0'
    multi-module: true  # Utilise jacocoAggregate
    enable-jacoco: true
    upload-reports: true
```

---

### Exemple avec Tests Déjà Exécutés

Si vous avez déjà exécuté les tests dans un job précédent :

```yaml
- name: Static Analysis (Skip Tests)
  uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
  with:
    component-name: 'my-service'
    build-version: '1.0.0'
    skip-tests: true  # Génère seulement les rapports
    enable-jacoco: true
```

---

## 📋 Inputs

### Configuration SBT (hérités de setup-sbt)

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `sbt-version` | Version SBT | Non | `1.10.4` |
| `scala-version` | Version Scala | Non | `` |
| `java-version` | Version Java | Non | `21` |
| `artifactory-host` | Hostname Artifactory | Non | `` |
| `repositories-file` | Preset repositories | Non | `` |
| `repositories-content` | Contenu inline repositories | Non | `` |
| `enable-cache` | Activer cache | Non | `true` |
| `working-directory` | Répertoire de travail | Non | `.` |

### Configuration Analyse

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `multi-module` | Projet multi-module | Non | `false` |
| `component-name` | Nom du composant | **Oui** | - |
| `build-version` | Version du build | **Oui** | - |

### Configuration Jacoco

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `enable-jacoco` | Activer Jacoco | Non | `true` |
| `jacoco-command` | Commande Jacoco custom | Non | `` |
| `skip-tests` | Skip les tests | Non | `false` |

### Configuration Rapports

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `upload-reports` | Upload vers GitHub Artifacts | Non | `true` |
| `reports-artifact-name` | Nom de l'artifact | Non | (auto-généré) |
| `reports-retention-days` | Durée de rétention | Non | `7` |

### Autres

| Input | Description | Requis | Défaut |
|-------|-------------|--------|--------|
| `env-vars` | Variables d'environnement (YAML) | Non | `` |
| `sbt-opts` | Options SBT | Non | `-Dsbt.log.noformat=true` |

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `jacoco-report-path` | Chemin du rapport Jacoco XML |
| `jacoco-html-path` | Chemin du rapport Jacoco HTML |
| `coverage-percentage` | Pourcentage de couverture |
| `reports-artifact-name` | Nom de l'artifact des rapports |
| `analysis-status` | Statut (success/failure) |
| `sbt-version` | Version SBT installée |
| `cache-hit` | Cache hit (true/false) |

---

## 🔧 Commandes SBT Utilisées

### Mono-Module

**Avec tests :**
```bash
sbt clean test jacoco
```

**Sans tests (rapports seulement) :**
```bash
sbt jacoco
```

### Multi-Module

**Avec tests :**
```bash
sbt clean test jacocoAggregate
```

**Sans tests (rapports seulement) :**
```bash
sbt jacocoAggregate
```

### Custom

Vous pouvez spécifier une commande custom :

```yaml
jacoco-command: 'clean coverage test coverageReport coverageAggregate'
```

---

## 📊 Rapports Générés

### Structure des Rapports Jacoco

```
target/
└── scala-3.3.1/
    └── jacoco/
        ├── jacoco.xml          # Rapport XML (pour SonarQube)
        └── html/               # Rapport HTML
            └── index.html
```

### Multi-Module

```
target/
└── scala-3.3.1/
    ├── jacoco/                 # Rapport agrégé
    │   ├── jacoco.xml
    │   └── html/
    └── jacoco-aggregate/       # Détails par module
        └── ...
```

---

## 💡 Exemples Avancés

### Avec Variables d'Environnement

```yaml
- name: Static Analysis
  uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
  with:
    component-name: 'my-service'
    build-version: '1.0.0'
    env-vars: |
      TZ: America/New_York
      LANG: en_US.UTF-8
      CUSTOM_VAR: value
```

---

### Réutiliser les Rapports

```yaml
jobs:
  analysis:
    steps:
      - name: Generate Reports
        id: analysis
        uses: your-org/sbt-actions/.github/actions/static-analysis-sbt@v1
        with:
          component-name: 'my-service'
          build-version: '1.0.0'
      
      - name: Display Coverage
        run: |
          echo "Coverage: ${{ steps.analysis.outputs.coverage-percentage }}%"
          echo "Report: ${{ steps.analysis.outputs.jacoco-report-path }}"
      
      - name: Download Reports
        uses: actions/download-artifact@v4
        with:
          name: ${{ steps.analysis.outputs.reports-artifact-name }}
```

---

## 🐛 Troubleshooting

### Erreur : "Jacoco XML report not found"

**Cause :** Plugin sbt-jacoco non installé

**Solution :**
```scala
// project/plugins.sbt
addSbtPlugin("com.github.sbt" % "sbt-jacoco" % "3.4.0")
```

---

### Erreur : "Could not extract coverage metrics"

**Cause :** Format du rapport Jacoco inattendu

**Solution :** Vérifier la configuration Jacoco dans build.sbt

---

### Coverage = 0%

**Cause :** Pas de tests ou tests non exécutés

**Solution :**
- Vérifier que `skip-tests: false` (défaut)
- Vérifier que des tests existent dans `src/test/`

---

## 🎯 Roadmap

### Phase 1 : Jacoco Coverage ✅
- [x] Génération rapports Jacoco
- [x] Support mono/multi-module
- [x] Extraction coverage
- [x] Upload artifacts

### Phase 2 : Dependency Check 🚧
- [ ] Scan CVE
- [ ] Rapports HTML/JSON

### Phase 3 : SonarQube 🚧
- [ ] Upload vers SonarQube
- [ ] Intégration rapports Jacoco
- [ ] Intégration rapports Dependency Check
- [ ] Métriques qualité

---

## 📝 Notes

- **Cache :** Le cache SBT est géré automatiquement via setup-sbt
- **Credentials :** Les credentials doivent être dans l'environnement
- **Rapports :** Conservés 7 jours par défaut dans GitHub Artifacts
- **Multi-module :** Utilise `jacocoAggregate` pour un rapport global

---

## 🤝 Contributing

Cette action fait partie de la suite `sbt-actions` :
- [setup-sbt](./../setup-sbt/README.md)
- [build-and-test-sbt](./../build-and-test-sbt/README.md)
- **static-analysis-sbt** (vous êtes ici)

---

## 📄 License

MIT License

---

**Built with ❤️ by Tina Alliche for the SBT community**
