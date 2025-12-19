# Tests pour build-and-test-sbt

Documentation des workflows de test pour l'action `build-and-test-sbt`.

---

## 📋 Workflows de Test

### **1. test-build-and-test-public.yml** ☁️

**Test l'usage PUBLIC (Maven Central)**

**Ce qui est testé :**
- ✅ Action fonctionne avec Maven Central
- ✅ Pas besoin d'Artifactory
- ✅ Pas besoin de credentials
- ✅ Setup SBT est appelé en interne
- ✅ Build réussit
- ✅ Outputs corrects (`action-artifact-name`, `build-status`, etc.)
- ✅ Artifacts uploadés
- ✅ Artifacts téléchargeables

**Configuration :**
```yaml
with:
  sbt-version: '1.10.4'
  scala-version: '3.3.1'
  java-version: '21'
  # PAS de artifactory-host
  # PAS de repositories-file
  sbt-commands: 'clean compile test'
```

**Quand il se lance :**
- Push sur `main` ou `develop`
- Pull request vers `main`
- Changements dans :
  - `.github/actions/build-and-test-sbt/**`
  - `.github/actions/setup-sbt/**`
  - `test-project/**`
- Manuellement via `workflow_dispatch`

---

### **2. test-build-and-test-enterprise.yml** 🏢

**Test l'usage ENTERPRISE (Artifactory)**

**Ce qui est testé :**
- ✅ Action fonctionne avec configuration Artifactory
- ✅ Setup SBT est appelé avec bons paramètres
- ✅ Repositories configurés correctement
- ✅ Credentials créés (fichiers existent)
- ✅ Variables d'environnement (env-vars) fonctionnent
- ✅ Fallback vers Maven Central si Artifactory fail
- ✅ Structure de l'action (inputs, outputs)

**Configuration :**
```yaml
env:
  ARTIFACTORY_USER: test-user
  ARTIFACTORY_API_KEY: test-api-key-mock-value

with:
  artifactory-host: 'artifacts.example.com'
  repositories-file: 'test-configs/repositories-enterprise-test'
  env-vars: |
    TZ: America/Montreal
    TEST_ENV: enterprise-test
```

**Note Importante :**
Les credentials sont **mockés** (pas réels). Le build peut échouer à cause de ça, mais c'est OK !
Le test vérifie que :
1. Setup est fait correctement
2. Fallback vers Maven Central fonctionne

**Quand il se lance :**
- Push sur `main` ou `develop`
- Pull request vers `main`
- Changements dans :
  - `.github/actions/build-and-test-sbt/**`
  - `.github/actions/setup-sbt/**`
  - `test-project/**`
  - `test-configs/**`
- Manuellement via `workflow_dispatch`

---

## 🎯 Ce Que Chaque Test Vérifie

### **Test Public**

| Vérification | Description |
|--------------|-------------|
| **Setup SBT** | Action appelle setup-sbt correctement |
| **Maven Central** | Build fonctionne sans Artifactory |
| **Build Success** | `sbt clean compile test` réussit |
| **Outputs** | Tous les outputs sont présents et corrects |
| **Artifact Upload** | Artifact uploadé avec nom correct |
| **Artifact Download** | Artifact peut être téléchargé |
| **Build Files** | Classes compilées existent |

### **Test Enterprise**

| Vérification | Description |
|--------------|-------------|
| **Setup SBT** | Action appelle setup-sbt avec bons params |
| **Repositories** | Fichier `~/.sbt/repositories` créé |
| **Credentials** | Fichiers credentials créés |
| **Env Vars** | Variables d'env (TZ, etc.) configurées |
| **Action Structure** | Fichiers action.yml, README.md existent |
| **Inputs/Outputs** | Tous les inputs/outputs définis |
| **Maven Fallback** | Build réussit avec Maven Central si Artifactory fail |

---

## 🚀 Lancer les Tests Manuellement

### **Via GitHub Actions UI**

1. Va sur l'onglet **Actions** du repo
2. Sélectionne le workflow :
   - "Test Build and Test SBT - Public"
   - "Test Build and Test SBT - Enterprise"
3. Clique **"Run workflow"**
4. Sélectionne la branche
5. Clique **"Run workflow"**

### **Via GitHub CLI**

```bash
# Test Public
gh workflow run "Test Build and Test SBT - Public"

# Test Enterprise
gh workflow run "Test Build and Test SBT - Enterprise"

# Voir les résultats
gh run list --workflow="Test Build and Test SBT - Public"
gh run watch
```

---

## 📊 Interpréter les Résultats

### **✅ Test Public Réussi**

```
✅✅✅ ALL TESTS PASSED ✅✅✅

Build Status: success
Artifact Name: test-public-kR3mP9xQwZ
Artifact Uploaded: true
Cache Hit: false (ou true si cache existait)
```

**Signification :**
- Action fonctionne parfaitement en mode public
- Build réussit avec Maven Central
- Artifacts uploadés correctement
- Prêt pour utilisation en production

---

### **✅ Test Enterprise Réussi**

