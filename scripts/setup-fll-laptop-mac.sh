#!/usr/bin/env bash
# =============================================================================
# setup-fll-laptop-mac.sh
#
# SYNOPSIS
#   Standardized setup script for Bolton Robotics FLL chapter laptops -- macOS.
#
# DESCRIPTION
#   Run this script ONCE per donated laptop, while logged in as the
#   student team account (which has admin privileges).
#
#   Pass the team number as the first argument, or run with no arguments
#   to see the team menu and be prompted.
#
#   The script:
#     1. Installs Homebrew (if missing) and core software (Git, Python 3.12,
#        VS Code, Chrome, GitHub Desktop) via brew
#     2. Writes a chapter-standard .gitconfig to the user's home directory
#     3. Installs VS Code extensions and configures user settings
#     4. Notes that Chrome must be set as default browser manually
#     5. Applies a light set of macOS "quiet" defaults (show file extensions,
#        disable smart quotes/dashes/auto-correct so they don't mangle code)
#     6. Configures power management (don't sleep aggressively on AC)
#     7. Creates the team's repo folder, .command shortcuts, and Desktop README
#     8. Launches GitHub Desktop and pauses for the user to authenticate and
#        clone the fork
#     9. Configures the cloned repo: upstream remote, Python venv,
#        pybricks + pybricksdev packages, VS Code workspace settings
#
#   What it does NOT do (these are interactive, do them manually after):
#     - Sign in to Chrome with the team Gmail (Chrome requires a Google
#       account; outlook.com teams skip this step)
#     - Set Chrome as default browser (macOS requires user confirmation)
#     - Install the Pybricks firmware on the SPIKE Prime hub
#     - Pin shortcuts to the Dock (drag from the Desktop to the Dock)
#
#   NEW TEAM SUPPORT
#     If the team number is not in the known-teams list, the script will
#     prompt for the team's email, display name, and GitHub username. No
#     script edit needed to set up a new team. You can optionally add the
#     team to the known-teams list afterward so it appears in the menu
#     next time.
#
# NOTES
#   Author:   Steven Erat with Claude (Bolton Robotics chapter)
#   Audience: FLL chapter coaches provisioning team laptops on macOS
#   Tested on: macOS Sonoma (14) and Sequoia (15), Apple Silicon and Intel
#
#   Run from Terminal:
#       chmod +x setup-fll-laptop-mac.sh
#       ./setup-fll-laptop-mac.sh 27041
# =============================================================================

set -eo pipefail

# -----------------------------------------------------------------------------
# Color helpers (ANSI escapes; rendered by Terminal.app)
# -----------------------------------------------------------------------------
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
GRAY='\033[90m'
WHITE='\033[97m'
RESET='\033[0m'

cecho() { printf "%b%s%b\n" "$1" "$2" "$RESET"; }

# =============================================================================
# TEAM SELECTION
# =============================================================================

# Known chapter teams. To add a team to the menu, add cases to the three
# functions below. Otherwise, enter the team number at the prompt and the
# script will collect the team's email, name, and GitHub username
# interactively.

team_is_known() {
    case "$1" in
        18300|19991|27041|27042|62070) return 0 ;;
        *) return 1 ;;
    esac
}

team_default_name() {
    case "$1" in
        27041) echo "Thought Process" ;;
        *)     echo "" ;;
    esac
}

team_default_email() {
    case "$1" in
        18300) echo "fss.fll.18300@outlook.com" ;;
        19991) echo "fss.fll.19991@outlook.com" ;;
        27041) echo "fss.fll.27041@gmail.com"   ;;
        27042) echo "fss.fll.27042@gmail.com"   ;;
        62070) echo "fss.fll.62070@outlook.com" ;;
        *)     echo "" ;;
    esac
}

TEAM_NUMBER="${1:-}"

# Show menu if no team number was passed on the command line
if [[ -z "$TEAM_NUMBER" ]]; then
    echo
    cecho "$CYAN" "Bolton Robotics FLL -- known teams:"
    for t in 18300 19991 27041 27042 62070; do
        name="$(team_default_name "$t")"
        [[ -z "$name" ]] && name="(unnamed)"
        echo "  $t  $name"
    done
    echo "  (or enter any other 5-digit number for a new team)"
    echo
    read -r -p "Enter team number for this laptop: " TEAM_NUMBER
