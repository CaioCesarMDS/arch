# =========================================
# Aliases Configuration
#
# Contains commonly used aliases for Zsh
# =========================================

# --- Utility ---
alias ls='eza --icons=always --color=always --no-filesize --no-time --no-user --no-permissions'
alias la='eza -a --color=always --group-directories-first --icons'
alias lah='eza -lah --color=always --group-directories-first --icons --git --time-style=long-iso'
alias lt='eza -aT --color=always --group-directories-first --icons --ignore-glob=node_modules --ignore-glob=.git --ignore-glob=venv'

# --- Navigation ---
alias cd='z'

# --- Misc ---
alias c='clear'
alias h='history'
alias ff='fastfetch'
