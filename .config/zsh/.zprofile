# ============================================================================
# Zsh Login Profile
#
# Sourced at the start of a login shell. Sets environment variables and options
# that should only apply to login sessions (not every shell).
# ============================================================================

# Load custom functions
[[ -f "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"

# --- Add user directories to PATH ---
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"

# --- Global Variables ---
export EDITOR=code
export LANG=en_US.UTF-8
