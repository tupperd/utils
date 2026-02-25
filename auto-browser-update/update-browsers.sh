#!/bin/bash
# update-browsers.sh — Keep Brave and Chrome up to date via Homebrew

LOG="$HOME/Library/Logs/update-browsers.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $*" | tee -a "$LOG"
}

log "=== Browser update started ==="

if command -v brew &>/dev/null; then
    log "Homebrew found — running brew upgrade --cask"
    brew upgrade --cask google-chrome brave-browser 2>&1 | while IFS= read -r line; do
        echo "[$TIMESTAMP] $line" >> "$LOG"
    done
    STATUS=${PIPESTATUS[0]}
    if [ "$STATUS" -eq 0 ]; then
        log "brew upgrade completed successfully"
    else
        log "brew upgrade exited with status $STATUS (may mean already up to date)"
    fi
else
    log "Homebrew not found — falling back to Google Software Update for Chrome"
    GSU="/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/GoogleSoftwareUpdate"
    if [ -x "$GSU" ]; then
        "$GSU" --check-and-update 2>&1 | while IFS= read -r line; do
            echo "[$TIMESTAMP] $line" >> "$LOG"
        done
        log "Google Software Update finished"
    else
        log "Google Software Update daemon not found — Chrome may need a manual update"
    fi
    log "WARNING: Brave Browser requires Homebrew or a manual download to update automatically"
fi

log "=== Browser update finished ==="
