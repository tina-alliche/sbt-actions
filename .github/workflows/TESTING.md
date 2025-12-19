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

**Pattern Utilisé :**
```yaml
steps:
  - Checkout
  - Create Test Project  # AVANT d'appeler l'action
  - Build and Test       # Avec working-directory: './test-project'
  - Verify Outputs
```

**Configuration :**
```yaml
- name: Create Test Project
  run: |
    mkdir -p test-project/project
    cat > test-project/build.sbt << 'EOF'
    scalaVersion := "3.3.1"
    name := "test-project"
    libraryDependencies += "org.scala-lang.modules" %% "scala-parser-combinators" % "2.3.0"
    EOF
    echo 'sbt.version=1.10.4' > test-project/project/build.properties

- uses: ./.github/actions/build-and-test-sbt
  with:
    sbt-version: '1.10.4'
    java-version: '21'
    sbt-commands: 'clean compile'
    working-directory: './test-project'
```

**Quand il se lance :**
- Push sur `main` ou `develop`
- Pull request vers `main`
- Changements dans :
  - `.github/actions/build-and-test-sbt/**`
  - `.github/actions/setup-sbt/**`
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

**Pattern Utilisé :**
```yaml
steps:
  - Checkout
  - Setup Mock Credentials
  - Create Test Project  # AVANT d'appeler l'action
  - Build and Test       # Avec Artifactory config
  - Verify Setup
  - Test Fallback        # Maven Central si Artifactory fail
```

**Configuration :**
```yaml
env:
  ARTIFACTORY_USER: test-user
  ARTIFACTORY_API_KEY: test-api-key-mock-value

- uses: ./.github/actions/build-and-test-sbt
  with:
    artifactory-host: 'artifacts.example.com'
    repositories-file: 'test-configs/repositories-test'
    working-directory: './test-project'
    env-vars: |
      TZ: America/New_York
      TEST_ENV: enterprise-test
```

**Note Importante :**
Les credentials sont **mockés** (pas réels). Le build peut échouer à cause de ça, mais c'est OK !
Le test vérifie que :
1. Setup est fait correctement
2. Fallback vers Maven Central fonctionne

---

## 🎯 Pattern de Test Correct

### **✅ BON Pattern (Utilisé)**

```yaml
steps:
  # 1. Checkout
  - uses: actions/checkout@v4
  
  # 2. Créer test-project AVANT
  - name: Create Test Project
    run: |
      mkdir -p test-project/project
      echo 'scalaVersion := "3.3.1"' > test-project/build.sbt
      echo 'sbt.version=1.10.4' > test-project/project/build.properties
  
  # 3. Appeler l'action (projet existe déjà)
  - uses: ./.github/actions/build-and-test-sbt
    with:
      working-directory: './test-project'
      sbt-commands: 'clean compile'
```

**Pourquoi ça marche :**
- Le projet existe AVANT l'action ✅
- setup-sbt peut faire `cd ./test-project` sans erreur ✅
- Les commandes SBT s'exécutent dans le bon dossier ✅

---

### **❌ MAUVAIS Pattern (À Éviter)**

```yaml
steps:
  # 1. Checkout
  - uses: actions/checkout@v4
  
  # 2. Appeler l'action SANS créer le projet
  - uses: ./.github/actions/build-and-test-sbt
    with:
      working-directory: './test-project'  # ❌ N'existe pas encore !
```

**Pourquoi ça échoue :**
- setup-sbt essaie de `cd ./test-project` ❌
- Le dossier n'existe pas ❌
- Erreur : "No such file or directory" ❌

---

## 🔧 Fichiers Requis

### **Pour Test Public & Enterprise**

```
test-configs/
└── repositories-test
```

**Créer `test-configs/repositories-test` si manquant :**

```bash
mkdir -p test-configs

cat > test-configs/repositories-test << 'EOF'
[repositories]
local
maven-central: https://repo1.maven.org/maven2/
typesafe: https://repo.typesafe.com/typesafe/releases/
EOF
```

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

### **Erreur : "No such file or directory"**

```
Error: cd: ./test-project: No such file or directory
```

**Cause :** Le projet test n'existe pas avant l'action

**Solution :** Créer test-project AVANT d'appeler l'action (pattern correct ci-dessus)

---

### **Erreur : "Expected format {org}/{repo}[/path]@ref"**

```
Error: Expected format {org}/{repo}[/path]@ref. Actual '../../setup-sbt'
```

**Cause :** Chemin relatif invalide dans action.yml

**Solution :** Utiliser chemin absolu `./.github/actions/setup-sbt`

---

### **Test Public Échoue**

**Cause possible 1 : Build SBT fail**
```
❌ ERROR: Build status is not success
```

**Solution :**
- Vérifier les dépendances dans `build.sbt`
- Vérifier les versions (Scala, SBT)
- Vérifier Maven Central est accessible

**Cause possible 2 : Outputs vides**
```
❌ ERROR: action-artifact-name is empty
```

**Solution :**
- Vérifier l'action `action.yml`
- Vérifier les steps d'output
- Vérifier le script de génération de nom

---

### **Test Enterprise Échoue Complètement**

**Cause : Fallback ne marche pas**

**Solution :**
- Vérifier que Maven Central est accessible
- Vérifier que test-project est créé correctement
- Vérifier les logs détaillés

---

## ✅ Checklist Avant Commit

Avant de committer les workflows de test :

- [ ] Les 2 workflows sont dans `.github/workflows/`
- [ ] Fichier `test-configs/repositories-test` existe
- [ ] Action `build-and-test-sbt` est complète
- [ ] Action `setup-sbt` est à jour
- [ ] Pattern correct : Créer test-project AVANT l'action
- [ ] Lancer les tests manuellement
- [ ] Vérifier que les 2 tests passent

---

## 🎯 Prochaines Étapes

**Après que les tests passent :**

1. ✅ Merger sur `main`
2. ✅ Créer tag v1.1.0
3. ✅ Tester sur projet réel
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

**Créé par Tina Alliche pour l'action build-and-test-sbt** 🚀
