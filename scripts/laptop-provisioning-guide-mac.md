# Provisioning a New FLL Team Laptop (macOS)

A guide for any coach setting up a donated **Mac** laptop for a Bolton
Robotics FLL team. Start with **Quick Start** below. If anything's
unclear, the **Detailed Steps** section that follows expands every line
with specifics.

> For Windows laptops, use the sibling guide:
> [laptop-provisioning-guide.md](laptop-provisioning-guide.md). The two
> scripts and docs are intentionally parallel -- same nine sections,
> same prompts, same outcome.

## Quick Start

The major steps, in order. The script does the heavy lifting -- most of
these are short:

1. **Team email** -- `fss.fll.<TeamNumber>@gmail.com` or `@outlook.com`. Create one if the team doesn't have it.
2. **Team GitHub** -- a `fssfll<TeamNumber>` user with a fork of `stevenerat/spike_basecode`. Create and fork if needed.
3. **Download** `setup-fll-laptop-mac.sh` from the chapter upstream to the new laptop (e.g., to `Downloads`).
4. **Open Terminal** and run:

   ```bash
   cd ~/Downloads
   chmod +x setup-fll-laptop-mac.sh
   ./setup-fll-laptop-mac.sh <TeamNumber>
   ```

5. **Follow the prompts** when the script asks -- confirm new-team data if it's a new team, enter the admin password when it asks for sudo, then complete the GitHub Desktop sign-in and clone during the script's pause partway through.
6. **Verify** -- repo cloned to `~/repos/spike_basecode/`, VS Code opens it with the `.venv` interpreter, and a test program runs on a SPIKE Prime hub.
7. **Drag shortcuts to the Dock** from the Desktop .command files the script created.

That's the whole flow -- typically 30 to 60 minutes, mostly waiting on
downloads. If the list above makes sense, you're ready to go.

For prerequisites, specific URLs, the new-team interactive prompts, and
gotchas, continue to **Detailed Steps** below.

## Detailed Steps

This section expands each Quick Start step with the URLs, edge cases,
and decisions you'll encounter.

One framing note up front: the setup script must be downloaded as a
standalone `.sh` file before anything else, because a freshly-wiped
laptop doesn't have Git, GitHub Desktop, Homebrew, or any other chapter
tooling yet. The script itself is what installs them (including
Homebrew). You can't clone the repo first.

### Prerequisites

Before you start the laptop itself:

- A donated laptop running **macOS 12 (Monterey) or later**. Intel and Apple Silicon both work.
- The laptop's local user account has **admin privileges** (confirm with the donor -- check System Settings > Users & Groups; the account should say "Admin")
- The user is **not** signed in to iCloud with a coach's personal Apple ID. Either no iCloud, or signed in with the team's Apple ID if one exists. (Not required, but avoids accidental syncing of team work to a personal account.)
- Apple's **Command Line Tools** are not pre-installed -- the script will trigger their install via Homebrew, which pops a GUI prompt the first time. Just click Install and let it finish before continuing.
- A reliable internet connection
- The team's email and GitHub credentials (or willingness to create them -- see Step 1 and Step 2)
- About an hour of uninterrupted time

### 1. Set up a team email account (if one does not already exist)

Chapter standard format: `fss.fll.<TeamNumber>@gmail.com` or
`fss.fll.<TeamNumber>@outlook.com`. Either provider is acceptable. Gmail
is preferred when feasible because it integrates with Chrome sign-in;
Outlook is the fallback when Gmail signup is blocked.

This email becomes the team's identity for GitHub, commits, and any
chapter communications. Don't reuse a coach's personal email.

### 2. Set up a team GitHub account (if one does not already exist)

Chapter standard username: `fssfll<TeamNumber>` (e.g. `fssfll27041`).

The account needs to have a fork of `stevenerat/spike_basecode`. If the
team is new, sign in as the team's GitHub user and click **Fork** at
`https://github.com/stevenerat/spike_basecode`.

2FA is optional -- the chapter has only enabled it for teams with a
security-conscious lead coach. Decide based on who will be using the
account.

### 3. Download the setup script to the laptop

You'll download `setup-fll-laptop-mac.sh` as a standalone file. Open the
file on GitHub, click the **Raw** button, then in Safari/Chrome use
**File > Save Page As** (or right-click the Raw link and choose
**Download Linked File As**) and save it to `Downloads`. This is the
bootstrap: the script can't be cloned because nothing on the laptop
knows how to clone yet.

The two cases below differ only in whether you sync the team's fork first.

#### 3a. New team -- download from upstream

Go to `https://github.com/stevenerat/spike_basecode/tree/main/scripts/`,
open `setup-fll-laptop-mac.sh`, click **Raw**, and save. This is the
chapter's source of truth for the script.

#### 3b. Existing team -- sync the fork first, then download

If the team already has a fork (e.g., this laptop is replacing an old
one), the fork may be behind upstream. Before downloading the script:

1. Go to `https://github.com/fssfll<TeamNumber>/spike_basecode`
2. If GitHub shows "This branch is N commits behind", click **Sync fork**
3. Then download `setup-fll-laptop-mac.sh` from the team's fork (or from
   upstream -- either is fine once the fork is synced)

Syncing the fork first ensures the cloned repo the script lands on the
laptop will have the latest chapter code, not just the latest script.

### 4. Open Terminal and run the script

1. Press **Cmd+Space** to open Spotlight, type `Terminal`, and press Enter.
2. Make the script executable and run it with the team number:

   ```bash
   cd ~/Downloads
   chmod +x setup-fll-laptop-mac.sh
   ./setup-fll-laptop-mac.sh 27041
   ```

   Replace `27041` with the actual team number. If you omit the number,
   the script will show a menu of known teams and prompt for one.