fi

# If team is unknown, collect details interactively
if ! team_is_known "$TEAM_NUMBER"; then
    echo
    cecho "$YELLOW" "Team $TEAM_NUMBER is NOT in the known teams list."
    cecho "$YELLOW" "This will set up the laptop as a NEW team."
    cecho "$YELLOW" "(If you meant an existing team, this is a good moment to check for a typo.)"
    read -r -p "Continue setup for new team $TEAM_NUMBER? (Y/n) " confirm
    if [[ -n "$confirm" && ! "$confirm" =~ ^[Yy] ]]; then
        cecho "$RED" "Cancelled. Run the script again with the correct team number."
        exit 1
    fi

    echo
    cecho "$CYAN" "Enter team email."
    cecho "$CYAN" "Chapter standard format examples (do not press Enter to accept -- type the actual email):"
    cecho "$GRAY" "  fss.fll.${TEAM_NUMBER}@gmail.com"
    cecho "$GRAY" "  fss.fll.${TEAM_NUMBER}@outlook.com"
    read -r -p "Team email: " NEW_EMAIL
    while [[ -z "$NEW_EMAIL" || "$NEW_EMAIL" != *"@"* ]]; do
        cecho "$YELLOW" "Email is required and must contain '@'."
        read -r -p "Team email: " NEW_EMAIL
    done

    echo
    read -r -p "Team display name (optional; press Enter to skip): " NEW_NAME

    echo
    DEFAULT_GH_USER="fssfll$TEAM_NUMBER"
    read -r -p "GitHub username (press Enter for '$DEFAULT_GH_USER'): " NEW_GH_USER
    [[ -z "$NEW_GH_USER" ]] && NEW_GH_USER="$DEFAULT_GH_USER"

    TEAM_NAME="$NEW_NAME"
    TEAM_EMAIL="$NEW_EMAIL"
    GITHUB_USER="$NEW_GH_USER"
else
    TEAM_NAME="$(team_default_name "$TEAM_NUMBER")"
    TEAM_EMAIL="$(team_default_email "$TEAM_NUMBER")"
    GITHUB_USER="fssfll$TEAM_NUMBER"
fi

# Resolve final values
[[ -z "$TEAM_NAME" ]] && TEAM_NAME="Bolton Robotics Team $TEAM_NUMBER"

GIT_USER_NAME="Bolton Robotics FLL Team $TEAM_NUMBER"  # Shows up in commit history
GIT_USER_EMAIL="$TEAM_EMAIL"                           # Per-team email (gmail or outlook)
FORK_URL="https://github.com/$GITHUB_USER/spike_basecode.git"
UPSTREAM_URL="https://github.com/stevenerat/spike_basecode.git"

# Local paths
REPOS_ROOT="$HOME/repos"
REPO_PATH="$REPOS_ROOT/spike_basecode"
DESKTOP_PATH="$HOME/Desktop"
GIT_CONFIG_PATH="$HOME/.gitconfig"

# =============================================================================
# PRELIMINARIES
# =============================================================================

# macOS-only sanity check
if [[ "$(uname -s)" != "Darwin" ]]; then
    cecho "$RED" "This script targets macOS. Detected: $(uname -s)"
    cecho "$RED" "For Windows, use scripts/setup-fll-laptop.ps1 instead."
    exit 1
fi

# Refuse to run as root: brew will not install as root, and we want
# user-owned files in $HOME. The script will prompt for sudo just for the
# few commands that require it.
if [[ "$EUID" -eq 0 ]]; then
    cecho "$RED" "Do NOT run this script with sudo or as root."
    cecho "$RED" "Run as the student/team user. You'll be prompted for the admin password when needed."
    exit 1
fi

echo
cecho "$CYAN" "==============================================================="
cecho "$CYAN" " FLL Laptop Setup (macOS) -- Team $TEAM_NUMBER ($TEAM_NAME)"
cecho "$CYAN" " Email:  $TEAM_EMAIL"
cecho "$CYAN" " GitHub: $GITHUB_USER"
cecho "$CYAN" "==============================================================="
echo

