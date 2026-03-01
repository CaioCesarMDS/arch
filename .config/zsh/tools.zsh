# ============================================================================
# Tools Configuration
#
# Integrates external tools and utilities with Zsh.
# ============================================================================

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
  export STARSHIP_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/starship"
  eval "$(starship init zsh)"
fi

# --- zoxide (smarter cd) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# --- fzf (fuzzy finder) ---
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)

  export FZF_CTRL_R_OPTS="--style full"
  export FZF_CTRL_T_OPTS="
    -style full
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {} || cat {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
    "
fi
