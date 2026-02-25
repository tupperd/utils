# Auto Browser Update — Context

## Problem
Kolide (device management) was blocking access because Brave Browser and Google Chrome were out of date. A nightly automated update script was built to keep both browsers current.

## Solution
Two files make up the solution:

- **`update-browsers.sh`** — update script run by launchd
- **`com.user.update-browsers.plist`** — launchd agent that schedules the script

## How It Works
1. Runs daily at **2:00 AM** via launchd
2. Uses **Homebrew** (`brew upgrade --cask`) to update each browser individually
3. If a browser is running when the script fires, it is **quit and relaunched** so the new version takes effect
4. **`caffeinate`** holds a sleep assertion for the duration of the script so the machine can't sleep mid-update
5. Each run writes a **timestamped log** to `./execution-logs/YYYY-MM-DD_HH-MM-SS.log` and ends with `RESULT: SUCCESS` or `RESULT: FAILED`
6. The system-level log is also appended to `~/Library/Logs/update-browsers.log`

## Sleep / Wake Behaviour
- The launchd agent will **not** wake a sleeping machine — it only fires if the machine is already awake
- The setting **"Prevent automatic sleeping on power adapter when the display is off"** (System Settings → Battery, currently ON) keeps the machine awake when on the charger, so the 2 AM trigger will fire reliably
- The Battery → Schedule wake option (to wake a sleeping machine at a set time) was removed in macOS Ventura and is no longer available
- `caffeinate` ensures the machine stays awake for the duration of the script once it starts

## Browser Installation
Chrome and Brave were originally installed directly from the web, meaning `brew upgrade` had nothing to manage and updates were not actually being applied. Both browsers were **reinstalled via Homebrew Cask** so the script has full control:

```bash
brew install --cask google-chrome brave-browser
```

Browser profiles (bookmarks, passwords, extensions) are stored in `~/Library/Application Support/` and were unaffected by the reinstall.

## Kolide Compatibility
Kolide checks browser versions from the **app bundle** (`Info.plist → CFBundleShortVersionString`), not from Homebrew. As long as the app bundle is current, Kolide is satisfied regardless of how the update was delivered.

## Setup (one-time)
```bash
chmod +x ~/playground/utils/auto-browser-update/update-browsers.sh
cp ~/playground/utils/auto-browser-update/com.user.update-browsers.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.update-browsers.plist
```

A symlink also exists at `~/.local/bin/update-browsers` so the script can be run on demand from any terminal:
```bash
update-browsers
```

## Repository
- **GitHub:** https://github.com/tupperd/utils (under the `tupperd` account)
- **Local:** `~/playground/utils/`
- `execution-logs/` is excluded from git via `.gitignore`