# Pre-cache sudo credentials so later prompts don't interrupt long brew
# installs. Keep-alive refreshes the timestamp until this script exits.
cecho "$GRAY" "This script needs sudo for power-management settings. You may be prompted now."
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
echo

# =============================================================================
# 1. SOFTWARE INSTALLATION VIA HOMEBREW
# =============================================================================

cecho "$YELLOW" "[1/9] Installing core software via Homebrew..."

# Install Homebrew if missing. The official installer is non-interactive
# when NONINTERACTIVE=1 is set (it still uses the cached sudo above for
# the /usr/local or /opt/homebrew bootstrap step).
if ! command -v brew >/dev/null 2>&1; then
    cecho "$GRAY" "  Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    cecho "$GRAY" "  Homebrew already installed."
fi

# Make sure brew is on PATH for the rest of this script.
# Apple Silicon: /opt/homebrew. Intel: /usr/local.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    cecho "$RED" "Homebrew install appears to have failed. Check the output above."
    exit 1
fi

# Formulas (CLI tools)
brew_formulas=("git" "python@3.12")
for pkg in "${brew_formulas[@]}"; do
    cecho "$GRAY" "  Installing $pkg..."
    brew install "$pkg" || cecho "$YELLOW" "  Warning: brew reported issues installing $pkg. Continuing."
done

# Casks (GUI apps)
brew_casks=(
    "visual-studio-code"
    "google-chrome"
    "github"            # GitHub Desktop
)
for cask in "${brew_casks[@]}"; do
    cecho "$GRAY" "  Installing $cask (cask)..."
    brew install --cask "$cask" || cecho "$YELLOW" "  Warning: brew reported issues installing $cask. Continuing."
done

# Make `python3.12` and `code` resolvable for the rest of the script.
# brew symlinks python3.12 into its bin; VS Code CLI lives inside the app
# bundle and needs to be invoked by full path (we don't symlink it into
# /usr/local/bin to avoid sudo on Intel; users can run "Shell Command:
# Install 'code' command in PATH" from inside VS Code later).
PYTHON_BIN="$(command -v python3.12 || true)"
if [[ -z "$PYTHON_BIN" ]]; then
    # Fall back to brew's prefix
    BREW_PREFIX="$(brew --prefix)"
    PYTHON_BIN="$BREW_PREFIX/opt/python@3.12/bin/python3.12"
fi

CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

cecho "$GREEN" "  Software install complete."
echo

# =============================================================================
# 2. GIT CONFIGURATION (.gitconfig)
# =============================================================================

cecho "$YELLOW" "[2/9] Writing chapter-standard .gitconfig..."

# Adapted from Steve's Mac .gitconfig with chapter-standard additions:
#   - credential.helper = osxkeychain (macOS Keychain for GitHub auth)
#   - core.autocrlf = false: the repo's .gitattributes drives EOL behavior
#     (`* text=auto eol=lf` plus `*.bat eol=crlf`). Setting autocrlf
#     alongside it causes phantom diffs and conflicting rules. Same choice
#     as on Windows; only the credential helper differs.
#   - Added init.defaultBranch, pull.rebase
#
# Re-running this script OVERWRITES the .gitconfig file -- any manual
# edits will be lost.

cat > "$GIT_CONFIG_PATH" <<EOF
# ~/.gitconfig -- FLL chapter laptop (macOS)
# Generated by setup-fll-laptop-mac.sh -- re-running the script overwrites this file.

[user]
    name = $GIT_USER_NAME
    email = $GIT_USER_EMAIL

[init]
    defaultBranch = main

[pull]
    rebase = false                   # Default to merge on pull, not rebase

[credential]
    helper = osxkeychain             # macOS Keychain for GitHub auth

[color]
    ui = auto

[color "status"]
    added = green
    changed = yellow
    untracked = red

[color "diff"]
    meta = cyan
    frag = magenta
    old = red
    new = green

[color "branch"]
    current = yellow bold
    local = green
    remote = cyan

[core]
    editor = code --wait             # VS Code as default editor
    pager = less -FRSX               # Better pager
    autocrlf = false                 # .gitattributes drives EOL behavior; don't double up

[help]
    autocorrect = 20                 # Auto-run corrected commands after 2 sec

