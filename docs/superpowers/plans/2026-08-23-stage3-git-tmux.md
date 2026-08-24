# Stage 3: Git + Tmux Config Migration (mise-managed dotfiles) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move git + tmux config from home-manager-generated to mise-managed dotfiles in the repo, using `.config/` paths (per user preference: avoid polluting `~/`), with git handling the work-vs-personal profile distinction.

**Architecture:**
- **tmux** → repo `.config/tmux/tmux.conf`, mise `[dotfiles]` entry (symlink), disable nix `programs.tmux`. Port the user's `extraConfig`; drop nix boilerplate + catppuccin theme. tmux = `pacman:tmux`/`brew:tmux` bootstrap package (not in mise registry).
- **git** → repo `.config/git/config` (base) + work-profile handling via git `includeIf` + a work profile file. Design options below. Disable nix `programs.git`.
- Both become mise `[dotfiles]` entries (prefer `.config/` paths per user; `~/.gitconfig` is legacy, `.config/git/config` is the modern git path).

**Tech Stack:** mise 2026.8.11 (`~/.local/bin/mise`), `[dotfiles]`, git (system, `pacman:git`), tmux (system, `pacman:tmux` to add). Nix only for disable step.

**Spec:** `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` (Stage 3: generated user configs).
**Prior state:** zsh+antidote phase complete; mise standalone at `~/.local/bin/mise`; dotfiles repo `[bootstrap.repos]` disabled until merge.

---

## Key design decisions (from user)

1. **`.config/` paths preferred** — use `~/.config/git/config` (not `~/.gitconfig`) and `~/.config/tmux/tmux.conf` (already the HM default), avoiding `~/` pollution.
2. **Git work-vs-personal — Option B (mise vars)** — dirs aren't consistent, so `includeIf` doesn't fit.
   - `.config/git/config` is a **mise-template dotfile** rendered from a repo template.
   - **mise `[vars]`**: base/default is non-work (personal: AlinaNova21 / alina@alinanova.dev). A **`.work.toml`** (or `mise.<host>.toml` / env) overrides `user.email` (e.g. work-mbp → Alina.Shumann@kyndryl.com) + the `insteadOf` for github.kyndryl.net.
   - Concretely: the git config template references `{{ vars.git_email }}` etc.; vars default to personal, and the work host/machine sets work values. (mise vars are per-config-root, non-exported — right fit.)
3. **tmux config content** — port ONLY the user's `extraConfig` (status-bg blue, C-S-Left/Right swap, prefix, mouse, etc.) + clean base; drop HM boilerplate AND the catppuccin theme (user: drop theme; tmux via `pacman:tmux`/`brew:tmux` bootstrap package — tmux not in mise registry).

---

## File Structure

Created/modified:
- Create: `.config/tmux/tmux.conf` — clean, hand-authored (base options + user extraConfig intent)
- Create: `.config/git/config` — base git config (personal identity, settings from git.nix)
- Create: `.config/git/work.toml` — work git profile (email, insteadOf) — per design decision
- Modify: `.config/mise/config.toml` — `[dotfiles]` entries for `~/.config/tmux/tmux.conf` + `~/.config/git/config` (+ work)
- Modify: `modules/home/shell/tmux.nix` — disable `programs.tmux`
- Modify: `modules/home/shell/git.nix` — disable `programs.git`
- Maybe: `modules/home/programming/direnv.nix`, `base.nix` (for git/tmux deps) — disable nix bits

## Task 1: Author `.config/tmux/tmux.conf`

**Files:**
- Create: `.config/tmux/tmux.conf`

- [ ] **Step 1: capture the user's tmux intent from current nix-generated config**

The generated was `~/.config/tmux/tmux.conf` (HM boilerplate + plugin + extraConfig). The **user-relevant** parts to port:
```tmux
# prefix C-a
unbind C-b
set -g prefix C-a
# mouse
set  -g mouse             on
setw -g aggressive-resize on
setw -g clock-mode-style  24
# base index
set  -g base-index      1
setw -g pane-base-index 1
# user extraConfig
unbind r
bind r source-file ~/.config/tmux/tmux.conf
set -g status-bg blue
set -g status-fg white
bind-key -n C-S-Left  swap-window -t -1
bind-key -n C-S-Right swap-window -t +1
# catppuccin hint (currently nix plugin; if tmux plugin moved to a TPM or dropped, note)
```
(HM default options like `default-terminal screen`, `history-limit 2000`, escape-time are housekeeping — include reasonable defaults.)

