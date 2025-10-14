# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.0.0] - 2025-10-14

### Added
- Suppression d'arrière-plan avec intelligence artificielle via Remove.bg API
- Sélection d'image depuis la caméra ou la galerie
- Galerie locale pour gérer les images traitées
- Partage d'images traitées
- Sauvegarde automatique dans la galerie de l'appareil
- Support multi-plateforme (Android, iOS)
- Gestion de la connectivité réseau
- Interface utilisateur moderne et intuitive
- Politique de confidentialité intégrée
- Splash screen personnalisé
- Icône d'application personnalisée

### Technical
- Architecture basée sur Riverpod pour la gestion d'état
- Navigation avec GoRouter
- API Remove.bg avec gestion des erreurs et timeouts
- Tests unitaires et analyse statique
- Support Android 15 (targetSDK 35)
- Linting personnalisé avec Riverpod Lint

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