3. **Do NOT run with `sudo`.** The script refuses to run as root. It
   will prompt for the admin password once near the start (for the
   power-management step) and cache the credential for the rest of the run.

4. **First run only -- Gatekeeper.** macOS may show "cannot verify the
   developer of `setup-fll-laptop-mac.sh`" the first time you try to run
   it. If you downloaded from a browser, the simplest fix is:

   ```bash
   xattr -d com.apple.quarantine setup-fll-laptop-mac.sh
   ```

   Then re-run the script. (You can also right-click the file in Finder
   and choose **Open** the first time, but for a `.sh` that's run from
   Terminal, the xattr command is faster.)

### 5. Complete prompts as the script runs

The script is mostly hands-off, but it will pause for input in a few places:

- **Sudo password**: right after the banner, you'll be prompted once for
  your macOS admin password. The cached credential covers the rest of the run.
- **Command Line Tools install** (first time only, on freshly-wiped
  laptops): Homebrew's installer triggers Apple's GUI prompt to install
  the Command Line Tools. Click Install, agree to the license, and let
  the ~5-minute install finish. The script continues automatically afterward.
- **New team setup**: if the team number is not in the script's
  known-teams list, it will ask you to confirm and prompt for the team
  email, display name, and GitHub username. Examples are shown in the prompts.
- **GitHub Desktop authentication and clone**: midway through, the
  script launches GitHub Desktop and pauses. Follow the on-screen
  instructions: sign in to GitHub as the team user, clone the fork to
  the path the script shows, and -- when asked "How are you planning to
  use this fork?" -- select **For my own purposes**, not "To contribute
  to the parent project". Press Enter in the Terminal window when the
  clone is done.

If anything goes sideways, the script is safe to re-run from the start.

### 6. Verify the setup

When the script finishes, confirm:

- The repo folder exists at `~/repos/spike_basecode/` and contains the
  chapter code (not just a `.git` folder).
- GitHub Desktop is signed in as the team user and shows the cloned repo.
- VS Code can be launched from the desktop shortcut **Open Team N
  Code.command**, and the bottom-right status bar shows a `.venv`
  Python interpreter. If not, use **Cmd+Shift+P > Python: Select
  Interpreter > .venv**.
- Opening `menu.py` in VS Code does not show "Import could not be
  resolved" on `from pybricks...` lines.
- Connect to a SPIKE Prime hub and run a test program to confirm the
  full pipeline works:

  ```bash
  python3.12 -m pybricksdev run ble --name <hub-name> main.py
  ```

### 7. Pin shortcuts to the Dock (optional)

The script creates several `.command` shortcuts on the Desktop. macOS
doesn't pin arbitrary files to the Dock the way Windows pins to the
taskbar, so the convention is slightly different:

- **For apps** (Chrome, GitHub Desktop, VS Code): open the app from
  `/Applications` or Launchpad, then **right-click the icon in the Dock
  > Options > Keep in Dock**.
- **For the team workflow shortcuts** (`Open Team N Code.command`,
  `Team N Repo Folder.command`, `Terminal (Team N).command`): drag the
  `.command` file from the Desktop into the **right side** of the Dock
  (the area between the apps and the Trash, which is for files and
  folders). It stays there until removed.

Also worth doing at this point:

- Set Chrome as the default browser: open Chrome and click **Set as
  default** on the prompt, or **System Settings > Desktop & Dock >
  Default web browser > Google Chrome**.
- Sign in to Chrome with the team email (Gmail teams only -- Chrome
  does not accept Outlook accounts).

## Notes and gotchas

**Account creation friction.** Gmail enforces a phone-number rate limit
that may block creating multiple accounts in succession; GitHub may
block account creation from `@outlook.com` addresses. If you hit
either, the chapter's workaround is to create a GitHub account using a
personal email address TEMPORARILY, and then later switch the GitHub
account's primary email to the team's permanent (Outlook or Gmail)
address and set that address as the primary email for GitHub. Then
remove the personal address.

**The script is idempotent.** If anything fails partway through,
re-running the script from the start is the recommended fix.
Already-installed software, existing configs, and an existing clone
will all be detected and skipped.

**Apple Silicon vs Intel.** The script handles both. Homebrew installs
to `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel; the
script picks the right one automatically. No coach action needed.

**`.command` shortcuts open a Terminal window.** When you double-click
a `.command` shortcut, macOS opens a Terminal window to run the script
and then shows `[Process completed]` after the inner command (`open
-a "Visual Studio Code" ...`) returns. That terminal window is
harmless -- close it or set **Terminal > Settings > Profiles > Shell >
When the shell exits > Close if the shell exited cleanly** so it
auto-dismisses.

**The "code" CLI is not on PATH by default.** Homebrew installs VS Code
but does not symlink the `code` command into `/usr/local/bin`. The
script invokes it via the full path inside the app bundle, so this
doesn't matter for setup. If a coach later wants to run `code` from
Terminal, open VS Code, press **Cmd+Shift+P**, and run **Shell
Command: Install 'code' command in PATH**.

**Smart quotes / dashes / auto-correct.** The script disables these
GLOBALLY in macOS because they rewrite typed characters in any text
field -- including Terminal, GitHub Desktop's commit message box, and
filenames. This is the single biggest source of "why won't my code
run" frustration on Mac. If a team specifically wants them back, they
can be toggled in **System Settings > Keyboard > Text Input > Edit**.

**Where to find help.** The script is at
`https://github.com/stevenerat/spike_basecode/blob/main/scripts/setup-fll-laptop-mac.sh`.
For chapter-specific questions, contact Steve. For technical questions
about a specific failure mode, capture the Terminal output and send it
along.