```
✅✅✅ CRITICAL TESTS PASSED ✅✅✅

Test 1: Artifactory Configuration
  - Setup SBT called: ✅
  - Repositories configured: ✅
  - Credentials configured: ✅
  - Build status: failure (expected with mock credentials)

Test 2: Maven Central Fallback
  - Build status: success
  - Fallback works: ✅

Test 3: Action Structure
  - Files exist: ✅
  - Calls setup-sbt: ✅
```

**Signification :**
- Action configure Artifactory correctement
- Env vars fonctionnent
- Fallback vers Maven Central fonctionne
- Structure de l'action est bonne
- Prêt pour utilisation en production

**Note :** Test 1 peut échouer (credentials mock), c'est normal ! Ce qui compte c'est le Test 2 (fallback).

---

## ❌ Debugging des Échecs

### **Test Public Échoue**

**Cause possible 1 : Build SBT fail**
```
❌ ERROR: Build status is not success
```

**Solution :**
- Vérifier le projet test (`test-project/`)
- Vérifier les dépendances dans `build.sbt`
- Vérifier les versions (Scala, SBT)

**Cause possible 2 : Outputs vides**
```
❌ ERROR: action-artifact-name is empty
```

**Solution :**
- Vérifier l'action `action.yml`
- Vérifier les steps d'output
- Vérifier le script de génération de nom

**Cause possible 3 : Artifact pas uploadé**
```
❌ ERROR: Artifact not uploaded
```

**Solution :**
- Vérifier le pattern de fichiers (`artifact-path`)
- Vérifier que les JARs sont créés
- Vérifier les permissions de fichiers

---

### **Test Enterprise Échoue**

**Cause possible 1 : Setup pas appelé**
```
❌ ERROR: Action does not call setup-sbt
```

**Solution :**
- Vérifier `action.yml`
- Vérifier la ligne `uses: ../../setup-sbt`

**Cause possible 2 : Inputs manquants**
```
❌ ERROR: Input 'artifactory-host' not found
```

**Solution :**
- Vérifier la section `inputs:` dans `action.yml`
- Vérifier l'orthographe exacte

**Cause possible 3 : Fallback échoue**
```
❌ ERROR: Fallback failed
```

**Solution :**
- Problème avec Maven Central
- Vérifier la connexion réseau
- Vérifier les dépendances du projet test

---

## 🔧 Modifier les Tests

### **Ajouter une Vérification**

Dans `test-build-and-test-public.yml` :

```yaml
- name: My Custom Verification
  run: |
    echo "Testing something specific"
    
    if [ condition ]; then
      echo "✅ Test passed"
    else
      echo "❌ Test failed"
      exit 1
    fi
```

### **Changer les Paramètres de Test**

```yaml
- uses: ./.github/actions/build-and-test-sbt
  with:
    sbt-version: '1.9.0'      # Tester autre version
    java-version: '17'        # Tester autre Java
    sbt-commands: 'clean test' # Tester autres commandes
```

### **Ajouter un Nouveau Test**

Créer un nouveau job dans le workflow :

```yaml
test-with-custom-config:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: ./.github/actions/build-and-test-sbt
      with:
        # Configuration spécifique
```

---

## 📁 Fichiers Requis

### **Pour Test Public**

```
.github/workflows/test-build-and-test-public.yml
test-project/
├── build.sbt
├── project/
│   └── build.properties
└── src/
    └── main/scala/
```

### **Pour Test Enterprise**

```
.github/workflows/test-build-and-test-enterprise.yml
test-project/
└── (même structure)
test-configs/
└── repositories-enterprise-test
```

**Créer `test-configs/repositories-enterprise-test` si manquant :**

```bash
mkdir -p test-configs

cat > test-configs/repositories-enterprise-test << 'EOF'
[repositories]
local
maven: https://artifacts.example.com/maven-virtual/
sbt: https://artifacts.example.com/sbt-virtual/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
EOF
```

---

## ✅ Checklist Avant Commit

Avant de committer les workflows de test :

- [ ] Les 2 workflows sont dans `.github/workflows/`
- [ ] Projet test existe (`test-project/`)
- [ ] Fichier `test-configs/repositories-enterprise-test` existe
- [ ] Action `build-and-test-sbt` est complète
- [ ] Action `setup-sbt` est à jour
- [ ] Lancer les tests manuellement
- [ ] Vérifier que les 2 tests passent

---

## 🎯 Prochaines Étapes

**Après que les tests passent :**

1. ✅ Merger sur `main`
2. ✅ Créer tag v1.1.0
3. ✅ Tester sur projet DXP réel
4. ✅ Documenter dans README principal
5. ✅ Annoncer aux équipes

---

## 📞 Support

**Si les tests échouent de manière inexpliquée :**

1. Vérifier les logs détaillés dans GitHub Actions
2. Vérifier la section "Test Summary" à la fin
3. Comparer avec les exemples de résultats ci-dessus
4. Vérifier les changements récents dans setup-sbt

---

**Créé pour accompagner l'action build-and-test-sbt** 🚀
