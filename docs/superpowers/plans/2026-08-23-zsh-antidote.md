# Zsh + Antidote Migration (mise-managed) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move zsh config + antidote (plugin manager) from home-manager/nix management to mise-managed dotfiles: `[bootstrap.repos]` clones this dotfiles repo AND antidote; `.zshrc`/`.zprofile`/`.zshenv` become mise `[dotfiles]` entries; `[bootstrap.mise_shell_activate]` handles activation; nix's `programs.zsh` is disabled.

**Architecture:** This is Stage 3's most-involved piece (the zsh/antidote migration). Design decision: **Option A — `[bootstrap.repos]` manages both repos**:
- `[bootstrap.repos]` clones this dotfiles repo (`~/projects/dotfiles` → git AlinaNova21/dotfiles) and antidote (`~/.antidote` → mattmc3/antidote) before dotfiles apply (bootstrap step 8 → step 9).
- `.zshrc` becomes a repo file (mise dotfile, mirror → `~/.zshrc` = `repo/.zshrc`), sourcing `~/.antidote/antidote.zsh`.
- `[bootstrap.mise_shell_activate] zshrc = "activate"` writes/keeps the `mise activate zsh` block.
- nix `programs.zsh` disabled; the existing plugin list (.zsh_plugins.txt) carries over verbatim.

**Tech Stack:** mise 2026.8.6 (`/usr/bin/mise`, pacman), `[bootstrap.repos]`, `[dotfiles]`, `[bootstrap.mise_shell_activate]`, antidote (git, mattmc3), zsh. Nix/home-manager only for the disable step.

**Spec:** `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` (Stage 3 zsh portion + Stage 4).
**Prior commit:** `3083d07` (Stage 2 done: desktop dotfiles moved).

---

## File Structure

Created/modified in this plan:

- Modify: `.config/mise/config.toml` — add `[bootstrap.repos]` (this repo + antidote), `[dotfiles]` entries for `.zshenv`/`.zprofile`/`.zshrc` (and `.zlogout`/`.zsh_plugins.txt`), `[bootstrap.mise_shell_activate]`.
- Create: `.zshenv` — minimal env (PATH, mise activate for all shells).
- Create: `.zprofile` — login-shell fpath/source, login-shell mise (interim).
- Create: `.zshrc` — history opts, bindkeys, starship, direnv hook, aliases, zdotdir plugins, antidote load (`.zsh_plugins.txt` + static deferred load pattern).
- Create: `.zsh_plugins.txt` — the antidote plugin list (carried verbatim from `zsh.nix` antidote.plugins).
- Create: `.zlogout` — optional cleanup on logout exit.
- Create: `.zsh_plugins` (generated static file cache; gitignored; antidote `bundle < .txt > .zsh` pattern).
- Modify: `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` — mark Stage 3 progress.
- Modify: `modules/home/shell/zsh.nix` — disable `programs.zsh` (nix no longer generates .zshrc or antidote); retain commented for rollback.

