#!/bin/bash
# update-browsers.sh — Keep Brave and Chrome up to date via Homebrew

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXEC_LOG_DIR="$SCRIPT_DIR/execution-logs"
SYS_LOG="$HOME/Library/Logs/update-browsers.log"
RUN_TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
EXEC_LOG="$EXEC_LOG_DIR/$RUN_TIMESTAMP.log"
RESULT="SUCCESS"

mkdir -p "$EXEC_LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$SYS_LOG" "$EXEC_LOG"
}

fail() {
    RESULT="FAILED"
    log "ERROR: $*"
}

restart_browser() {
    local app="$1"
    if pgrep -xq "$app"; then
        log "$app is running — quitting for update..."
        osascript -e "tell application \"$app\" to quit" || { fail "Could not quit $app"; return; }
        sleep 3
        log "Relaunching $app..."
        open -a "$app" || fail "Could not relaunch $app"
    else
        log "$app is not running — skipping restart"
    fi
}

log "=== Browser update started ==="

# Prevent system sleep for the duration of this script
caffeinate -i -w $$ &
CAFFEINATE_PID=$!
log "caffeinate started (PID $CAFFEINATE_PID)"

if command -v brew &>/dev/null; then
    log "Homebrew found — running brew upgrade --cask"
    for CASK in google-chrome brave-browser; do
        BREW_OUT=$(brew upgrade --cask "$CASK" 2>&1)
        STATUS=$?
        echo "$BREW_OUT" | while IFS= read -r line; do
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$CASK] $line" | tee -a "$SYS_LOG" "$EXEC_LOG"
        done
        if [ "$STATUS" -eq 0 ]; then
            log "[$CASK] upgrade completed successfully"
        elif echo "$BREW_OUT" | grep -q "is not installed"; then
            log "[$CASK] not installed via Homebrew — skipping"
        else
            fail "[$CASK] upgrade failed with status $STATUS"
        fi
    done
else
    log "Homebrew not found — falling back to Google Software Update for Chrome"
    GSU="/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/GoogleSoftwareUpdate"
    if [ -x "$GSU" ]; then
        "$GSU" --check-and-update 2>&1 | while IFS= read -r line; do
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" | tee -a "$SYS_LOG" "$EXEC_LOG"
        done
        log "Google Software Update finished"
    else
        fail "Google Software Update daemon not found — Chrome may need a manual update"
    fi
    log "WARNING: Brave Browser requires Homebrew or a manual download to update automatically"
fi

restart_browser "Google Chrome"
restart_browser "Brave Browser"

kill "$CAFFEINATE_PID" 2>/dev/null
log "=== RESULT: $RESULT ==="
log "=== Log saved to: $EXEC_LOG ==="