- [ ] **Step 2: write the clean `.config/tmux/tmux.conf`**

Author a clean hand-written config capturing the above (base options + user binds/status). Do NOT include the nix-store catppuccin run-shell path (drop or replace with TPM-style if wanted).

- [ ] **Step 3: verify tmux reads it**

If tmux is system-installed (`which tmux`), run `tmux -f ~/.config/tmux/tmux.conf` or `tmux list-sessions` with `-f` to sanity-check no syntax errors. (Or skip — config is simple.)

- [ ] **Step 4: commit**.

## Task 2: Author `.config/git/config` (base + work profile)

**Files:**
- Create: `.config/git/config`
- Create: `.config/git/work.toml` (or `.work.gitconfig`)

- [ ] **Step 1: design git work-profile mechanism** (decide ONE)

Option A — **git includeIf on work dir** (standard, no mise needed):
```toml
# .config/git/config
[user]
name = "AlinaNova21"
email = "alina@alinanova.dev"
[includeIf "gitdir:~/work/"]
path = work.toml
```
```toml
# .config/git/work.toml
[user]
email = "Alina.Shumann@kyndryl.com"
```

Option B — **mise env-driven template** (machine select): a mise-template dotfile renders the base config with the host's email (personal vs work), per-host via `mise.<host>.toml` env.

**Recommendation: Option A** (git-native includeIf, no mise magic; work dir `~/work/` triggers work identity + insteadOf). Simpler, standard, portable.

- [ ] **Step 2: write `.config/git/config`** (base: personal identity + settings from git.nix: push.default/autoSetupRemote, diff.nvimdiff, init.defaultBranch, ignores)

- [ ] **Step 3: write the work profile** (`work.toml` with work email + `[url "ssh://git@github.kyndryl.net/"]` insteadOf for https://github.kyndryl.net/)

- [ ] **Step 4: commit**.

## Task 3: Add `[dotfiles]` entries + disable nix git/tmux

**Files:**
- Modify: `.config/mise/config.toml`
- Modify: `modules/home/shell/tmux.nix`
- Modify: `modules/home/shell/git.nix`

- [ ] **Step 1: add dotfiles entries**
```toml
[dotfiles]
"~/.config/tmux/tmux.conf" = {}
"~/.config/git/config" = {}
"~/.config/git/work.toml" = {}
```
(mirror via `dotfiles.root` → repo `.config/tmux/tmux.conf` etc.)

- [ ] **Step 2: disable nix** — comment out `programs.tmux` in tmux.nix, `programs.git` in git.nix (keep options inert), nixfmt.

- [ ] **Step 3: commit**.

## Task 4: Verify + user switch/apply

**Files:** none (user-driven)

- [ ] **Step 1 (user):** `home-manager switch` (clears nix tmux.conf/gitconfig) then `mise bootstrap dotfiles apply`.

- [ ] **Step 2:** verify `~/.config/git/config` + work includeIf work:
```
git config --global user.email          # alina@alinanova.dev (personal)
cd ~/work/somerepo && git config user.email   # Alina.Shumann@kyndryl.com (includeIf)
```

- [ ] **Step 3:** verify tmux loads: `tmux new-session -d -f ~/.config/tmux/tmux.conf && tmux kill-server`

## Deferred (Stage 3 remainder — plan later)
- htop, jujutsu, user-dirs, electron-flags, hyfetch, nix-index → same pattern (`.config/` repo file + dotfile + disable nix).
- tmux catppuccin: decide plugin mechanism (mise tmux? TPM? drop) — not in this plan's critical path.

## Success criteria
- `~/.config/tmux/tmux.conf` + `~/.config/git/config` are mise-managed repo files (applied), no nix-store paths.
- Git work identity (includeIf) selects the right email per directory.
- nix `programs.tmux`/`programs.git` disabled; config parses; fresh shell/tmux/git work.