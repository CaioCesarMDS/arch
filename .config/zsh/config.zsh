# ============================================================================
# General Configuration
#
# Sets general Zsh options, shell behavior, and history settings for all
# interactive shells. Adjust these to customize your shell experience.
# ============================================================================

# --- History settings ---
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/.zsh_history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_find_no_dups

# --- Command correction ---
setopt CORRECT