[merge]
    conflictstyle = diff3            # Show base version during conflicts

[blame]
    coloring = highlightRecent

[diff]
    tool = vimdiff

[difftool]
    prompt = false

[alias]
    st = status -sb
    lg = log --graph --decorate --oneline --all
    lga = log --graph --decorate --pretty=oneline --abbrev-commit --all
    undo = reset --soft HEAD~1
EOF

cecho "$GREEN" "  .gitconfig written to $GIT_CONFIG_PATH"
cecho "$GREEN" "  Configured for $GIT_USER_NAME <$GIT_USER_EMAIL>."
echo

# =============================================================================
# 3. VS CODE EXTENSIONS AND USER SETTINGS
# =============================================================================

cecho "$YELLOW" "[3/9] Installing VS Code extensions and configuring user settings..."

# Note: ms-vscode.powershell intentionally NOT included.
# Steve is the only chapter coach who edits PowerShell, and he's on a Mac
# already. The extension also stalled during install on a slow network
# during the 5-laptop run -- reliability risk with zero educational value.
vscode_extensions=(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "eamodio.gitlens"
)

if [[ -x "$CODE_BIN" ]]; then
    for ext in "${vscode_extensions[@]}"; do
        cecho "$GRAY" "  Installing extension: $ext"
        "$CODE_BIN" --install-extension "$ext" --force >/dev/null
    done
else
    cecho "$YELLOW" "  VS Code 'code' CLI not found at $CODE_BIN -- skipping extension install."
    cecho "$YELLOW" "  After VS Code launches, run 'Shell Command: Install code command in PATH' and re-run this script."
fi

# Configure VS Code USER settings (apply to all workspaces).
# Workspace settings (per-repo, including the venv interpreter) are
# written in Section 9 after the repo is cloned.
VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
VSCODE_SETTINGS_PATH="$VSCODE_SETTINGS_DIR/settings.json"

mkdir -p "$VSCODE_SETTINGS_DIR"

cat > "$VSCODE_SETTINGS_PATH" <<'EOF'
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "editor.formatOnSave": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "telemetry.telemetryLevel": "off",
    "update.showReleaseNotes": false,
    "workbench.startupEditor": "none",
    "explorer.confirmDragAndDrop": false
}
EOF

cecho "$GREEN" "  VS Code configured."
echo

# =============================================================================
# 4. BROWSER DEFAULTS
# =============================================================================

cecho "$YELLOW" "[4/9] Configuring browser defaults..."

# Setting Chrome as default browser on macOS cannot be done silently --
# macOS shows a confirmation prompt the first time a non-Apple browser
# tries to register as default. We prompt the user instead.
cecho "$CYAN" "  NOTE: Setting Chrome as default browser must be done manually."
cecho "$CYAN" "        After this script finishes, open Google Chrome and click"
cecho "$CYAN" "        'Set as default' on the prompt that appears, or go to"
cecho "$CYAN" "        System Settings > Desktop & Dock > Default web browser."

# There's no "Edge in the Dock" equivalent to remove on macOS -- Safari
# is the built-in browser and Apple doesn't allow scripted Dock changes
# for system apps. Skip.

cecho "$GREEN" "  Browser defaults note printed."
echo

# =============================================================================
# 5. QUIET MACOS -- TYPING DEFAULTS THAT HURT CODE
# =============================================================================

cecho "$YELLOW" "[5/9] Quieting macOS defaults that interfere with code..."

# Show all file extensions in Finder -- otherwise kids see "menu" instead
# of "menu.py" and get confused about which file is which.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable smart quotes / smart dashes / auto-correct GLOBALLY. These rewrite
# typed characters in any text field, including filenames, commit messages,
# and code typed outside the VS Code editor (e.g., in Terminal). They are
# the single biggest source of "why won't my code run" frustration on Mac.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled  -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable Photos from auto-launching when an iPhone is connected
# (kids sometimes plug phones in to charge during meetings).
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

# Restart Finder so the file-extension change takes effect immediately.
killall Finder 2>/dev/null || true

cecho "$GREEN" "  macOS quieted."
echo

# =============================================================================
# 6. POWER MANAGEMENT
# =============================================================================

cecho "$YELLOW" "[6/9] Configuring power management..."

