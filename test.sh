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

SUCCESS=0
FAILED=0

while IFS= read -r -d '' FILE
do
    if : > "$FILE" 2>/dev/null; then

        echo "TRONQUE : $FILE"
        SUCCESS=$((SUCCESS + 1))

    else

        echo "IGNORE : $FILE"
        echo "Raison : impossible d'écrire dans le fichier"
        FAILED=$((FAILED + 1))

    fi

done < <(find "$TEST_DIR" -type f -print0)

echo ""
echo "=========================================="
echo "Fichiers tronqués : $SUCCESS"
echo "Fichiers ignorés  : $FAILED"
echo "=========================================="
