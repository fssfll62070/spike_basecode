# Provisioning a New FLL Team Laptop (Linux / Fedora 42)

A guide for any coach setting up a donated **Linux** laptop for a
Bolton Robotics FLL team. Start with **Quick Start** below. If
anything's unclear, the **Detailed Steps** section that follows
expands every line with specifics.

> For Windows laptops use [laptop-provisioning-guide.md](laptop-provisioning-guide.md);
> for macOS use [laptop-provisioning-guide-mac.md](laptop-provisioning-guide-mac.md).
> The three scripts and docs are intentionally parallel -- same nine
> sections, same prompts, same outcome.

> **One note about GitHub Desktop on Linux:** the official GitHub
> Desktop has no Linux build, but a community fork by `shiftkey`
> tracks upstream closely and is functionally identical. The chapter
> uses it via Flatpak (`io.github.shiftey.Desktop` from Flathub) so
> kids on Linux teams have the same UX as Windows/macOS teams.

## Quick Start

The major steps, in order. The script does the heavy lifting -- most
of these are short:

1. **Team email** -- `fss.fll.<TeamNumber>@gmail.com` or `@outlook.com`. Create one if the team doesn't have it.
2. **Team GitHub** -- a `fssfll<TeamNumber>` user with a fork of `stevenerat/spike_basecode`. Create and fork if needed.
3. **Download** `setup-fll-laptop-linux.sh` from the chapter upstream to the new laptop (e.g., to `Downloads`).
4. **Open a terminal** and run:

   ```bash
   cd ~/Downloads
   chmod +x setup-fll-laptop-linux.sh
   ./setup-fll-laptop-linux.sh <TeamNumber>
   ```

5. **Follow the prompts** -- confirm new-team data if it's a new team, enter the sudo password when asked, then complete the GitHub Desktop sign-in and clone during the script's pause partway through (same flow as the Windows/macOS scripts).
6. **Verify** -- repo cloned to `~/repos/spike_basecode/`, VS Code opens it with the `.venv` interpreter, and a test program runs on a SPIKE Prime hub.
7. **Pin shortcuts to the dash** by pressing **Super**, typing "Open Team", right-clicking each launcher, and choosing **Add to Favorites**.

That's the whole flow -- typically 30 to 60 minutes, mostly waiting on
package downloads. If the list above makes sense, you're ready to go.

## Detailed Steps

This section expands each Quick Start step with the URLs, edge cases,
and decisions you'll encounter.

One framing note up front: the setup script must be downloaded as a
standalone `.sh` file before anything else, because a freshly-installed
laptop doesn't have the Microsoft VS Code repo, the Google Chrome
repo, or any chapter tooling yet. The script itself is what installs
them. You can't clone the repo first.

### Prerequisites

Before you start the laptop itself:

- A donated laptop running **Fedora 42** (GNOME 48 / Wayland is the tested config). Older Fedora releases or RHEL-family kin should work; Debian/Ubuntu will need the `dnf install` lines adapted to `apt`.
- The user account is in the **`wheel` group** (can run `sudo`). Confirm with `groups | grep -q wheel` -- if it's missing, an existing admin must run `sudo usermod -aG wheel <user>` and log the user out/in.
- The laptop is reasonably up to date. If it's been idle for months, run `sudo dnf upgrade --refresh` separately before starting the provisioning script.
- A reliable internet connection.
- The team's email and GitHub credentials (or willingness to create them -- see Step 1 and Step 2).
- About an hour of uninterrupted time (allow extra if Fedora updates are needed first).

### 1. Set up a team email account (if one does not already exist)

Chapter standard format: `fss.fll.<TeamNumber>@gmail.com` or
`fss.fll.<TeamNumber>@outlook.com`. Either provider is acceptable.
Gmail is preferred when feasible because it integrates with Chrome
sign-in; Outlook is the fallback when Gmail signup is blocked.

This email becomes the team's identity for GitHub, commits, and any
chapter communications. Don't reuse a coach's personal email.

### 2. Set up a team GitHub account (if one does not already exist)

Chapter standard username: `fssfll<TeamNumber>` (e.g. `fssfll27041`).

The account needs to have a fork of `stevenerat/spike_basecode`. If
the team is new, sign in as the team's GitHub user and click **Fork**
at `https://github.com/stevenerat/spike_basecode`.

2FA is optional. If the team account has 2FA enabled, GitHub Desktop's
sign-in flow in Section 8 handles it correctly via the browser-based
device-code flow.

### 3. Download the setup script to the laptop

