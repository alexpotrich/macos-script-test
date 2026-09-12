#!/bin/bash

TARGET="$1"

# Vérifie qu'on est bien dans GitHub Actions
if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERREUR : GITHUB_WORKSPACE absent."
    exit 1
fi

# Sécurité : on n'accepte que work-data
EXPECTED_TARGET="$GITHUB_WORKSPACE/work-data"

if [ "$TARGET" != "$EXPECTED_TARGET" ]; then
    echo "ERREUR : cible refusée."
    echo "Cible reçue   : $TARGET"
    echo "Cible attendue: $EXPECTED_TARGET"
    exit 1
fi

TEST_DIR="$TARGET/test1"

if [ ! -d "$TEST_DIR" ]; then
    echo "ERREUR : dossier test1 introuvable."
    exit 1
fi

# Chemin absolu de ce script
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

echo "=========================================="
echo "TRONCATURE DES FICHIERS"
echo "=========================================="
echo "Cible       : $TEST_DIR"
echo "Script exclu: $SELF"
echo ""

SUCCESS=0
FAILED=0
SKIPPED=0

while IFS= read -r -d '' FILE
do

    # Ne jamais modifier corrupt.sh lui-même
    if [ "$FILE" = "$SELF" ]; then
        echo "IGNORE : $FILE"
        echo "Raison : script courant"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Tronque le fichier à 0 octet
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
echo "RESULTAT"
echo "=========================================="
echo "Fichiers tronqués : $SUCCESS"
echo "Échecs             : $FAILED"
echo "Fichiers exclus    : $SKIPPED"
echo "=========================================="
