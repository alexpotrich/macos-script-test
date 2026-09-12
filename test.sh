#!/bin/bash

TARGET="$1"

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
    echo "Dossier cible invalide."
    exit 1
fi

echo "Modification d'un fichier de test..."

echo "MODIFICATION TEST" >> "$TARGET/test1/texte.txt"
