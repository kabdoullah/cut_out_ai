# Guide CI/CD avec GitHub Actions - CutOut AI

Ce guide explique comment configurer et utiliser les workflows CI/CD pour automatiser les tests, builds et déploiements de l'application CutOut AI.

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Configuration initiale](#configuration-initiale)
3. [Workflows disponibles](#workflows-disponibles)
4. [Configuration des secrets GitHub](#configuration-des-secrets-github)
5. [Configuration Play Store API](#configuration-play-store-api)
6. [Utilisation quotidienne](#utilisation-quotidienne)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

### Qu'est-ce que le CI/CD ?

**CI (Continuous Integration)** : Tests et vérifications automatiques à chaque modification du code.

**CD (Continuous Deployment)** : Construction et déploiement automatiques de l'application.

### Architecture des workflows

```
Code Push → CI Tests → Version Bump → Build → Deploy → Play Store
```

### Workflows créés

| Workflow | Fichier | Déclencheur | Durée | Objectif |
|----------|---------|-------------|-------|----------|
| **CI Tests** | `ci.yml` | Push/PR | ~5 min | Tests & qualité |
| **Build Android** | `build-android.yml` | Tag/Manuel | ~10 min | APK/AAB signé |
| **Deploy Play Store** | `deploy-playstore.yml` | Manuel | ~5 min | Publication |
| **Version Bump** | `version-bump.yml` | Manuel | ~30 sec | Gestion version |

---

## ⚙️ Configuration initiale

### Prérequis

- [x] Compte GitHub avec accès au repository
- [x] Compte Google Play Developer actif
- [x] Keystore de signature créé
- [x] Clé API Remove.bg

### Étape 1 : Encoder le Keystore en Base64

```bash
# Sur Linux/macOS
base64 -w 0 ~/cutout-ai-release.jks > keystore_base64.txt

# Sur macOS (alternative)
base64 -i ~/cutout-ai-release.jks | tr -d '\n' > keystore_base64.txt

# Sur Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\keystore.jks")) | Out-File -Encoding ASCII keystore_base64.txt
```

Le fichier `keystore_base64.txt` contient maintenant votre keystore encodé.

### Étape 2 : Pousser les workflows sur GitHub

```bash
git add .github/workflows/
git add CHANGELOG.md
git commit -m "ci: add GitHub Actions workflows"
git push origin main
```

---

## 🔒 Configuration des secrets GitHub

### Accéder aux secrets

1. Allez sur : `https://github.com/kabdoullah/cut_out_ai`
2. Cliquez sur **Settings**
3. Dans le menu gauche : **Secrets and variables** → **Actions**
4. Cliquez **New repository secret**

### Secrets requis

#### 1. KEYSTORE_BASE64

**Description** : Votre fichier `.jks` encodé en base64

**Valeur** : Contenu du fichier `keystore_base64.txt` créé à l'étape 1

**Commande** :
```bash
cat keystore_base64.txt
```

#### 2. KEYSTORE_PASSWORD

**Description** : Mot de passe du keystore

**Valeur** : Le mot de passe que vous avez utilisé lors de la création du keystore

**Exemple** : `MonMotDePasseKeystore123!`

#### 3. KEY_ALIAS

**Description** : Alias de la clé dans le keystore

**Valeur** : L'alias défini lors de la création du keystore

**Exemple** : `cutout-ai-key`

**Comment le retrouver** :
```bash
keytool -list -v -keystore ~/cutout-ai-release.jks
# Cherchez "Alias name:"
```

#### 4. KEY_PASSWORD

**Description** : Mot de passe de la clé

**Valeur** : Le mot de passe de la clé (peut être différent du mot de passe du keystore)

**Exemple** : `MonMotDePasseKey456!`

#### 5. REMOVEBG_API_KEY

**Description** : Clé API Remove.bg

**Valeur** : Votre clé API Remove.bg

**Où la trouver** : [remove.bg/dashboard](https://remove.bg/dashboard)

**Exemple** : `AbCdEfGhIjKlMnOpQrStUvWx1234567890`

#### 6. PLAYSTORE_SERVICE_ACCOUNT_JSON

**Description** : Credentials JSON du Service Account Google Cloud

**Valeur** : Contenu complet du fichier JSON (voir section suivante)

**Format** :
```json
{
  "type": "service_account",
  "project_id": "...",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "...",
  "client_id": "...",
  ...
}
```

### Récapitulatif des secrets

| Nom du secret | Type | Exemple |
|---------------|------|---------|
| `KEYSTORE_BASE64` | String (long) | `eW91ci1rZXlzdG9yZS1iYXNlNjQ=...` |
| `KEYSTORE_PASSWORD` | String | `MonMotDePasse123!` |
| `KEY_ALIAS` | String | `cutout-ai-key` |
| `KEY_PASSWORD` | String | `MaClé456!` |
| `REMOVEBG_API_KEY` | String | `abc123xyz...` |
| `PLAYSTORE_SERVICE_ACCOUNT_JSON` | JSON | `{"type":"service_account",...}` |

---

## 🔐 Configuration Play Store API

Pour permettre à GitHub Actions de déployer sur Play Store, vous devez créer un Service Account.

### Étape 1 : Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com)
2. Créez un nouveau projet ou sélectionnez-en un existant
3. Notez l'**ID du projet**

### Étape 2 : Activer l'API Google Play

1. Dans Google Cloud Console, allez dans **APIs & Services** → **Library**
2. Cherchez **"Google Play Android Developer API"**
3. Cliquez **Enable** (Activer)

### Étape 3 : Créer un Service Account

1. Dans Google Cloud Console : **IAM & Admin** → **Service Accounts**
2. Cliquez **Create Service Account**
3. Remplissez :
   - **Service account name** : `github-actions-cutout-ai`
   - **Service account ID** : Auto-généré
   - **Description** : `Service account for GitHub Actions CI/CD`
4. Cliquez **Create and Continue**
5. **Grant this service account access to project** : Sélectionnez **Editor**
6. Cliquez **Done**

### Étape 4 : Créer une clé JSON

1. Cliquez sur le Service Account créé
2. Allez dans l'onglet **Keys**
3. Cliquez **Add Key** → **Create new key**
4. Choisissez **JSON**
5. Cliquez **Create**
6. Le fichier JSON est téléchargé automatiquement
7. **⚠️ Sauvegardez ce fichier en lieu sûr !**

### Étape 5 : Lier le Service Account à Play Console

1. Allez sur [Google Play Console](https://play.google.com/console)
2. Allez dans **Setup** → **API Access** (Configuration → Accès API)
3. Dans la section **Service accounts**, cliquez **Link a service account**
4. Suivez les instructions pour lier votre projet Google Cloud
5. Le Service Account apparaît dans la liste

### Étape 6 : Donner les permissions

1. Cliquez sur **Grant access** (Accorder l'accès) à côté du Service Account
2. Dans l'onglet **App permissions** :
   - Sélectionnez **Cutout AI**
3. Dans l'onglet **Account permissions** :
   - ✅ **View app information and download bulk reports**
   - ✅ **Manage production releases**
   - ✅ **Manage testing track releases**
4. Cliquez **Invite user**
5. Le Service Account est maintenant configuré !

### Étape 7 : Ajouter le JSON dans GitHub Secrets

1. Ouvrez le fichier JSON téléchargé dans un éditeur de texte
2. Copiez **tout le contenu** (incluant les accolades `{}`)
3. Dans GitHub : **Settings** → **Secrets** → **New repository secret**
4. Nom : `PLAYSTORE_SERVICE_ACCOUNT_JSON`
5. Valeur : Collez le contenu JSON
6. Cliquez **Add secret**

### Vérification

```bash
# Le JSON doit contenir ces champs
cat service-account.json | jq 'keys'
# Résultat attendu:
# [
#   "type",
#   "project_id",
#   "private_key_id",
#   "private_key",
#   "client_email",
#   "client_id",
#   "auth_uri",
#   "token_uri",
#   ...
# ]
```

---

## 🚀 Workflows disponibles

### 1. CI - Tests & Analyse (`ci.yml`)

**Objectif** : Vérifier la qualité du code automatiquement

**Déclenchement** :
- Push sur `main` ou `develop`
- Pull Request vers `main` ou `develop`

**Actions** :
- ✅ Vérification du formatage (`dart format`)
- ✅ Analyse statique (`flutter analyze`)
- ✅ Linting custom (`riverpod_lint`)
- ✅ Tests unitaires (`flutter test`)
- ✅ Couverture de code (upload vers Codecov)
- ✅ Build de vérification (APK debug)

**Durée** : ~5-7 minutes

**Utilisation** :
```bash
# Le workflow se déclenche automatiquement
git add .
git commit -m "feat: add new feature"
git push
```

**Résultat** :
- ✅ Badge vert : Tout est OK
- ❌ Badge rouge : Des tests échouent ou le code ne compile pas

---

### 2. Build Android (`build-android.yml`)

**Objectif** : Construire l'APK et l'App Bundle signés

**Déclenchement** :
- Automatique : Lors de la création d'un tag `v*.*.*`
- Manuel : Via le bouton "Run workflow" sur GitHub

**Options manuelles** :
- **build_type** : `apk`, `appbundle`, ou `both`

**Actions** :
- 🔐 Décodage du keystore
- 📝 Création de `key.properties`
- 🏗️ Build de l'App Bundle (`.aab`)
- 📦 Build de l'APK (`.apk`) si demandé
- ✍️ Signature avec le keystore
- 📤 Upload des artefacts
- 🏷️ Création de GitHub Release (si tag)

**Durée** : ~10-12 minutes

**Utilisation manuelle** :

1. Allez dans **Actions** sur GitHub
2. Sélectionnez **Build Android**
3. Cliquez **Run workflow**
4. Choisissez la branche : `main`
5. Choisissez le type de build : `appbundle`
6. Cliquez **Run workflow**

**Utilisation automatique (avec tag)** :

```bash
# Créez un tag et poussez-le
git tag v1.0.1
git push origin v1.0.1

# Le workflow se déclenche automatiquement
```

**Résultat** :
- 📦 Artefacts disponibles dans l'onglet **Actions** → Workflow run → **Artifacts**
- 📥 GitHub Release créée avec les fichiers téléchargeables (si tag)

**Télécharger les artefacts** :

1. Allez dans **Actions**
2. Cliquez sur le workflow run
3. Scrollez vers le bas → section **Artifacts**
4. Téléchargez `app-bundle-release` ou `app-apk-release`

---

### 3. Deploy to Play Store (`deploy-playstore.yml`)

**Objectif** : Déployer automatiquement sur Google Play Store

**Déclenchement** :
- Automatique : Après un build Android réussi
- Manuel : Via le bouton "Run workflow"

**Options manuelles** :
- **track** : `internal`, `alpha`, `beta`, `production`
- **rollout_percentage** : `10`, `25`, `50`, `100` (pour production)

**Actions** :
- 🏗️ Build de l'App Bundle
- 🔐 Authentification Play Store API
- 📤 Upload de l'App Bundle
- 📝 Extraction et ajout des notes de version depuis `CHANGELOG.md`
- 🚀 Publication sur la track choisie

**Durée** : ~5-7 minutes

**Utilisation** :

#### Déploiement en Internal Testing

```
1. Actions → Deploy to Play Store → Run workflow
2. track: internal
3. Run workflow
```

#### Déploiement en Beta

```
1. Actions → Deploy to Play Store → Run workflow
2. track: beta
3. Run workflow
```

#### Déploiement en Production (rollout progressif)

```
1. Actions → Deploy to Play Store → Run workflow
2. track: production
3. rollout_percentage: 25
4. Run workflow
```

**Résultat** :
- ✅ App Bundle uploadé sur Play Store
- 📝 Notes de version ajoutées
- 🔔 Notification de succès

**Vérification** :
1. Allez sur [Play Console](https://play.google.com/console)
2. Sélectionnez **Cutout AI**
3. Allez dans la section correspondante (Internal testing, Beta, Production)
4. Vous devriez voir la nouvelle version

---

### 4. Version Bump (`version-bump.yml`)

**Objectif** : Gérer les versions automatiquement

**Déclenchement** : Manuel uniquement

**Options** :
- **bump_type** : `patch`, `minor`, `major`, `build`
- **create_tag** : `true` ou `false`
- **trigger_build** : `true` ou `false`

**Types de bump** :

| Type | Exemple | Usage |
|------|---------|-------|
| `patch` | `1.0.0` → `1.0.1` | Correction de bugs |
| `minor` | `1.0.0` → `1.1.0` | Nouvelles fonctionnalités |
| `major` | `1.0.0` → `2.0.0` | Changements majeurs |
| `build` | `1.0.0+1` → `1.0.0+2` | Rebuild sans changement |

**Actions** :
- 📖 Lecture de la version actuelle
- 🔢 Calcul de la nouvelle version
- ✏️ Mise à jour de `pubspec.yaml`
- 📝 Création d'une nouvelle entrée dans `CHANGELOG.md`
- 💾 Commit des changements
- 🏷️ Création d'un tag Git (optionnel)
- ▶️ Déclenchement du build (optionnel)

**Durée** : ~30 secondes

**Utilisation** :

#### Correction de bug (patch)

```
1. Actions → Version Bump → Run workflow
2. bump_type: patch
3. create_tag: true
4. trigger_build: true
5. Run workflow

Résultat: 1.0.0 → 1.0.1
```

#### Nouvelle fonctionnalité (minor)

```
1. Actions → Version Bump → Run workflow
2. bump_type: minor
3. create_tag: true
4. trigger_build: true
5. Run workflow

Résultat: 1.0.1 → 1.1.0
```

#### Refonte majeure (major)

```
1. Actions → Version Bump → Run workflow
2. bump_type: major
3. create_tag: true
4. trigger_build: true
5. Run workflow

Résultat: 1.1.0 → 2.0.0
```

**Résultat** :
- ✅ `pubspec.yaml` mis à jour
- ✅ `CHANGELOG.md` avec nouvelle section
- ✅ Commit automatique
- ✅ Tag Git créé (si demandé)
- ✅ Build déclenché (si demandé)

---

## 📱 Utilisation quotidienne

### Scénario 1 : Correction rapide d'un bug

```bash
# 1. Correction du bug
vim lib/features/image_processing/providers/image_view_model.dart

# 2. Test local
flutter test

# 3. Commit et push
git add .
git commit -m "fix: correction du crash au démarrage"
git push

# ✅ CI workflow se déclenche automatiquement et teste le code

# 4. Si les tests passent, bump la version
# GitHub Actions → Version Bump → Run workflow
# - bump_type: patch
# - create_tag: true
# - trigger_build: true

# ✅ Version automatiquement incrémentée : 1.0.0 → 1.0.1
# ✅ Build automatique déclenché
# ✅ Artefacts disponibles après 10 minutes

# 5. Déployer en internal testing
# GitHub Actions → Deploy to Play Store → Run workflow
# - track: internal

# ✅ App disponible pour les testeurs internes en 5 minutes
```

**Temps total** : ~20 minutes (dont 15 min d'attente automatique)

---

### Scénario 2 : Nouvelle fonctionnalité

```bash
# 1. Créer une branche feature
git checkout -b feature/image-filters

# 2. Développer la fonctionnalité
# ... code ...

# 3. Commit et push
git add .
git commit -m "feat: add image filters (b&w, sepia)"
git push origin feature/image-filters

# ✅ CI workflow teste automatiquement

# 4. Créer une Pull Request sur GitHub
# ✅ CI re-teste automatiquement

# 5. Review et merge vers main

# 6. Bump version (minor)
# GitHub Actions → Version Bump → Run workflow
# - bump_type: minor
# - create_tag: true
# - trigger_build: true

# ✅ Version: 1.0.1 → 1.1.0

# 7. Tester en beta
# GitHub Actions → Deploy to Play Store → Run workflow
# - track: beta

# 8. Si OK, déployer en production
# GitHub Actions → Deploy to Play Store → Run workflow
# - track: production
# - rollout_percentage: 25

# 9. Augmenter progressivement le rollout
# GitHub Actions → Deploy to Play Store → Run workflow
# - track: production
# - rollout_percentage: 100
```

**Temps total** : ~30 minutes de travail actif

---

### Scénario 3 : Publication urgente (hotfix)

```bash
# 1. Créer une branche hotfix
git checkout -b hotfix/critical-crash
git checkout main
git pull
git checkout -b hotfix/critical-crash

# 2. Corriger le bug critique
# ... fix ...

# 3. Test local
flutter test

# 4. Commit et push
git add .
git commit -m "fix: correction du crash critique sur Android 15"
git push origin hotfix/critical-crash

# 5. Merger immédiatement vers main (pas de PR)
git checkout main
git merge hotfix/critical-crash
git push

# 6. Bump version (patch)
# GitHub Actions → Version Bump → Run workflow
# - bump_type: patch
# - create_tag: true
# - trigger_build: true

# 7. Déployer directement en production
# GitHub Actions → Deploy to Play Store → Run workflow
# - track: production
# - rollout_percentage: 100

# ✅ Correctif en production en 20 minutes
```

---

## 🔍 Dépannage

### Problème 1 : CI échoue avec "flutter analyze"

**Symptôme** :
```
flutter analyze
Analyzing cutout_ai...
  error • Undefined name 'context' • lib/...dart:42:15 • undefined_identifier
1 issue found.
```

**Solution** :
```bash
# Corrigez les erreurs d'analyse
flutter analyze

# Si tout est OK localement, vérifiez les versions
flutter --version
```

---

### Problème 2 : Build échoue avec "Keystore not found"

**Symptôme** :
```
Error: Keystore file not found
```

**Cause** : Le secret `KEYSTORE_BASE64` n'est pas configuré ou est invalide

**Solution** :
1. Vérifiez que le secret existe : **Settings** → **Secrets** → `KEYSTORE_BASE64`
2. Réencodez le keystore :
   ```bash
   base64 -w 0 ~/cutout-ai-release.jks > keystore_base64.txt
   cat keystore_base64.txt
   ```
3. Remplacez le secret avec la nouvelle valeur

---

### Problème 3 : Build échoue avec "Wrong password"

**Symptôme** :
```
Error: Failed to load keystore: Wrong password
```

**Cause** : `KEYSTORE_PASSWORD` ou `KEY_PASSWORD` incorrect

**Solution** :
1. Testez localement :
   ```bash
   keytool -list -v -keystore ~/cutout-ai-release.jks
   # Entrez le mot de passe
   ```
2. Si le mot de passe est correct localement, mettez à jour les secrets GitHub :
   - `KEYSTORE_PASSWORD`
   - `KEY_PASSWORD`

---

### Problème 4 : Deploy échoue avec "Authentication failed"

**Symptôme** :
```
Error: Failed to authenticate with Google Play API
```

**Cause** : Service Account JSON invalide ou permissions insuffisantes

**Solution** :

1. Vérifiez le JSON :
   ```bash
   cat service-account.json | jq .
   # Doit afficher un JSON valide
   ```

2. Vérifiez les permissions dans [Play Console](https://play.google.com/console) :
   - **Setup** → **API Access**
   - Trouvez le Service Account
   - Vérifiez qu'il a accès à **Cutout AI**
   - Vérifiez les permissions :
     - ✅ View app information
     - ✅ Manage production releases
     - ✅ Manage testing track releases

3. Vérifiez que l'API est activée :
   - [Google Cloud Console](https://console.cloud.google.com)
   - **APIs & Services** → **Library**
   - Cherchez "Google Play Android Developer API"
   - Vérifiez qu'elle est **Enabled**

---

### Problème 5 : Version Bump ne crée pas de tag

**Symptôme** :
```
Error: unable to push tag
```

**Cause** : Permissions GitHub Actions insuffisantes

**Solution** :

1. Allez dans **Settings** → **Actions** → **General**
2. Scrollez vers **Workflow permissions**
3. Sélectionnez **Read and write permissions**
4. ✅ Cochez **Allow GitHub Actions to create and approve pull requests**
5. Cliquez **Save**

---

### Problème 6 : Build réussit mais APK/AAB introuvable

**Symptôme** :
Le workflow se termine avec succès, mais pas d'artefacts

**Cause** : Artefacts expirés ou non générés

**Solution** :

1. Vérifiez les logs du workflow :
   - **Actions** → Cliquez sur le workflow run
   - Regardez les étapes "Build App Bundle" et "Upload App Bundle"

2. Vérifiez la rétention des artefacts :
   - Par défaut : 30 jours
   - Peut être modifié dans le workflow : `retention-days: 90`

3. Téléchargez immédiatement après le build :
   - **Actions** → Workflow run → **Artifacts**

---

### Problème 7 : Tests échouent avec "API key not found"

**Symptôme** :
```
Error: REMOVEBG_API_KEY environment variable not set
```

**Cause** : Le secret `REMOVEBG_API_KEY` n'est pas configuré

**Solution** :

1. Ajoutez le secret :
   - **Settings** → **Secrets** → **New repository secret**
   - Nom : `REMOVEBG_API_KEY`
   - Valeur : Votre clé API Remove.bg

2. Récupérez votre clé API :
   - [remove.bg/dashboard](https://remove.bg/dashboard)

---

### Problème 8 : Workflow en attente indéfiniment

**Symptôme** :
Le workflow reste en statut "Queued" ou "Waiting"

**Cause** : Limite de runners GitHub atteinte

**Solution** :

1. Vérifiez l'utilisation :
   - **Settings** → **Billing** → **Usage this month**

2. Pour repos publics : Illimité (mais max 20 jobs concurrents)

3. Pour repos privés :
   - Free tier : 2000 minutes/mois
   - Si dépassé, ajoutez un mode de paiement

4. Optimisez les workflows :
   - Réduisez `timeout-minutes`
   - Utilisez le cache Flutter

---

### Problème 9 : "Build number must be greater"

**Symptôme** :
```
Error: versionCode 3 has already been used
```

**Cause** : Le build number n'a pas été incrémenté

**Solution** :

1. Utilisez le workflow **Version Bump** qui incrémente automatiquement

2. Ou manuellement :
   ```yaml
   # pubspec.yaml
   version: 1.0.0+4  # Incrémentez le nombre après le +
   ```

3. Le build number doit **toujours augmenter**, même si vous revenez à une version antérieure :
   - ❌ `1.0.1+4` → `1.0.0+3` (INVALIDE)
   - ✅ `1.0.1+4` → `1.0.0+5` (VALIDE)

---

### Problème 10 : CHANGELOG mal formaté

**Symptôme** :
Les notes de version ne s'affichent pas correctement sur Play Store

**Cause** : Format CHANGELOG.md incorrect

**Solution** :

Respectez ce format :

```markdown
## [1.0.1] - 2025-10-14

### Added
- Nouvelle fonctionnalité

### Fixed
- Correction de bug
```

**Points importants** :
- Titre : `## [X.Y.Z] - YYYY-MM-DD`
- Sous-titres : `### Added`, `### Fixed`, etc.
- Liste à puces : `-` (tiret + espace)
- Ligne vide après chaque section

---

## 📊 Monitoring et statistiques

### Voir l'état des workflows

1. **Badge GitHub** :

   Ajoutez dans votre `README.md` :
   ```markdown
   ![CI](https://github.com/kabdoullah/cut_out_ai/workflows/CI%20-%20Tests%20%26%20Analyse/badge.svg)
   ```

2. **Onglet Actions** :
   - Liste de tous les workflow runs
   - Statut (Success, Failed, Cancelled)
   - Durée d'exécution
   - Logs détaillés

3. **Notifications email** :
   - GitHub envoie automatiquement des emails en cas d'échec
   - Configurable dans **Settings** → **Notifications**

### Statistiques d'utilisation

**Settings** → **Actions** → **General** → **Usage**

- Minutes utilisées ce mois-ci
- Minutes restantes (repos privés)
- Historique d'utilisation

### Temps d'exécution typiques

| Workflow | Durée moyenne | Facteurs d'influence |
|----------|---------------|---------------------|
| CI Tests | 5-7 min | Nombre de tests |
| Build Android | 10-12 min | Taille du projet |
| Deploy Play Store | 5-7 min | Taille de l'AAB |
| Version Bump | 30 sec | Négligeable |

### Optimisations possibles

1. **Cache Flutter** : Déjà activé dans les workflows
   ```yaml
   cache: true
   cache-key: 'flutter-:os:-:channel:-:version:'
   ```

2. **Cache Gradle** : Ajouter si builds lents
   ```yaml
   - uses: actions/cache@v4
     with:
       path: |
         ~/.gradle/caches
         ~/.gradle/wrapper
       key: gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
   ```

3. **Paralléliser les jobs** :
   - CI : `analyze-and-test` + `build-check` en parallèle
   - Déjà implémenté dans les workflows

---

## 🎓 Bonnes pratiques

### 1. Gestion des branches

```
main (production)
  ↓
develop (développement)
  ↓
feature/* (fonctionnalités)
hotfix/* (correctifs urgents)
```

**Workflow recommandé** :
```bash
# Nouvelle fonctionnalité
git checkout develop
git pull
git checkout -b feature/my-feature
# ... develop ...
git push origin feature/my-feature
# Create PR: feature/my-feature → develop

# Merge vers develop
# Test en internal/alpha

# Merge vers main
# Deploy en production
```

### 2. Commits conventionnels

Utilisez le format Conventional Commits :

| Type | Usage | Exemple |
|------|-------|---------|
| `feat:` | Nouvelle fonctionnalité | `feat: add dark mode` |
| `fix:` | Correction de bug | `fix: resolve crash on startup` |
| `docs:` | Documentation | `docs: update README` |
| `style:` | Formatage | `style: fix indentation` |
| `refactor:` | Refactoring | `refactor: improve performance` |
| `test:` | Tests | `test: add unit tests for auth` |
| `chore:` | Maintenance | `chore: update dependencies` |
| `ci:` | CI/CD | `ci: add deploy workflow` |

### 3. Tests avant push

```bash
# Toujours tester localement avant de push
flutter analyze
flutter test
flutter build apk --debug
```

### 4. Gestion des versions

| Changement | Type | Version |
|-----------|------|---------|
| Bug fix mineur | `patch` | 1.0.0 → 1.0.1 |
| Nouvelle fonctionnalité (compatible) | `minor` | 1.0.0 → 1.1.0 |
| Breaking change | `major` | 1.0.0 → 2.0.0 |
| Rebuild sans changement | `build` | 1.0.0+1 → 1.0.0+2 |

### 5. Déploiement progressif

Pour minimiser les risques :

```
Internal Testing (10 utilisateurs)
  ↓ 2-3 jours
Alpha (50 utilisateurs)
  ↓ 1 semaine
Beta (500 utilisateurs)
  ↓ 1 semaine
Production 25%
  ↓ 2 jours
Production 50%
  ↓ 2 jours
Production 100%
```

### 6. Monitoring post-déploiement

Après chaque déploiement, surveillez :

1. **Play Console** :
   - Crashes & ANRs
   - Avis utilisateurs
   - Statistiques d'installation

2. **Firebase Crashlytics** (si configuré) :
   - Crash reports en temps réel
   - Logs d'erreur

3. **Analytics** :
   - Taux de rétention
   - Engagement utilisateur

---

## 🔗 Ressources utiles

### Documentation officielle

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Google Play Developer API](https://developers.google.com/android-publisher)

### Actions GitHub utilisées

- [actions/checkout@v4](https://github.com/actions/checkout)
- [actions/setup-java@v4](https://github.com/actions/setup-java)
- [subosito/flutter-action@v2](https://github.com/subosito/flutter-action)
- [r0adkll/upload-google-play@v1](https://github.com/r0adkll/upload-google-play)

### Outils de monitoring

- [Codecov](https://codecov.io) - Couverture de code
- [Firebase Crashlytics](https://firebase.google.com/products/crashlytics) - Crash reporting
- [Sentry](https://sentry.io) - Error tracking

---

## 📞 Support

### Obtenir de l'aide

1. **Issues GitHub** : Créez une issue sur le repository
2. **Documentation** : Consultez ce guide et `GUIDE_SIGNATURE_PLAYSTORE.md`
3. **Logs** : Consultez les logs détaillés dans GitHub Actions

### Logs utiles

```bash
# Voir les logs d'un workflow
GitHub → Actions → Cliquez sur le run → Cliquez sur un job → Voir les logs

# Télécharger les logs
GitHub → Actions → Run → ... → Download log archive
```

---

**Date de dernière mise à jour** : 2025-10-14
**Version du guide** : 1.0.0
**Auteur** : CutOut AI Team