You'll download `setup-fll-laptop-linux.sh` as a standalone file. Open
the file on GitHub, click the **Raw** button, then save the page
(Firefox: **Ctrl+S**; or right-click the Raw link and pick **Save Link
As**). Save it to `~/Downloads`.

The two cases below differ only in whether you sync the team's fork
first.

#### 3a. New team -- download from upstream

Go to `https://github.com/stevenerat/spike_basecode/tree/main/scripts/`,
open `setup-fll-laptop-linux.sh`, click **Raw**, and save.

#### 3b. Existing team -- sync the fork first, then download

If the team already has a fork (e.g., this laptop is replacing an old
one), the fork may be behind upstream. Before downloading the script:

1. Go to `https://github.com/fssfll<TeamNumber>/spike_basecode`
2. If GitHub shows "This branch is N commits behind", click **Sync fork**
3. Then download `setup-fll-laptop-linux.sh` from the team's fork (or from upstream -- either is fine once the fork is synced)

### 4. Open a terminal and run the script

1. Press **Super** (the Windows key), type `Terminal`, and press Enter. On Fedora 42 GNOME this opens **Ptyxis** (the new GNOME Console replacement) or a fallback like `gnome-terminal`.
2. Make the script executable and run it with the team number:

   ```bash
   cd ~/Downloads
   chmod +x setup-fll-laptop-linux.sh
   ./setup-fll-laptop-linux.sh 27041
   ```

   Replace `27041` with the actual team number. If you omit the number, the script will show a menu of known teams and prompt for one.

3. **Do NOT run with `sudo`.** The script refuses to run as root. It will prompt for the admin password once near the start (for `dnf` package installs) and cache the credential for the rest of the run.

### 5. Complete prompts as the script runs

The script is mostly hands-off, but it will pause for input in a few
places:

- **Sudo password**: right after the banner, you'll be prompted once for your Linux user password. The cached credential covers the rest of the run.
- **dnf RPM key prompts** (first time only): when installing Chrome and the Microsoft VS Code repo, dnf may ask you to confirm the GPG key fingerprint. Answer `y` to import.
- **New team setup**: if the team number is not in the script's known-teams list, it will ask you to confirm and prompt for the team email, display name, and GitHub username. Examples are shown in the prompts.
- **GitHub Desktop authentication and clone**: midway through, the script launches GitHub Desktop (the shiftkey Flatpak fork) and pauses. Follow the on-screen instructions: sign in to GitHub as the team user (`fssfll<TeamNumber>`), clone the fork to the path the script shows, and -- when asked "How are you planning to use this fork?" -- select **For my own purposes**, NOT "To contribute to the parent project". Press Enter in the terminal window when the clone is done.

If anything goes sideways, the script is safe to re-run from the
start. Already-installed packages, existing config files, and an
existing clone will all be detected and skipped.

### 6. Verify the setup

When the script finishes, confirm:

- The repo folder exists at `~/repos/spike_basecode/` and contains the chapter code (not just a `.git` folder).
- GitHub Desktop is signed in as the team user and shows the cloned repo.
- VS Code can be launched from **Activities** by typing "Open Team N Code", and the bottom-right status bar shows a `.venv` Python interpreter. If not, use **Ctrl+Shift+P > Python: Select Interpreter > .venv**.
- Opening `menu.py` in VS Code does not show "Import could not be resolved" on `from pybricks...` lines.
- Connect to a SPIKE Prime hub and run a test program to confirm the full pipeline works:

  ```bash
  python3.12 -m pybricksdev run ble --name <hub-name> main.py
  ```

### 7. Pin shortcuts to the dash / make them easy to find

Modern GNOME (Fedora 42 ships GNOME 48) hides desktop icons by default
and centers discovery on the **Activities overview**. The script
installs four launchers in **both** `~/.local/share/applications/`
(so they show up in Activities) **and** `~/Desktop/` (visible only if
the **Desktop Icons NG** extension is enabled):

- `Open Team N Code` -- launches VS Code on the repo
- `Team N Repo Folder` -- opens the folder in Files
- `Terminal (Team N)` -- spawns a terminal sitting in the repo folder (used for `pybricksdev`)
- `GitHub Desktop` -- launches the shiftkey Flatpak fork

The recommended workflow on GNOME:

1. Press **Super**, type **Open Team** or **GitHub Desktop** -- the launchers appear.
2. Right-click each one and pick **Add to Favorites** to pin them to the dash on the left edge.
3. (Optional) If you want desktop icons, install the **Desktop Icons NG (DING)** GNOME Shell extension via `https://extensions.gnome.org/`. The script has already set the `metadata::trusted` attribute on the `.desktop` files so DING will treat them as launchers rather than text.

