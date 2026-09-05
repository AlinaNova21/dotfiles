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

# Aliases are managed as a mise [dotfiles] block (~/.zshrc/aliases) — not inline here.
# See .config/mise/config.toml.

# --- antidote (zsh plugin manager) ---
# oh-my-zsh plugins are loaded directly via antidote (no oh-my-zsh.sh), so they
# miss the framework's ZSH_CACHE_DIR + completions dir that oh-my-zsh.sh creates
# (kubectl plugin's completion generator needs it; without it, its =(...) temp
# file creation fails and zsh 5.9.2 corrupts the heap: "free(): invalid size").
[[ -n "$ZSH_CACHE_DIR" ]] || ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR/completions"
# Static deferred load (fast): generate .zsh_plugins.zsh once, source it
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
[[ ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]] || {
  ( source ~/.antidote/antidote.zsh
    antidote bundle < ${zsh_plugins}.txt > ${zsh_plugins}.zsh )
}
source ${zsh_plugins}.zsh