# Don't sleep aggressively while plugged in at meetings.
# -c = AC adapter (plugged in). All values in minutes; 0 = never.
sudo pmset -c sleep 60 displaysleep 30 disksleep 0

cecho "$GREEN" "  Power plan configured (AC: sleep 60min, display 30min, disk never)."
echo

# =============================================================================
# 7. REPO FOLDER, DESKTOP SHORTCUTS, README
# =============================================================================

cecho "$YELLOW" "[7/9] Creating repo folder and desktop shortcuts..."

# Create repo parent folder (clone will land here in Section 8)
mkdir -p "$REPOS_ROOT"

# Helper to write an executable .command shortcut. macOS treats files with
# the .command extension as scripts that should be opened in Terminal when
# double-clicked. The Terminal window will briefly show "[Process completed]"
# after the script exits -- that's expected and harmless.
make_command_shortcut() {
    local path="$1"
    local body="$2"
    cat > "$path" <<EOF
#!/bin/zsh
$body
EOF
    chmod +x "$path"
}

# Team-specific workflow shortcuts ------------------------------------------

make_command_shortcut \
    "$DESKTOP_PATH/Open Team $TEAM_NUMBER Code.command" \
    "open -a 'Visual Studio Code' '$REPO_PATH'"
cecho "$GRAY" "  Created shortcut: Open Team $TEAM_NUMBER Code"

make_command_shortcut \
    "$DESKTOP_PATH/Team $TEAM_NUMBER Repo Folder.command" \
    "open '$REPO_PATH'"
cecho "$GRAY" "  Created shortcut: Team $TEAM_NUMBER Repo Folder"

# Opens Terminal sitting in the repo folder with an interactive zsh.
make_command_shortcut \
    "$DESKTOP_PATH/Terminal (Team $TEAM_NUMBER).command" \
    "cd '$REPO_PATH' 2>/dev/null || cd '$HOME'
exec /bin/zsh -l"
cecho "$GRAY" "  Created shortcut: Terminal (Team $TEAM_NUMBER)"

# App launchers ------------------------------------------------------------
# macOS doesn't really do "desktop shortcuts to apps" the way Windows does;
# apps live in /Applications and are launched from Dock/Spotlight/Launchpad.
# We provide GitHub Desktop and Chrome as .command launchers anyway, for
# coach convenience and parity with the Windows script's desktop set.

make_command_shortcut \
    "$DESKTOP_PATH/GitHub Desktop.command" \
    "open -a 'GitHub Desktop'"
cecho "$GRAY" "  Created shortcut: GitHub Desktop"

make_command_shortcut \
    "$DESKTOP_PATH/Google Chrome.command" \
    "open -a 'Google Chrome'"
cecho "$GRAY" "  Created shortcut: Google Chrome"

# Desktop README -- GitHub Desktop oriented, not git CLI -------------------

cat > "$DESKTOP_PATH/README - Team $TEAM_NUMBER.txt" <<EOF
TEAM $TEAM_NUMBER - $TEAM_NAME
==========================================

YOUR CODE LIVES IN:
  $REPO_PATH

EVERYDAY WORKFLOW (use GitHub Desktop):

  Get the latest code from your team's repo:
    1. Open GitHub Desktop
    2. Click "Fetch origin" (top bar)
    3. Click "Pull origin" if updates appear

  Save your changes:
    1. Open GitHub Desktop
    2. Review changed files in the "Changes" tab
    3. Type a summary message at the bottom-left
    4. Click "Commit to main"
    5. Click "Push origin" in the top bar

  Pull chapter updates (when Steve announces changes):
    1. Go to https://github.com/$GITHUB_USER/spike_basecode
    2. If GitHub shows "This branch is N commits behind", click "Sync fork"
    3. In GitHub Desktop, click "Fetch origin" then "Pull origin"

  Run code on the SPIKE hub:
    Open Terminal (or the VS Code terminal) in the repo folder, then run:
      python3.12 -m pybricksdev run ble --name <hub-name> main.py

QUESTIONS?
  Talk to your coach, or contact Steve.

YOUR TEAM'S GITHUB:
  https://github.com/$GITHUB_USER/spike_basecode

CHAPTER UPSTREAM (where updates come from):
  $UPSTREAM_URL

