# Checklist de déploiement Play Store - CutOut AI

## ✅ Configuration technique (TERMINÉ)

- [x] **Keystore de production créé** : `cutout-ai-release-key.keystore`
- [x] **Configuration signature** : `key.properties` et `build.gradle.kts`
- [x] **Application ID** : `com.abdoulaye.cutout_ai`
- [x] **Target SDK** : API 34 (Android 14)
- [x] **Version** : 1.0.0+1
- [x] **Build AAB réussi** : `app-release.aab` (43MB)
- [x] **Script de build** : `build_release.sh`

## 📋 Assets requis (À COMPLÉTER)

### Obligatoires
- [ ] **Icône haute résolution** : 512x512px (PNG, 32-bit avec alpha)
- [ ] **Screenshots smartphone** : minimum 2, maximum 8
  - [ ] Page d'accueil avec illustration IA
  - [ ] Sélection d'image (caméra/galerie)
  - [ ] Comparaison avant/après avec slider
  - [ ] Galerie des créations
- [ ] **Description courte** : 80 caractères max
- [ ] **Description complète** : 4000 caractères max

### Optionnels mais recommandés
- [ ] **Bannière de feature** : 1024x500px
- [ ] **Screenshots tablette** : 7" et 10"
- [ ] **Vidéo de démonstration** : max 30 secondes

## 📄 Métadonnées (À COMPLÉTER)

### Informations de base
- [x] **Titre** : "CutOut AI - Suppression d'arrière-plan"
- [x] **Description courte** : "Supprimez l'arrière-plan de vos photos avec l'IA en quelques secondes"
- [x] **Description complète** : Rédigée dans `store_listing.md`
- [ ] **Catégorie** : Photographie
- [ ] **Mots-clés** : IA, photo, arrière-plan, suppression, édition

### Informations légales
- [ ] **Politique de confidentialité** : URL requis
- [ ] **Conditions d'utilisation** : Optionnel mais recommandé
- [ ] **Classification de contenu** : Tous publics
- [ ] **Permissions justifiées** : Documentation des permissions

## 🛡️ Conformité et sécurité

### Permissions
- [x] **INTERNET** : Pour API Remove.bg ✓
- [x] **CAMERA** : Pour prendre des photos ✓
- [x] **READ_EXTERNAL_STORAGE** : Pour accéder à la galerie ✓
- [x] **READ_MEDIA_IMAGES** : Android 13+ ✓

### Tests requis
- [ ] **Test sur device physique** Android 13+
- [ ] **Test permissions** : Dénier puis accepter
- [ ] **Test mode avion** : Gestion hors ligne
- [ ] **Test performance** : Pas de crash, responsive
- [ ] **Test API limits** : Gestion erreurs Remove.bg

## 🏪 Configuration Play Console

### Étape 1 : Création de l'app
- [ ] Créer nouvelle application sur Play Console
- [ ] Sélectionner "App" (pas "Jeu")
- [ ] Choisir nom : "CutOut AI"
- [ ] Langue par défaut : Français

### Étape 2 : Configuration du contenu
- [ ] **Classification du contenu** : Questionnaire obligatoire
- [ ] **Données de sécurité** : Formulaire sur collecte de données
- [ ] **Public cible** : Déterminer tranche d'âge
- [ ] **Politique familiale** : Si app enfants

### Étape 3 : Version de test
- [ ] **Test interne** : Ajouter testeurs (optionnel)
- [ ] **Test fermé** : Groupe limité (recommandé)
- [ ] **Validation** : Pas d'erreurs de crash

### Étape 4 : Production
- [ ] Upload de l'AAB final
- [ ] Configuration des pays de distribution
- [ ] Définition du prix (gratuit)
- [ ] Soumission pour review

## ⚠️ Points critiques

### Sécurité
- [ ] **Keystore sauvegardé** : Dans lieu sûr, plusieurs copies
- [ ] **Mots de passe notés** : Stockage sécurisé
- [ ] **Clé API Remove.bg** : Limite et facturation vérifiées

### Performance
- [ ] **Taille APK** : <150MB recommandé (actuel: 43MB ✓)
- [ ] **Temps de démarrage** : <3 secondes
- [ ] **Consommation mémoire** : Raisonnable
- [ ] **Gestion erreurs** : Pas de crash utilisateur

### Légal
- [ ] **Droits d'utilisation** : API Remove.bg autorisée commercialement
- [ ] **Données personnelles** : RGPD si utilisateurs EU
- [ ] **Contenus générés** : Responsabilité utilisateur

## 📅 Timeline estimé

1. **Jour 1** : Compléter assets et métadonnées
2. **Jour 2** : Tests intensifs et corrections
3. **Jour 3** : Soumission Play Console
4. **Jour 4-7** : Review Google (durée variable)
5. **Jour 8** : Publication (si approuvé)

## 🚨 En cas de refus

### Raisons courantes
- Screenshots de mauvaise qualité
- Description pas assez claire
- Permissions non justifiées
- Crash au lancement
- Non-conformité politique contenu

### Actions
1. Corriger le problème identifié
2. Incrémenter version (1.0.1+2)
3. Rebuild et resoumission
4. Réponse détaillée si nécessaire

---

## 📞 Contacts et ressources

- **Play Console** : https://play.google.com/console
- **Documentation** : https://developer.android.com/distribute/
- **Support** : https://support.google.com/googleplay/android-developer/

## 🎯 Objectifs post-lancement

- [ ] Monitoring des crashs (Firebase Crashlytics)
- [ ] Analytics d'usage (Firebase Analytics)  
- [ ] Feedback utilisateurs
- [ ] Updates régulières
- [ ] Marketing et ASO (App Store Optimization)