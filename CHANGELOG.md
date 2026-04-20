# Changelog

## [1.2.0] - 2026-04-20

### Added
- Suppression d'arrière-plan par IA directement sur l'appareil (ONNX Runtime) — aucune connexion Internet requise
- Ajout d'une image comme fond du résultat (en plus de la couleur unie)
- Aperçu en direct du fond dans la page résultat
- Nouveau design : typographie Outfit/Nunito, palette violet/fuchsia, animations enrichies
- Hero animé sur la page d'accueil

### Changed
- Architecture : remplacement de l'API Remove.bg par un moteur ML local (`image_background_remover`)
- Suppression des limites de traitement (était 2 req/jour en gratuit)
- iOS : déploiement minimum relevé à iOS 16.0

### Removed
- Dépendance à Internet pour le traitement des images
- Bannière de connectivité réseau
- Clé API Remove.bg (plus nécessaire)

## [1.0.0] - 2025-10-14

### Added
- Suppression d'arrière-plan avec Remove.bg API
- Sélection d'image depuis la caméra ou la galerie
- Galerie locale pour gérer les images traitées
- Partage d'images traitées
- Sauvegarde automatique dans la galerie de l'appareil
- Support multi-plateforme (Android, iOS)
- Interface utilisateur moderne et intuitive

---

## Guide d'utilisation du CHANGELOG

### Quand ajouter une entrée ?

À chaque nouvelle version, ajoutez une section avec :
- **[Version]** : Numéro de version (ex: 1.0.1)
- **Date** : Date de release (YYYY-MM-DD)
- **Catégories** : Organisez les changements par type

### Catégories disponibles

#### Added (Ajouté)
Pour les nouvelles fonctionnalités.

Exemple :
```markdown
### Added
- Nouvelle fonctionnalité de filtres photo
- Support du mode sombre
```

#### Changed (Modifié)
Pour les modifications de fonctionnalités existantes.

Exemple :
```markdown
### Changed
- Amélioration de l'interface utilisateur
- Mise à jour des dépendances Flutter
```

#### Fixed (Corrigé)
Pour les corrections de bugs.

Exemple :
```markdown
### Fixed
- Correction du crash au démarrage sur Android 15
- Résolution du bug de sauvegarde d'image
```

#### Deprecated (Déprécié)
Pour les fonctionnalités bientôt retirées.

Exemple :
```markdown
### Deprecated
- L'ancien système de cache sera retiré en v2.0.0
```

#### Removed (Retiré)
Pour les fonctionnalités retirées.

Exemple :
```markdown
### Removed
- Suppression du support Android 5.0
```

#### Security (Sécurité)
Pour les correctifs de sécurité.

Exemple :
```markdown
### Security
- Correction de la vulnérabilité CVE-2024-XXXXX
- Mise à jour des certificats SSL
```

### Template pour nouvelle version

Copiez ce template pour chaque nouvelle version :

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
-

### Changed
-

### Fixed
-

### Security
-
```

### Exemples de bonnes entrées

✅ **BON** : Descriptif et clair
```markdown
## [1.1.0] - 2025-10-20

### Added
- Ajout du support des filtres photo (noir et blanc, sépia)
- Nouvelle fonctionnalité de recadrage d'image

### Fixed
- Correction du crash lors de la sélection d'images très volumineuses
- Résolution du problème de rotation d'image sur certains appareils
```

❌ **MAUVAIS** : Trop vague
```markdown
## [1.1.0] - 2025-10-20

### Changed
- Améliorations diverses
- Corrections de bugs
```

### Notes importantes

- **Les workflows CI/CD lisent automatiquement ce fichier** pour générer les notes de version sur Play Store
- Gardez les descriptions **courtes** et **orientées utilisateur**
- Utilisez un **langage simple** (évitez le jargon technique)
- Mettez à jour ce fichier **avant** de créer un tag de version
- Les versions non encore publiées peuvent utiliser `[Unreleased]` comme en-tête

### Exemple de workflow avec CHANGELOG

```bash
# 1. Modifiez le code
git commit -m "feat: add image filters"

# 2. Mettez à jour CHANGELOG.md
# Ajoutez vos changements dans la section [Unreleased] ou créez [1.1.0]

# 3. Lancez le workflow Version Bump sur GitHub
# Il créera automatiquement une nouvelle section dans CHANGELOG.md

# 4. Le workflow Deploy utilisera ces notes pour Play Store
```