NOTE FOR TECHNICAL COACHES:
  Git CLI works too. The repo has scripts/sync-from-upsteam.ps1 for
  fetching chapter updates from PowerShell (Windows) -- the equivalent
  flow on macOS is run from Terminal in the repo folder:
      git fetch upstream
      git merge --ff-only upstream/main
      git push origin main
EOF

cecho "$GREEN" "  Desktop shortcuts and README created."
echo

# =============================================================================
# 8. GITHUB DESKTOP AUTHENTICATION AND REPO CLONE (INTERACTIVE PAUSE)
# =============================================================================

cecho "$YELLOW" "[8/9] GitHub Desktop authentication and repository clone..."

if [[ -d "$REPO_PATH/.git" ]]; then
    cecho "$GRAY" "  Repository already cloned at $REPO_PATH -- skipping clone step."
else
    if [[ -d "/Applications/GitHub Desktop.app" ]]; then
        open -a "GitHub Desktop"
        cecho "$GRAY" "  GitHub Desktop launched."
    else
        cecho "$YELLOW" "  GitHub Desktop not found in /Applications -- launch it manually."
    fi

    echo
    cecho "$CYAN" "  MANUAL STEPS in GitHub Desktop:"
    cecho "$CYAN" "    1. Sign in to GitHub (if not already signed in)."
    cecho "$CYAN" "       Use the team's GitHub account: $GITHUB_USER"
    cecho "$CYAN" "    2. File > Clone Repository > URL tab"
    cecho "$CYAN" "         URL:        $FORK_URL"
    cecho "$CYAN" "         Local path: $REPO_PATH"
    cecho "$CYAN" "       Click Clone."
    cecho "$CYAN" "    3. When asked 'How are you planning to use this fork?':"
    cecho "$CYAN" "         Select 'For my own purposes'."
    cecho "$CYAN" "         Do NOT select 'To contribute to the parent project'."
    cecho "$CYAN" "         (Team repos are downstream-only; chapter updates flow one direction.)"
    echo
    read -r -p "  Press Enter after the clone is complete: " _

    if [[ ! -d "$REPO_PATH/.git" ]]; then
        echo
        cecho "$RED" "ERROR: Clone not detected at $REPO_PATH."
        echo
        cecho "$YELLOW" "If you'd rather clone from the command line, open Terminal and run:"
        cecho "$GRAY"   "  git clone $FORK_URL \"$REPO_PATH\""
        cecho "$YELLOW" "Then re-run this script -- it is safe to re-run."
        exit 1
    fi
    cecho "$GREEN" "  Clone detected at $REPO_PATH."
fi
echo

# =============================================================================
# 9. POST-CLONE REPO SETUP -- UPSTREAM, VENV, PACKAGES, WORKSPACE SETTINGS
# =============================================================================

cecho "$YELLOW" "[9/9] Configuring repo: upstream remote, Python venv, packages, VS Code workspace..."

pushd "$REPO_PATH" >/dev/null

# 9a. Add upstream remote if not configured.
#     (GitHub Desktop's "For my own purposes" choice does NOT configure upstream.)
if ! git remote | grep -q '^upstream$'; then
    git remote add upstream "$UPSTREAM_URL"
    cecho "$GRAY" "  Added upstream remote: $UPSTREAM_URL"
else
    cecho "$GRAY" "  Upstream remote already configured -- skipping."
fi

# 9b. Create .venv if not present.
VENV_PYTHON="$REPO_PATH/.venv/bin/python"
if [[ ! -x "$VENV_PYTHON" ]]; then
    cecho "$GRAY" "  Creating Python virtual environment in .venv..."
    "$PYTHON_BIN" -m venv .venv
    if [[ ! -x "$VENV_PYTHON" ]]; then
        cecho "$RED" "Failed to create .venv. Check that python3.12 is installed (try: brew reinstall python@3.12)."
        popd >/dev/null
        exit 1
    fi
else
    cecho "$GRAY" "  Python venv already exists -- skipping creation."
fi

# 9c. Upgrade pip inside the venv.
cecho "$GRAY" "  Upgrading pip in .venv..."
"$VENV_PYTHON" -m pip install --upgrade pip --quiet

