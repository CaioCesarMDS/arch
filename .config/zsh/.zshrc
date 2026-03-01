# ============================================================================
# Main Zsh Configuration File
#
# This file is loaded for interactive Zsh shells and is responsible for
# importing modular configuration files.
# ============================================================================

# Prevent multiple loads
[[ -n "$ZSHRC_LOADED" ]] && return
export ZSHRC_LOADED=1

# --- Modular configuration ---
files=(
  "config.zsh"
  "plugins.zsh"
  "aliases.zsh"
  "functions.zsh"
  "tools.zsh"
)

# Load each module if it exists
for file in "${files[@]}"; do
  [[ -f "$ZDOTDIR/$file" ]] && source "$ZDOTDIR/$file"
done