Also worth doing at this point:

- The script has already set Chrome as the default web browser via `xdg-settings`. Verify in **Settings > Default Applications > Web** -- it should say Google Chrome.
- Sign in to Chrome with the team email (Gmail teams only -- Chrome does not accept Outlook accounts).

## Daily workflow

Linux teams use **GitHub Desktop** (shiftkey Flatpak fork), the same
as Windows/macOS chapter teams. The UI is identical to the official
build:

- **Get the latest code:** click **Fetch origin**, then **Pull origin** if updates appear.
- **Save changes:** review the diff under the **Changes** tab, type a summary at the bottom-left, click **Commit to main**, then **Push origin**.
- **Pull chapter updates:** visit `https://github.com/fssfll<TeamNumber>/spike_basecode` in the browser, click **Sync fork** if it shows behind, then **Fetch origin** + **Pull origin** in Desktop.

For running code on the hub, use the **Terminal (Team N)** launcher,
which opens a shell in the repo folder:

```bash
python3.12 -m pybricksdev run ble --name <hub-name> main.py
```

Authentication is handled inside GitHub Desktop: the team's PAT (or
the device-code token from the first-run browser flow) is stored by
the app in the system secret store (GNOME Keyring). Git CLI usage
(for coaches) uses an 8-hour in-memory credential cache configured in
`.gitconfig` -- short enough to be safe, long enough to avoid
constant re-prompting.

### CLI fallback for technical coaches

If a coach needs to drop to the command line:

```bash
git pull                              # team-mates' changes
git add . && git commit -m "..." && git push

git fetch upstream                    # chapter updates
git merge --ff-only upstream/main
git push origin main

python3.12 -m pybricksdev run ble --name <hub-name> main.py
```

These produce the same end state as the equivalent GitHub Desktop
operations. The first `git push` of a session will prompt for the
GitHub PAT; it'll then be cached for 8 hours.

## Notes and gotchas

**Account creation friction.** Gmail enforces a phone-number rate
limit that may block creating multiple accounts in succession; GitHub
may block account creation from `@outlook.com` addresses. If you hit
either, the chapter's workaround is to create a GitHub account using
a personal email address TEMPORARILY, and then later switch the
GitHub account's primary email to the team's permanent (Outlook or
Gmail) address and set that as the primary. Then remove the personal
address.

**The script is idempotent.** If anything fails partway through,
re-running the script from the start is the recommended fix.
Already-installed packages, existing configs, an existing GitHub
Desktop Flatpak, and an existing clone will all be detected and
skipped.

**GitHub Desktop is the shiftkey Flatpak fork.** The official GitHub
Desktop has no Linux build, so the chapter standardizes on the
community fork `io.github.shiftey.Desktop` from Flathub. It tracks
upstream closely and is functionally identical for the operations
kids care about (clone, fetch, commit, push, sync fork). Flatpak runs
the app in a sandbox -- file access is limited to a few well-known
paths, including `~/repos`, which is where the script puts the clone.

**Flathub remote.** The script adds Flathub at the user level
(`flatpak remote-add --user`). On a stock Fedora Workstation that
already enables Flathub system-wide this is a harmless duplicate; on
a minimal install it ensures the GitHub Desktop install will resolve
without separate setup.

**Microsoft VS Code repo and telemetry.** The script adds the
official Microsoft RPM repo to install VS Code. VS Code telemetry is
turned off in the user settings (`telemetry.telemetryLevel: off`),
but the Microsoft repo itself still phones home for update checks.
This is consistent with how VS Code is installed on Windows/macOS.

**SELinux.** The script does NOT modify SELinux policies. All
operations are within the user's home directory or use standard
package managers that are SELinux-aware. If SELinux is enforcing
(default on Fedora) and a step fails with a permission denial, check
`/var/log/audit/audit.log` -- but this should not happen with the
operations the script performs.

**Distro portability.** The script targets dnf-based distros (Fedora,
RHEL, CentOS Stream). On Debian/Ubuntu the Section 1 dnf calls would
need to be swapped for `apt` and the Microsoft/Google repos
configured the apt way. The other eight sections (gsettings, VS Code
settings, Flatpak, GitHub Desktop, git, venv) are distro-agnostic
and would still apply.

**Where to find help.** The script is at
`https://github.com/stevenerat/spike_basecode/blob/main/scripts/setup-fll-laptop-linux.sh`.
For chapter-specific questions, contact Steve. For technical
questions about a specific failure mode, capture the terminal output
and send it along.
