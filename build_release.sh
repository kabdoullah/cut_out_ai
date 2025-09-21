#!/bin/bash

# Script de build pour Play Store - CutOut AI
# Auteur: Claude Code Assistant

echo "🚀 Début du build de production CutOut AI..."

# Nettoyage
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupération des dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Build de l'App Bundle
echo "🔨 Création de l'App Bundle pour Play Store..."
flutter build appbundle --release

# Vérification du build
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo "✅ Build réussi !"
    echo "📁 Fichier AAB créé : build/app/outputs/bundle/release/app-release.aab"
    
    # Afficher la taille du fichier
    size=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    echo "📊 Taille de l'AAB : $size"
    
    echo ""
    echo "🎯 Étapes suivantes :"
    echo "1. Télécharger le fichier AAB vers la Play Console"
    echo "2. Configurer les métadonnées de l'app"
    echo "3. Ajouter les screenshots et assets"
    echo "4. Soumettre pour review"
    
else
    echo "❌ Erreur : Build échoué"
    exit 1
fi

echo ""
echo "🎉 Script terminé avec succès !"