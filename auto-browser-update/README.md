# auto-browser-update

Keeps Brave Browser and Google Chrome current on macOS using a daily launchd agent.

## Files

| File | Purpose |
|---|---|
| `update-browsers.sh` | Update script (uses Homebrew; falls back to Google Software Update) |
| `com.user.update-browsers.plist` | launchd agent — runs daily at 9:00 AM |

## Setup

1. Copy `update-browsers.sh` to your home directory and make it executable:
   ```bash
   cp update-browsers.sh ~/update-browsers.sh
   chmod +x ~/update-browsers.sh
   ```

2. Copy the plist to your LaunchAgents folder and load it:
   ```bash
   cp com.user.update-browsers.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.user.update-browsers.plist
   ```

## Verification

```bash
# Confirm the agent is registered
launchctl list | grep update-browsers

# Watch the log
tail -f ~/Library/Logs/update-browsers.log
```