# 9d. Install pybricks and pybricksdev by name (no requirements.txt;
#     these two packages are the canonical chapter dependencies).
cecho "$GRAY" "  Installing pybricks and pybricksdev..."
"$VENV_PYTHON" -m pip install pybricks pybricksdev --quiet
cecho "$GRAY" "  Packages installed."

# 9e. Write workspace .vscode/settings.json so VS Code auto-selects the venv.
WORKSPACE_SETTINGS_DIR="$REPO_PATH/.vscode"
WORKSPACE_SETTINGS_PATH="$WORKSPACE_SETTINGS_DIR/settings.json"
VENV_PYTHON_RELATIVE=".venv/bin/python"

mkdir -p "$WORKSPACE_SETTINGS_DIR"

if [[ -f "$WORKSPACE_SETTINGS_PATH" ]]; then
    # Merge: parse existing JSON, set/overwrite our key, write back.
    # Insurance against future repo PRs that add other workspace settings.
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$WORKSPACE_SETTINGS_PATH" "$VENV_PYTHON_RELATIVE" <<'PYEOF'
import json, sys
path, venv = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError("settings.json root is not an object")
except Exception as e:
    sys.stderr.write(f"Could not parse {path}: {e}\n")
    sys.exit(2)
data["python.defaultInterpreterPath"] = venv
with open(path, "w") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PYEOF
        if [[ $? -eq 0 ]]; then
            cecho "$GRAY" "  Merged python.defaultInterpreterPath into existing .vscode/settings.json"
        else
            cecho "$YELLOW" "  Could not parse existing .vscode/settings.json; leaving it untouched."
            cecho "$YELLOW" "  Set the interpreter manually in VS Code:"
            cecho "$YELLOW" "  Cmd+Shift+P -> Python: Select Interpreter -> .venv"
        fi
    else
        cecho "$YELLOW" "  python3 not available for merge; leaving existing .vscode/settings.json untouched."
    fi
else
    cat > "$WORKSPACE_SETTINGS_PATH" <<EOF
{
    "python.defaultInterpreterPath": "$VENV_PYTHON_RELATIVE"
}
EOF
    cecho "$GRAY" "  Wrote .vscode/settings.json with Python interpreter path."
fi

popd >/dev/null

cecho "$GREEN" "  Repo setup complete."
echo

# =============================================================================
# DONE
# =============================================================================

cecho "$CYAN" "==============================================================="
cecho "$CYAN" " Setup complete for Team $TEAM_NUMBER ($TEAM_NAME)"
cecho "$CYAN" "==============================================================="
echo
cecho "$YELLOW" "REMAINING MANUAL STEPS:"
cecho "$WHITE" "  1. Set Chrome as default browser:"
echo         "       Open Chrome and click 'Set as default', or"
echo         "       System Settings > Desktop & Dock > Default web browser > Google Chrome"
cecho "$WHITE" "  2. (Optional) Sign in to Chrome with $TEAM_EMAIL"
echo         "       Note: Chrome requires a Google account."
echo         "       Outlook.com teams cannot sign in to Chrome -- skip this step."
cecho "$WHITE" "  3. Pin shortcuts to the Dock (optional):"
echo         "       Drag desktop .command shortcuts or apps from /Applications to the Dock."
cecho "$WHITE" "  4. Launch VS Code via 'Open Team $TEAM_NUMBER Code' shortcut."
echo         "       Verify the venv shows in the bottom-right status bar"
echo         "       (should display '.venv': Python 3.12.x). If it doesn't:"
echo         "       Cmd+Shift+P -> Python: Select Interpreter -> .venv"
cecho "$WHITE" "  5. Open menu.py in VS Code and confirm pybricks imports do not"
echo         "       trigger 'Import could not be resolved' errors. Some type-check"
echo         "       warnings may remain depending on the repo's typing stubs;"
echo         "       runtime behavior on the hub is what matters."
cecho "$WHITE" "  6. Connect to a SPIKE Prime hub and run a test program to confirm"
echo         "       the full pipeline:"
echo         "         python3.12 -m pybricksdev run ble --name <hub-name> main.py"
echo
cecho "$GRAY" "If anything went wrong, the script is safe to re-run."
echo
