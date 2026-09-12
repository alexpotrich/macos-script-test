#!/bin/bash

TARGET="$1"

# Sécurité : ce script n'accepte que work-data du runner
if [ -z "$GITHUB_WORKSPACE" ] || [ "$TARGET" != "$GITHUB_WORKSPACE/work-data" ]; then
    echo "ERREUR : cible refusée"
    echo "Cible reçue : $TARGET"
    exit 1
fi

TEST_DIR="$TARGET/test1"

if [ ! -d "$TEST_DIR" ]; then
    echo "ERREUR : dossier introuvable : $TEST_DIR"
    exit 1
fi

echo "=========================================="
echo "TRONCATURE DES FICHIERS"
echo "=========================================="
echo "Cible : $TEST_DIR"
echo ""

COUNT=0

while IFS= read -r -d '' FILE
do
    : > "$FILE"

    echo "TRONQUE : $FILE"

    COUNT=$((COUNT + 1))

done < <(find "$TEST_DIR" -type f -print0)

echo ""
echo "=========================================="
echo "$COUNT fichier(s) tronqué(s) à 0 octet."
echo "=========================================="