### Key paths/conventions (verified)
- `~/.dotfiles → repo (the dotfiles root symlink created in Stage 1; `~/.dotfiles` has the dot, NOT `~/dotfiles`).
- Repo `.config/mise/config.toml` is the self-managed global config (via `~/.config/mise` → repo `.config/mise` symlink).
- `[dotfiles]` mirror-style sources resolve via `dotfiles.root` → `~/.dotfiles/.config/<name>` ... wait: `.zshrc` target is at HOME root, NOT `.config/`. So its dotfile entry is `"~/.zshrc" = {}` → `~/.dotfiles/.zshrc` (mirror style from dotfiles.root). Correct: zsh rc files live at repo ROOT and mirror to HOME root.

## Task 1: Author `[bootstrap.repos]` (this repo + antidote) in `.config/mise/config.toml`

**Files:**
- Modify: `.config/mise/config.toml`

- [ ] **Step 1: verify current [dotfiles] block location/key style in config.toml**

Run:
```bash
cat .config/mise/config.toml
```
Expected: `[settings]` (dotfiles.root/`~/.dotfiles`), `[dotfiles]` block (root symlink, mise self-manage, desktop dirs), `[tools]` (herdr, pi, usage).

- [ ] **Step 2: add `[bootstrap.repos]` section**

Append after the `[dotfiles]` block (before `[tools]`), with this repo + antidote:
```toml
[bootstrap.repos]
# The dotfiles repo itself (this repo) — cloned on fresh machines before dotfiles apply.
"~/projects/dotfiles" = { url = "git@github.com:AlinaNova21/dotfiles.git", ref = "main" }
# antidote (zsh plugin manager) — cloned before dotfiles apply so .zshrc can source it.
"~/.antidote" = { url = "git@github.com:mattmc3/antidote.git", ref = "main" }
```
Notes:
- `ref = "main"` for both (current default branches, verified).
- On THIS machine both repos already exist:
  - `~/projects/dotfiles` → the working repo (already correct origin).
  - `~/.antidote` → needs cloning (does not exist yet). Applying `[bootstrap.repos]` will clone it (a write — the user runs `mise bootstrap repos apply`).
- Mise repo semantics: existing repos with matching origin+ref are left alone (idempotent); missing ones get cloned.

- [ ] **Step 3: verify config parses**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config >/dev/null 2>&1 && echo "parse OK"
```
Expected: parse OK (no TOML error).

- [ ] **Step 4: dry-run repos apply (plan mode — do NOT create the clone yet)**

Run:
```bash
/usr/bin/mise bootstrap repos apply --dry-run
```
Expected: prints the clone actions (this repo + antidote) or reports current/missing. Nothing changed yet (dry-run). This confirms the config is right before you run the real apply.

- [ ] **Step 5: commit**

```bash
git add .config/mise/config.toml
git commit -m "feat: declare bootstrap repos (dotfiles repo + antidote)"
```

## Task 2: Clone antidote + this repo via repos apply (user action)

**Files:** none (runs `mise bootstrap repos apply` — a write; user-driven)

- [ ] **Step 1: user runs the repos apply**

