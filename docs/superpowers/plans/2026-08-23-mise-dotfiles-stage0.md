# Mise Dotfiles Migration — Stage 0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare the mise environment and prove the `mise bootstrap` machinery works against the repo's `.config/mise/` as source of truth — a pure mise pilot with **zero nix changes** and **zero real dotfile changes** to `~/`.

**Architecture:** The repo (reachable as `~/projects/dotfiles` and `~/dotfiles` → repo) becomes the mise source of truth: `.config/mise/config.toml` (global-core: settings + self-managing dotfile entry) + `.config/mise/conf.d/*.toml` fragments (tools + bootstrap packages). Because the repo loads as a *project config* when cwd is inside it, mise reads it without touching the real global config. The pilot proves config loading, dotfile resolution, dry-run apply, the capture workflow, and per-host selection mechanics — all sandboxed via `MISE_DOTFILES_ROOT`, `MISE_GLOBAL_CONFIG_FILE`, dry-runs, and scratch dirs.

**Tech Stack:** mise 2026.8.6 (`/usr/bin/mise`, pacman — the one with `bootstrap`), git, TOML. Nix/home-manager is intentionally NOT touched in this stage.

**Spec:** `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` (Stage 0 section).

**Constraint — always use the pacman mise explicitly:** every command below uses `/usr/bin/mise`. The nix-shim `mise` (2026.5.12, no `bootstrap`) on PATH is intentionally bypassed; resolving the shadow happens in Stage 1. Do not shell out as plain `mise`.

**Sandbox rule:** any command that could write uses `--dry-run`, a scratch `MISE_DOTFILES_ROOT`, or a scratch `MISE_GLOBAL_CONFIG_FILE`. Never run a real `mise bootstrap dotfiles apply` (or `unapply`) in this stage — it would fight nix-managed targets at `~/.config/...`.

---

## File Structure

Created in this stage (all inside the repo unless noted):

- Create (home, outside repo): `~/dotfiles` → symlink to repo (interim `dotfiles.root` access)
- Create: `.config/mise/config.toml` — settings (`dotfiles.root`, `dotfiles.default_mode`) + `[dotfiles]` self-managing entry for `~/.config/mise`
- Create: `.config/mise/conf.d/00-local.toml` — machine-local tools (gitignored)
- Create: `.config/mise/conf.d/10-default.toml` — default CLI group (from `tools.nix`)
- Create: `.config/mise/conf.d/20-tools-go.toml` — go group
- Create: `.config/mise/conf.d/30-tools-node.toml` — node group
- Create: `.config/mise/conf.d/40-tools-kubernetes.toml` — kubernetes group
- Create: `.config/mise/conf.d/50-tools-ai.toml` — claude-code
- Create: `.config/mise/conf.d/53-tools-docker.toml` — docker group
- Create: `.config/mise/conf.d/55-tools-onepassword.toml` — onepassword group
- Create: `.config/mise/conf.d/57-tools-pulumi.toml` — pulumi group
- Create: `.config/mise/conf.d/59-tools-d2.toml` — d2 group
- Create: `.config/mise/conf.d/60-shell.toml` — shell-integration tools (starship, eza, bat, fzf, zoxide, yazi, direnv)
- Create: `.config/mise/conf.d/70-packages.toml` — `[bootstrap.packages]` per-OS (age/sops)
- Modify: `.gitignore` — ignore `.config/mise/conf.d/00-local.toml`
- Modify (spec): `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` — resolve open item 4 (per-host selection) with the probe finding

Deferred (explicitly NOT in this stage — see "Deferred follow-on stages" at end): `[dotfiles]` entries for desktop dirs (Stage 2, alongside `git mv config .config`), zsh rc files (Stage 4), `[bootstrap.repos]` (Stage 6), any nix/home-manager change (Stage 1+).

---

## Task 1: Home access symlinks

**Files:**
- Create (home, outside repo): `~/dotfiles` → repo

- [ ] **Step 1: Verify `~/projects/dotfiles` exists**

Run: `ls -ld ~/projects/dotfiles && readlink -f ~/projects/dotfiles`
Expected: a symlink resolving to `/home/alina/.config/home-manager`.

- [ ] **Step 2: Create `~/dotfiles` → repo symlink**

Run:
```bash
ln -s /home/alina/.config/home-manager ~/dotfiles
```
Expected: `~/dotfiles` resolves to the repo (this is the interim `dotfiles.root` access path; `git status` in the repo stays clean — these are home-dir symlinks, not repo files).

