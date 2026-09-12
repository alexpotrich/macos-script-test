#!/bin/bash

TARGET="$1"

# Vérifie qu'on est bien dans un runner GitHub Actions
if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERREUR : GITHUB_WORKSPACE absent."
    exit 1
fi

# Sécurité : n'accepte que le dossier work-data
EXPECTED_TARGET="$GITHUB_WORKSPACE/work-data"

if [ "$TARGET" != "$EXPECTED_TARGET" ]; then
    echo "ERREUR : cible refusée."
    echo "Cible reçue   : $TARGET"
    echo "Cible attendue: $EXPECTED_TARGET"
    exit 1
fi

CORRUPT_SCRIPT="$TARGET/test1/corruption/corrupt.sh"

# Vérifie que corrupt.sh existe
if [ ! -f "$CORRUPT_SCRIPT" ]; then
    echo "ERREUR : corrupt.sh introuvable."
    echo "Chemin attendu : $CORRUPT_SCRIPT"
    exit 1
fi

echo "=========================================="
echo "LANCEMENT DU SCRIPT DE TEST"
echo "=========================================="
echo "Script : $CORRUPT_SCRIPT"
echo ""

# Lance corrupt.sh avec Bash.
# Pas besoin que corrupt.sh ait le bit executable.
 /bin/bash "$CORRUPT_SCRIPT" "$TARGET"