Run (from repo root):
```bash
mise bootstrap repos apply
```
Expected: clones `~/.antidote` (#if missing) and confirms `~/projects/dotfiles` is current. This makes `~/.antidote/antidote.zsh` available for `.zshrc` to source.

- [ ] **Step 2: verify antidote clone**

Run: `ls ~/.antidote/antidote.zsh ~/.antidote/functions/ 2>&1 | head -4`
Expected: `antidote.zsh` + `functions/` present (upstream repo layout).

- [ ] **Step 3: verify this repo repo status**

Run: `/usr/bin/mise bootstrap repos status 2>&1 | grep -E "dotfiles|antidote"`
Expected: both `current` (this repo current; antidote freshly cloned).

## Task 3: Author the repo zsh rc files (.zshenv, .zprofile, .zshrc, .zlogout)

**Files:**
- Create: `.zshenv` (repo root)
- Create: `.zprofile` (repo root)
- Create: `.zshrc` (repo root)
- Create: `.zlogout` (repo root)

These live at the **repo root** (mirroring `~/.zshenv` etc. via dotfiles.root).

- [ ] **Step 1: create `.zshenv`**

Content:
```zsh
# Sourced for ALL zsh invocations (interactive, login, non-login, scripts).
# Keep minimal: PATH only. mise activation is via [bootstrap.mise_shell_activate]
# in .zshrc (mise-native), NOT here.
typeset -U path cdpath fpath manpath
path=("$HOME/.local/bin" $path)
```
Notes:
- `.zshenv` is sourced first everywhere; keep it PATH-only (decided: activation lives in
  [bootstrap.mise_shell_activate] / .zshrc, mise-native).
- Keep PATH minimal here; .zprofile handles login-shell fpath.

- [ ] **Step 2: create `.zprofile`**

Content:
```zsh
# Sourced for LOGIN shells (e.g. terminal emulator login + ssh).
# fpath / completion setup, plus login-shell-specific init.
typeset -U path cdpath fpath manpath

# zsh function path + completions (compinit autoload).
autoload -Uz compinit && compinit -i
```
Notes:
- `.zshrc` also calls compinit (for non-login interactives); `compinit -i` is idempotent-safe.
- fpath from nix profiles is intentionally dropped — we're moving off nix.

- [ ] **Step 3: create `.zshrc`**

Content (replaces the nix-generated rc):
```zsh
# Sourced for every INTERACTIVE zsh shell. Main user config.
# mise activation + tool integrations (starship/direnv/zoxide) are appended by mise as blocks.
# antidote loads directly here (base content).

# History options
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST

# Bindings
bindkey '^[[A' history-search-backward # Up
bindkey '^[[B' history-search-forward  # Down

# Completion (for interactive non-login zsh)
autoload -Uz compinit && compinit -i

# Antidote loads DIRECTLY here (base content, copy-mode .zshrc) — not a separate block.
# starship/direnv/zoxide are APPENDED as mise-managed blocks on demand.

# Aliases
alias -- cat=bat
alias -- ls=eza
alias -- ll='eza -l'
alias -- la='eza -a'
alias -- lla='eza -la'
alias -- lt='eza --tree'
alias -- vimdiff='nvim -d'

# --- antidote (zsh plugin manager) ---
# Static deferred load (fast): generate .zsh_plugins.zsh once, source it
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
[[ ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]] || {
  ( source ~/.antidote/antidote.zsh
    antidote bundle < ${zsh_plugins}.txt > ${zsh_plugins}.zsh )
}
source ${zsh_plugins}.zsh
```
Notes:
- **Tool integrations as mise edit-blocks** (starship/direnv/zoxide) — declared via `[dotfiles]`
  edit entries in Task 5; mise inserts them between markers in the live `.zshrc`. No guards.
- **fnm line removed** (node is mise).
- **nix-index command-not-found dropped** (per spec open item 5).
- The **antidote static load** is the documented high-performance pattern.

- [ ] **Step 4: create `.zlogout`**

Content:
```zsh
# Sourced on zsh exit (login shells).
# (optional — nothing needed yet; exists for future logout hooks)
```

- [ ] **Step 5: add the `[dotfiles]` entries for rc files**

In `.config/mise/config.toml` `[dotfiles]` block, append:
```toml
# zsh rc files (mise-managed)
"~/.zshenv" = {}
"~/.zprofile" = {}
# .zshrc is COPY-mode (real file) so [dotfiles] edit blocks can manage tool sections inside it
"~/.zshrc" = { source = ".zshrc", mode = "copy" }
"~/.zlogout" = {}
```
Notes:
- Sources are the repo-root files (`.zshenv` etc. we just created), reached via `dotfiles.root = "~/.dotfiles"` → `repo/.zshenv` etc.
- `.zshrc` uses `copy` mode (NOT symlink) so the activation + starship/direnv/zoxide edit blocks (Task 5) can insert into a REAL file — docs warn edits through a symlink would write to the repo source.
- `.zsh_plugins.txt` is NOT a dotfile entry (it's a source, loaded by .zshrc; it lives in the repo, reachable at `~/.dotfiles/.zsh_plugins.txt`).

- [ ] **Step 6: verify config parses**

Run: `MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config >/dev/null && echo OK`
Expected: OK.

- [ ] **Step 7: verify rc file sources resolve (no source missing) BEFORE applying**

Run:
```bash
/usr/bin/mise bootstrap dotfiles status 2>&1 | grep -E "\.zshenv|\.zprofile|\.zshrc|\.zlogout"
```
Expected: entries listed with resolved source `~/.dotfiles/.zshrc` etc., status `missing` (target ~/.zshrc exists as nix symlink → will need force/disabled-first) or `differs`.

- [ ] **Step 8: commit**

```bash
git add .zshenv .zprofile .zshrc .zlogout .config/mise/config.toml
git commit -m "feat: author mise-managed zsh rc files + dotfiles entries"
```

## Task 4: `.zsh_plugins.txt` (antidote plugin list)

**Files:**
- Create: `.zsh_plugins.txt` (repo root)

- [ ] **Step 1: create the plugin list file**

Exactly the plugins from `modules/home/shell/zsh.nix` `antidote.plugins` (verified list, carried verbatim):
```
mattmc3/zephyr path:plugins/color
mattmc3/zephyr path:plugins/completion
mattmc3/zephyr path:plugins/history
mattmc3/zephyr path:plugins/utility
mattmc3/zfunctions
zsh-users/zsh-autosuggestions
zdharma-continuum/fast-syntax-highlighting kind:defer
zsh-users/zsh-history-substring-search
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/kubectl
ohmyzsh/ohmyzsh path:plugins/kubectx
ohmyzsh/ohmyzsh path:plugins/lol
ohmyzsh/ohmyzsh path:plugins/node
ohmyzsh/ohmyzsh path:plugins/nvm
ohmyzsh/ohmyzsh path:plugins/sudo
Aloxaf/fzf-tab
```

- [ ] **Step 2: gitignore the generated static file**

Append to root `.gitignore`:
```gitignore
# generated by antidote bundle (static plugin load cache)
.zsh_plugins.zsh
```

- [ ] **Step 3: commit**

```bash
git add .zsh_plugins.txt .gitignore
git commit -m "feat: add zsh plugin list (antidote) in repo"
```

## Task 5: Tool-integration `[dotfiles]` edit blocks + `[bootstrap.mise_shell_activate]`

**Files:**
- Modify: `.config/mise/config.toml`

- [ ] **Step 1: add `[dotfiles]` EDIT-block entries for tool integrations**

In `.config/mise/config.toml` `[dotfiles]` block, add edit entries for tools that emit a
`.zshrc` section (mise uses marker blocks in the live `~/.zshrc`):
```toml
[dotfiles]
# Tool-integration blocks mise-manages INSIDE the real ~/.zshrc (marker-delimited):
"~/.zshrc/starship" = { block = 'eval "$(starship init zsh)"' }
"~/.zshrc/direnv" = { block = 'eval "$(direnv hook zsh)"' }
"~/.zshrc/zoxide" = { block = 'eval "$(zoxide init zsh --cmd cd)"' }
```
Notes:
- These are **edit entries**, keyed `target/id` (`~/.zshrc/starship` = file/id). Each writes a
  marker-delimited block in the real `.zshrc` (`# >>> mise:starship >>>` ... `# <<< mise:starship <<<`),
  managed by mise. Ids may contain letters/digits/_/-/. — `starship`/`direnv`/`zoxide` are valid.
- **They target the real `~/.zshrc`** (an edit entry). Since our `~/.zshrc` is itself a mise symlink
  to `repo/.zshrc`, the docs warn: "an edit through a symlink would modify whatever the link points
  at — point the edit at the real file instead." So either (a) `~/.zshrc` must be a REAL file (not a
  symlink) when edit blocks target it, OR (b) the blocks go into the repo's `.zshrc` source. **Decision
  needed in Task 7** — prefer (a): make `~/.zshrc` a `copy` mode dotfile (real file) so edit blocks
  can manage the tool sections inside it, while the base `.zshrc` content comes from the repo.

- [ ] **Step 2: add the shell-activation section**

Append to `.config/mise/config.toml`:
```toml
[bootstrap.mise_shell_activate]
zshrc = "activate"
```
Notes:
- Writes/keeps `eval "$(mise activate zsh)"` in `.zshrc` — the mise-native activation mechanism.
- **Decision (user): prefer mise-native.** The `.zshenv` activation drafted in Task 3 is dropped; `.zshenv` becomes PATH-only. `[bootstrap.mise_shell_activate]` handles activation in `.zshrc`. (Revisit later ONLY if non-login/non-interactive shells need mise tools.)

- [ ] **Step 3: commit**

```bash
git add .config/mise/config.toml
git commit -m "feat: manage mise shell activation + tool-integration blocks via bootstrap"
```

## Task 6: Disable nix `programs.zsh` (the nix side cleanup)

**Files:**
- Modify: `modules/home/shell/zsh.nix`

- [ ] **Step 1: disable programs.zsh generation (comment out), keep acme.zsh option**

Replace the `config = mkIf cfg.enable { ... }` body's `programs.zsh = { ... };` (enable/antidote/initContent) with a disabled comment, retaining the option:
```nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.acme.zsh;
in
with lib; {
  options.acme.zsh = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh shell with plugins and integrations";
    };
  };
  config = mkIf cfg.enable {
    # DISABLED (mise migration): zsh config (.zshrc, plugs, antidote) is now
    # managed by mise [dotfiles] + [bootstrap.repos] (antidote) + shell activation.
    # programs.zsh = { ... };  # (whole nix-generated block commented out)
  };
}
```
Note: Keep `acme.zsh.enable` option defined (inert) — host configs may reference it. Full block commented, not deleted (reversible).

- [ ] **Step 2: nixfmt + commit**

Run: `nixfmt modules/home/shell/zsh.nix`
Commit:
```bash
git add modules/home/shell/zsh.nix
git commit -m "feat(hm): disable programs.zsh — zsh+antidote now mise-managed"
```

- [ ] **Step 3 (user): home-manager switch**

Run: `home-manager switch --flake '.#alina@alina-desktop'`
Expected: nix stops generating `.zshrc` (removes the nix-store `.zshrc` symlink + antidote from profile path). The `.zshrc` symlink disappears; mise's `.zshrc` dotfile entry can then take over.

## Task 7: Apply zsh dotfiles + validate (user-driven, with dry-run first)

**Files:** none (runs `mise bootstrap dotfiles apply`)

- [ ] **Step 1: pre-apply dry-run to confirm the plan (no changes)**

Run (from repo root):
```bash
/usr/bin/mise bootstrap dotfiles apply --dry-run
```
Expected: prints planned symlinks for `.zshenv`/`.zprofile`/`.zshrc`/`.zlogout` + the desktop dirs. No changes (dry-run).

- [ ] **Step 2: .zshrc conflict check — nix symlink must be gone first**

After Task 6's `home-manager switch`, confirm `~/.zshrc` is no longer a nix symlink:
```bash
ls -l ~/.zshrc
```
Expected: absent (nix cleared it) or dangling; if still a real/hm file, use `--force` on apply.

- [ ] **Step 3: real apply**

Run:
```bash
mise bootstrap dotfiles apply
```
Expected: creates `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.zlogout` symlinks → `~/.dotfiles/<name>`.

- [ ] **Step 4: verify status**

Run: `mise bootstrap dotfiles status 2>&1 | grep -E "\.zshenv|\.zprofile|\.zshrc|\.zlogout"`
Expected: all `applied`.

- [ ] **Step 5: activation + `.zshrc`-mode decisions (resolved: mise-native)**

- **Activation:** USE `[bootstrap.mise_shell_activate] zshrc = "activate"` (mise-native). `.zshenv` is
  PATH-only. One activation source in `.zshrc` (mise-managed block).
- **`.zshrc` mode for edit blocks:** The `[dotfiles]` edit entries in Task 5 target the real
  `~/.zshrc`. Since our `~/.zshrc` is itself a mise symlink (to repo `.zshrc`), edits through the
  symlink would write into the repo source (docs: "point the edit at the real file instead").
  **Resolution: make `~/.zshrc` a `copy`-mode dotfile** (`"~/.zshrc" = { source = ".zshrc", mode = "copy" }`)
  so it's a REAL file — mise copies the repo `.zshrc` content on apply, and the activation/starship/
  direnv/zoxide edit blocks insert into that real file. Base content stays in the repo; tool sections
  are manage-able markers. (Asymmetric with the other rc files' symlink mode — acceptable; `.zshrc`
  is the one file needing in-place edits.)

- [ ] **Step 6: verify a fresh zsh shell loads**

Run: `zsh -i -c "echo loaded: ${commands[starship]:-no-starship}; echo plugins-active: $(whence -w antidote 2>/dev/null)"`  (or just open a new zsh)
Expected: no zsh errors; starship/direnv/zoxide present (mise tools active); plugins loaded via antidote static file.

## Task 8: Finalize activation strategy + full zsh validation from a clean shell

**Files:**
- Possibly Modify: `.zshenv` (remove activation) OR `.config/mise/config.toml` (remove `[bootstrap.mise_shell_activate]`) — per Task 7 Step 5 decision.

- [ ] **Step 1: confirm the mise-native activation strategy** (decided in Task 7 Step 5)

Confirm in practice:
- `.zshenv` is PATH-only (no activation eval).
- `config.toml` has `[bootstrap.mise_shell_activate] zshrc = "activate"`.
- `~/.zshrc` is a `copy`-mode dotfile (real file), and its starship/direnv/zoxide/activate marker
  blocks are managed by mise. Verify by inspecting `~/.zshrc` for the marker blocks after apply.
If `.zshenv`-activation is ever needed for non-login scripts later, add it then (not now).

- [ ] **Step 2: verify with a truly fresh login shell**

Run:
```bash
env -i HOME="$HOME" /usr/bin/zsh -i -c 'echo PATH-ok; command -v mise; command -v starship; whence -w antidote'
```
(NOTE: `env -i` drops env — may break; alternative is `zsh -i -c 'command -v mise'` from a fresh terminal.)
Expected: `mise`, `starship` on PATH; `antidote` function active; no zsh startup errors.

- [ ] **Step 3: commit any final strategy change + finalize**

```bash
git add .zshenv .config/mise/config.toml
git commit -m "feat(zsh): finalize mise-managed activation strategy"
```

- [ ] **Step 4: update spec Stage 3/4 progress**

Edit `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md`: note zsh+antidote migrated (Stage 3 zsh portion + Stage 4 done), activation via [bootstrap.mise_shell_activate] (or .zshenv), antidote via [bootstrap.repos]. Commit.

## Task 9: Full migration consistency check

**Files:** none (verification)

- [ ] **Step 1: nix no longer owns any zsh/antidote file**

Run: `grep -rn "antidote\|programs.zsh" ~/.zshrc modules/home/shell/zsh.nix 2>/dev/null | head`
Expected: only the mise-managed `.zshrc` references `~/.antidote`; no nix store path.

- [ ] **Step 2: dotfiles fully applied**

Run: `mise bootstrap dotfiles status 2>&1 | grep -c applied`
Expected: all configured entries `applied`.

- [ ] **Step 3: repo self-managed via [bootstrap.repos]**

Run: `mise bootstrap repos status 2>&1 | grep -E "dotfiles|antidote"`
Expected: both `current`. This confirms bootstrap manages this repo (side-note the user raised) + antidote.

- [ ] **Step 4: record in memory + summary**

Summary of what's mise-managed now: desktop dotfiles (Stage 2), zsh rc files + antidote + activation (this plan). Remaining: Stage 3 other generated configs (starship/git/tmux/htop), further program migration (Stage 5).

---

## Deferred (not in this plan)

- **Stage 3 remainder** — starship.toml, git config, tmux, jujutsu, htop, user-dirs, electron-flags, hyfetch → repo files + dotfiles. Planned separately when ready.
- **Stage 5** — programs → [tools]/[bootstrap.packages] (age/sops done already; kubernetes/neovim done).
- **Stage 6/7** — fresh bootstrap prove-out; cross-platform.
- Completions: `mise completion zsh` + tool completions to be folded into `.zshrc`/compinit as part of Stage 3 remainder (side-note; not blocking this zsh plan).

## Success criteria

- `[bootstrap.repos]` declares the dotfiles repo + antidote; both clone/are-current on fresh machines (bootstrap step 8 → step 9).
- `.zshenv`/`.zprofile`/`.zshrc`/`.zlogout` are repo files, mise `[dotfiles]` entries, applied as symlinks to `~`.
- `.zsh_plugins.txt` carries the full prior plugin list; `.zshrc` loads plugins via the antidote static deferred pattern from `~/.antidote`.
- nix `programs.zsh` disabled; no nix-store path in `.zshrc`.
- Activation via `[bootstrap.mise_shell_activate] zshrc = "activate"` (mise-native); `.zshenv` PATH-only. Antidote loads in `.zshrc` base content; starship/direnv/zoxide appended as mise-managed blocks.
- A fresh zsh loads: mise tools on PATH, antidote plugins active, no startup errors.
- `mise bootstrap repos status` shows both repos `current`.