- [ ] **Step 3: Verify both paths resolve to the repo**

Run: `readlink -f ~/dotfiles ~/projects/dotfiles`
Expected: both print `/home/alina/.config/home-manager`.

No commit — these are home-dir artifacts, not repo content.

---

## Task 2: Repo `.config/mise/` skeleton + gitignore

**Files:**
- Create: `.config/mise/conf.d/` (empty dir — git only tracks files; create the dir and add a keep-file if needed, but fragments in later tasks populate it)
- Modify: `.gitignore`

- [ ] **Step 1: Create the skeleton dirs**

Run: `mkdir -p .config/mise/conf.d`

- [ ] **Step 2: Add gitignore entry**

Append to `.gitignore` (current contents: `home-manager`, `result`, `.direnv`, `**/.claude/`, `*.bak`, `*.bak2`, `config/noctalia/settings.json`):
```gitignore
# machine-local mise tools (not shared)
.config/mise/conf.d/00-local.toml
```

- [ ] **Step 3: Verify 00-local.toml is ignored**

Run: `git check-ignore .config/mise/conf.d/00-local.toml`
Expected: prints `.config/mise/conf.d/00-local.toml`.

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore: gitignore machine-local mise fragment"
```

---

## Task 3: Port `~/.config/mise/conf.d/00-local.toml` into the repo

**Files:**
- Create: `.config/mise/conf.d/00-local.toml`

- [ ] **Step 1: Read the live file to confirm content**

Run: `cat ~/.config/mise/conf.d/00-local.toml`
Expected:
```toml
[env]
_.path = ["~/.rokit/bin"]

[tools]
1password-cli = "latest"
bun = "latest"
"github:ogulcancelik/herdr" = "latest"
incus = "latest"
op = "latest"
pi = "latest"
pnpm = "10"

[tool_alias]
incus = "github:lxc/incus"
```

- [ ] **Step 2: Create the repo fragment with identical content**

Create `.config/mise/conf.d/00-local.toml` with exactly:
```toml
[env]
_.path = ["~/.rokit/bin"]

[tools]
1password-cli = "latest"
bun = "latest"
"github:ogulcancelik/herdr" = "latest"
incus = "latest"
op = "latest"
pi = "latest"
pnpm = "10"

[tool_alias]
incus = "github:lxc/incus"
```

- [ ] **Step 3: Verify it's gitignored (never committed)**

Run: `git status --short .config/mise/conf.d/`
Expected: 00-local.toml does NOT appear (ignored).

- [ ] **Step 4: Verify mise parses & merges it from the repo context**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config
```
Expected: output includes the repo's `.config/mise/conf.d/00-local.toml` line with `1password-cli, bun, github:ogulcancelik/herdr, incus, op, pi, pnpm`.

No commit (00-local.toml is gitignored by design). If you later edit the live `~/.../00-local.toml`, this draft is the future home; the shadow/merge is resolved in Stage 1.

---

## Task 4: Port `tools.nix` groups → conf.d fragments

**Files:**
- Create: `.config/mise/conf.d/10-default.toml`
- Create: `.config/mise/conf.d/20-tools-go.toml`
- Create: `.config/mise/conf.d/30-tools-node.toml`
- Create: `.config/mise/conf.d/40-tools-kubernetes.toml`
- Create: `.config/mise/conf.d/50-tools-ai.toml`
- Create: `.config/mise/conf.d/53-tools-docker.toml`
- Create: `.config/mise/conf.d/55-tools-onepassword.toml`
- Create: `.config/mise/conf.d/57-tools-pulumi.toml`
- Create: `.config/mise/conf.d/59-tools-d2.toml`

Each fragment has one responsibility: the exact tool group from `modules/home/tools.nix` (per-host opt-in semantics are preserved via the fragment file itself; the per-host *selection* mechanism is settled in Task 10 and applied in later stages).

- [ ] **Step 1: Create `10-default.toml`**

Content (identical to the current nix-generated `default.toml`):
```toml
[tools]
gh = "latest"
gitui = "latest"
jq = "latest"
just = "latest"
ripgrep = "latest"
yq = "latest"
```

- [ ] **Step 2: Create `20-tools-go.toml`**

```toml
[tools]
go = "latest"
golangci-lint = "latest"
gotestsum = "latest"
```

- [ ] **Step 3: Create `30-tools-node.toml`**

```toml
[tools]
node = "latest"
```

