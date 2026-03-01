# =============================================================================
# Global Zsh Environment File
#
# This file is loaded for all Zsh shells (interactive and non-interactive).
# It sets essential environment variables and XDG base directories before any
# other configuration is loaded.
# =============================================================================

# --- XDG Base Directories ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Zsh config directory
export ZDOTDIR="$HOME/.config/zsh"