- [ ] **Step 4: Create `40-tools-kubernetes.toml`**

Content (identical to the current nix-generated `kubernetes.toml`):
```toml
[tools]
helm = "latest"
helmfile = "latest"
k9s = "latest"
krew = "latest"
kubectl = "latest"
kubectx = "latest"
kubelogin = "latest"
kustomize = "latest"
```

- [ ] **Step 5: Create `50-tools-ai.toml`**

```toml
[tools]
claude-code = "latest"
```

- [ ] **Step 6: Create `53-tools-docker.toml`**

```toml
[tools]
docker-compose = "latest"
docker-cli = "latest"
```

- [ ] **Step 7: Create `55-tools-onepassword.toml`**

```toml
[tools]
1password-cli = "latest"
```

- [ ] **Step 8: Create `57-tools-pulumi.toml`**

```toml
[tools]
pulumi = "latest"
```

- [ ] **Step 9: Create `59-tools-d2.toml`**

```toml
[tools]
d2 = "latest"
```

- [ ] **Step 10: Verify the repo config loads all fragments merged**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config
```
Expected: one line per new fragment; the tool sets match the fragments above (plus the real global `~/.config/mise/conf.d/*` lines still listed).

- [ ] **Step 11: Commit**

```bash
git add .config/mise/conf.d/
git commit -m "feat: port tools.nix groups to mise conf.d fragments"
```

---

## Task 5: Author `.config/mise/config.toml` (settings + self-managing dotfile)

**Files:**
- Create: `.config/mise/config.toml`

- [ ] **Step 1: Create the file**

Content:
```toml
# Global core config — mirrored into ~/.config/mise in Stage 1.
# Follows mise's intended dotfiles mirror layout (see docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md).
[settings]
dotfiles.root = "~/dotfiles"
dotfiles.default_mode = "symlink"

# Self-manage mise's own config dir. Source resolves via the mirror:
# ~/.config/mise -> ~/dotfiles/.config/mise -> repo .config/mise (Stage 1 applies this).
[dotfiles]
"~/.config/mise" = {}
```

Notes:
- `dotfiles.root = "~/dotfiles"` resolves through the Task 1 symlink to the repo, so `~/.config/mise` mirrors to `repo/.config/mise`.
- The `[dotfiles]` entry for desktop dirs (hypr, niri, …) is **deliberately not here yet** — their sources live under `repo/config/` until the Stage 2 rename, and adding them now would make status report `source missing`. They arrive in Stage 2 alongside `git mv config .config`.

- [ ] **Step 2: Verify config parses and merges**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config
```
Expected: output includes `.config/mise/config.toml` (as the last repo line, `(none)` tools) after the fragment lines.

- [ ] **Step 3: Verify the self-managing entry resolves (source exists)**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise bootstrap dotfiles status
```
Expected: line for `~/.config/mise` — status `differs` or `applied`-style with resolved source `.../repo/.config/mise`, and **no `source missing`**. Target currently being a real dir (not symlink) is expected and fine; do NOT apply.

- [ ] **Step 4: Commit**

```bash
git add .config/mise/config.toml
git commit -m "feat: author mise global core config with self-managing dotfiles entry"
```

---

## Task 6: Shell-integration tools + bootstrap packages fragments

**Files:**
- Create: `.config/mise/conf.d/60-shell.toml`
- Create: `.config/mise/conf.d/70-packages.toml`

- [ ] **Step 1: Create `60-shell.toml`**

Shell-integration tools (currently nix-installed; declared here so the same config works without nix). Content:
```toml
[tools]
starship = "latest"
eza = "latest"
bat = "latest"
fzf = "latest"
zoxide = "latest"
yazi = "latest"
direnv = "latest"
```

- [ ] **Step 2: Create `70-packages.toml`**

Host/system packages, declared per-OS (mise's built-in managers; `pacman:` on CachyOS/Arch, `brew:` on macOS). Contents finalize in Stages 4–5; this is the initial real set:
```toml
[bootstrap.packages]
"pacman:age" = { os = "linux" }
"brew:age" = { os = "macos" }
"brew:sops" = { os = "macos" }
```
Notes:
- These are declarations only — mise installs packages only on explicit `mise bootstrap packages apply` (which this stage never runs).
- `sops` on Arch lives in the `extra` repo; include `"pacman:sops" = { os = "linux" }` only if a live probe in Task 10 confirms the package name resolves via pacman. Verify with `pacman -Si sops` before adding.

- [ ] **Step 3: Verify both fragments load**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config
```
Expected: lines for `60-shell.toml` (starship, eza, bat, fzf, zoxide, yazi, direnv) and `70-packages.toml` (`(none)` under tools — it declares `[bootstrap.packages]`, which `mise config` doesn't list as tools).

- [ ] **Step 4: Verify package declarations parse via bootstrap status (dry, no install)**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise bootstrap packages status
```
Expected: lists `age` (and `sops` if added) as requested; no installation happens.

- [ ] **Step 5: Commit**

```bash
git add .config/mise/conf.d/60-shell.toml .config/mise/conf.d/70-packages.toml
git commit -m "feat: declare shell-integration tools and bootstrap packages"
```

---

## Task 7: Trust the repo config

**Files:** none (trust state recorded outside the repo by mise).

- [ ] **Step 1: Trust via `mise trust` (records human approval)**

Run (from repo root):
```bash
/usr/bin/mise trust
```
Expected: prints `mise trusted <repo-path>` (or lists the config; confirm it marks `.config/mise` trusted). This lets future commands read it without prompting.

- [ ] **Step 2: Trust via `MISE_TRUSTED_CONFIG_PATHS` (automation path)**

Run (from repo root):
```bash
MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config >/dev/null
```
Expected: exit 0, no trust errors. Note: `trusted_config_paths` is also a `[settings]` key usable later for automated bootstrap on fresh machines.

- [ ] **Step 3: Verify trust persisted without env**

Run (from repo root):
```bash
/usr/bin/mise config >/dev/null
```
Expected: exit 0 (no trust prompt). If it still errors, run `/usr/bin/mise trust` again and check `~/.local/state/mise/trusted-configs` or equivalent.

No commit (machine-local trust state).

---

## Task 8: Pilot verification — dotfiles resolve, dry-run only

**Files:** none (verifies prior tasks).

Runs from the repo root. All apply commands are `--dry-run` only. The real `~/dotfiles` symlink is the `dotfiles.root`; the real `~/.config/...` targets are nix-managed and must remain untouched — dry-run proves what a later apply would do without doing it.

- [ ] **Step 1: Status — every entry resolves, none `source missing`**

Run:
```bash
/usr/bin/mise bootstrap dotfiles status
```
Expected: `~/.config/mise` line with a resolved source path under `~/dotfiles/.config/mise` (= repo `.config/mise`) and a non-`missing` state — `differs` or a conflict note, since the target is currently a real directory (nix-managed), not the expected symlink. The key assertion: **no `source missing`**.

- [ ] **Step 2: Apply dry-run — prints the exact `ln -sf` without touching**

Run:
```bash
/usr/bin/mise bootstrap dotfiles apply --dry-run
```
Expected: because `~/.config/mise` is a real directory, this should report a **conflict refusal** (mise refuses to replace real files/dirs it doesn't manage; `--force` would be needed). That refusal is the correct, expected Stage 0 result — it confirms conflict detection works and that real state is safe from accidental apply. Verify `~/.config/mise` was NOT changed (no new symlink).

- [ ] **Step 3: Full bootstrap sequence dry-run**

Run:
```bash
/usr/bin/mise bootstrap --only dotfiles --dry-run
```
Expected: prints `mise bootstrap: dotfiles` header + the same dry-run lines; exits cleanly.

- [ ] **Step 4: Negative check — a bad source entry reports `source missing`**

Run (from repo root, using a throwaway config dir in /tmp — do not edit the committed config):
```bash
mkdir -p /tmp/mise-pilot-check/.config/mise && cat > /tmp/mise-pilot-check/.config/mise/config.toml <<'EOF'
[settings]
dotfiles.root = "~/dotfiles"
[dotfiles]
"~/.config/nonexistent-tool" = {}
EOF
cd /tmp/mise-pilot-check && MISE_TRUSTED_CONFIG_PATHS=/tmp/mise-pilot-check /usr/bin/mise bootstrap dotfiles status
```
Expected: `~/.config/nonexistent-tool ... source missing`. Then clean up: `rm -rf /tmp/mise-pilot-check`.

---

## Task 9: Pilot verification — capture workflow is sandboxed

**Files:** none (scratch only).

`mise bootstrap dotfiles add` writes the entry to the **global config** and seeds the file under `dotfiles.root`. Both must be pointed at scratch locations so the real global config and real home files are untouched.

- [ ] **Step 1: Run `add` with scratch global + scratch root**

Run (from repo root; scratch globals/roots under /tmp):
```bash
mkdir -p /tmp/mise-pilot-root
MISE_GLOBAL_CONFIG_FILE=/tmp/mise-pilot-global.toml \
MISE_DOTFILES_ROOT=/tmp/mise-pilot-root \
  /usr/bin/mise bootstrap dotfiles add ~/.inputrc --no-apply
```
Expected: prints e.g. `mise dotfiles: copied ~/.inputrc to /tmp/mise-pilot-root/.inputrc` and `mise dotfiles: added ~/.inputrc to /tmp/mise-pilot-global.toml`.

- [ ] **Step 2: Verify the entry landed in the scratch global, not the real one**

Run:
```bash
cat /tmp/mise-pilot-global.toml        # → should contain [dotfiles] "~/.inputrc" = {}
ls ~/.config/mise/config.toml          # → must NOT exist (real global untouched)
```

- [ ] **Step 3: Verify the mirror file was seeded only in scratch root**

Run: `ls -l /tmp/mise-pilot-root/.inputrc`
Expected: exists (copy of `~/.inputrc`).

- [ ] **Step 4: Clean up scratch**

Run: `rm -rf /tmp/mise-pilot-root /tmp/mise-pilot-global.toml`

---

## Task 10: Settle open item 4 — per-host/OS selection mechanism

**Files:**
- Modify: `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` (open item 4 → resolved with finding)

Probe (in /tmp, no repo or system changes) which mechanism mise 2026.8.6 actually uses to gate tools by host/OS. This decides how Stage 1+ author per-host opt-in groups (replacing `acme.tools.<group>.enable`).

- [ ] **Step 1: Probe conf.d naming — is `20-macos.toml` a plain fragment or OS-gated?**

Run:
```bash
rm -rf /tmp/mise-probe && mkdir -p /tmp/mise-probe/.config/mise/conf.d && cd /tmp/mise-probe
cat > .config/mise/config.toml <<'EOF'
[settings]
auto_env = true
EOF
cat > .config/mise/conf.d/10-linux.toml <<'EOF'
[tools]
ripgrep = "latest"
EOF
cat > .config/mise/conf.d/20-macos.toml <<'EOF'
[tools]
"bad-tool-that-does-not-exist-probe" = "latest"
EOF
MISE_TRUSTED_CONFIG_PATHS=/tmp/mise-probe /usr/bin/mise config
```
Expected observed behavior (record it): since 20-macos.toml is a plain fragment, `bad-tool...` loads on Linux too — proving **conf.d fragment names do NOT gate by OS**. If instead the bad tool errors/skips, platform gating exists — record that instead.

- [ ] **Step 2: Probe env-gating via `mise.<env>.toml`**

Run:
```bash
cat > .config/mise/mise.custom.toml <<'EOF'
[tools]
d2 = "latest"
EOF
MISE_TRUSTED_CONFIG_PATHS=/tmp/mise-probe MISE_ENV=custom /usr/bin/mise ls --current | grep -E "d2|bad-tool"
echo "--- no MISE_ENV ---"
MISE_TRUSTED_CONFIG_PATHS=/tmp/mise-probe /usr/bin/mise ls --current | grep -E "d2|bad-tool"
```
Expected: `d2` appears with `MISE_ENV=custom` and not without (env-gating works via `mise.<env>.toml`); `bad-tool` behavior from Step 1 is confirmed.

- [ ] **Step 3: Probe platform files via `auto_env`**

Run:
```bash
cat > .config/mise/mise.linux.toml <<'EOF'
[tools]
jq = "latest"
EOF
MISE_TRUSTED_CONFIG_PATHS=/tmp/mise-probe /usr/bin/mise ls --current | grep jq
```
Expected: record whether `mise.linux.toml` is auto-loaded on Linux with `auto_env = true`.

- [ ] **Step 4: Record the finding in the spec**

Edit `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` open item 4 to a resolved note: which mechanism works (e.g. `mise.<host>.toml` with `MISE_ENV=<host>`, or platform files + `auto_env`), and that conf.d fragment names are plain (not OS/env-gated) in 2026.8.6.

- [ ] **Step 5: Verify sops/age package names resolve via pacman (for 70-packages.toml)**

Run: `pacman -Si sops | head -3; pacman -Si age | head -3`
Expected: both query successfully (package exists). If `sops` is not in the system repos, remove `"pacman:sops"` from 70-packages.toml (AUR-only packages are skipped by `[bootstrap.packages] pacman:` since user repos aren't in default pacman).

- [ ] **Step 6: Commit the spec finding**

```bash
git add docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md
git commit -m "docs: resolve open item 4 (per-host selection) with live probe finding"
```

- [ ] **Step 7: Clean up probe**

Run: `rm -rf /tmp/mise-probe`

---

## Task 11: Stage 0 exit checks — zero nix diff, rollback documented

**Files:** none (verification).

- [ ] **Step 1: Confirm no nix/home-manager changes**

Run: `git status --short`
Expected: only the deliberate Stage 0 commits (`.config/mise/**`, `.gitignore`, spec) — **no `modules/`, `hosts/`, `flake.nix`, `flake.lock` changes**. (If the unrelated pre-existing `flake.lock` modification is still sitting uncommitted from before this branch, leave it as-is; it is not part of this work.)

- [ ] **Step 2: Confirm real dotfiles untouched**

Run:
```bash
ls -ld ~/.config/hypr ~/.config/niri        # still nix-store symlinks (goal: unchanged)
readlink ~/.zshrc                           # still nix-store path
```
Expected: unchanged from before Stage 0 (desktop dirs still point into the nix store; `.zshrc` still a nix-managed symlink). Nothing was applied.

- [ ] **Step 3: Update the spec's Stage 0 status**

Edit `docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md` Stage 0 section: mark it **DONE** (pilot complete; bootstrapping machinery proven against repo `.config/mise/`). Commit:
```bash
git add docs/superpowers/specs/2026-08-23-mise-dotfiles-design.md
git commit -m "docs: mark Stage 0 (mise pilot) complete"
```

- [ ] **Step 4: Record rollback**

In a short note appended to the spec (or this plan's end), record: **Stage 0 rollback** = `rm ~/dotfiles`, `rm -rf .config/mise`, `git checkout .gitignore`, and (if trust was recorded) remove the trusted path — zero system impact since no dotfile or package was applied, no nix change exists to revert.

---

## Deferred follow-on stages (intentionally not planned here)

Per design decision, later stages are written as plans only when we're ready to execute them, so we can adapt as needed:

- **Stage 1** — first nix touch: disable HM `tools.nix`/`dev.nix` conf.d generation and `programs.mise.enable`; apply the self-managing `[dotfiles] "~/.config/mise" = {}` entry; confirm single `/usr/bin/mise`. **Plan when Stage 0 has run green.**
- **Stage 2** — desktop dotfiles + `git mv config/* .config/` (note: `.config/` will exist; move contents, not the dir). Declare `[dotfiles]` for hypr/niri/uwsm/hyprpanel/ashell/noctalia/nvim **after** the rename so sources exist.
- **Stage 3 — deferred** — generated non-shell configs (starship/git/tmux/htop…) → repo files.
- **Stage 4** — zsh rc files + antidote (git-clone under `~/.antidote`) + `[bootstrap.mise_shell_activate]`.
- **Stage 5** — programs → `[tools]`/`[bootstrap.packages]` (finish 70-packages.toml / 80-desktop.toml).
- **Stage 6** — `[bootstrap.repos]`, `[bootstrap.user]`, tasks/hooks, standalone `mise bootstrap` prove-out.
- **Stage 7** — cross-platform (work-mbp) / shrink nix.

The `[dotfiles]` desktop entries are intentionally absent from the Stage 0 config.toml (their sources don't exist until the Stage 2 rename); adding them in Stage 0 would violate the "no `source missing`" exit criterion.

---

## Success criteria (Stage 0)

- `~/projects/dotfiles` and `~/dotfiles` both resolve to the repo.
- `.config/mise/` in the repo is a complete draft of the future global config: `config.toml` + all tool fragments + bootstrap packages.
- `MISE_TRUSTED_CONFIG_PATHS="$(pwd)" /usr/bin/mise config` lists the repo's `.config/mise/config.toml` and every fragment, merged with the real global config.
- `mise bootstrap dotfiles status` resolves `~/.config/mise` → repo `.config/mise` (no `source missing`).
- `mise bootstrap ... --dry-run` variants all work (dotfiles apply, full `--only dotfiles` sequence).
- Capture workflow (`dotfiles add`) proven against scratch global/root; real global config untouched.
- Open item 4 recorded in the spec with a live finding.
- `git status` shows zero nix/home-manager changes; real `~/.config/...` targets untouched.