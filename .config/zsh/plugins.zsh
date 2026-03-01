# ===================================
# Plugins Configuration
#
# Loads and configures Zsh plugins.
# ===================================

# --- Zinit (Plugin Manager) ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# --- Plugins and Snippets ---
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting

zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-you-should-use

zinit snippet OMZP::git

# --- Completion Fix ---
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

autoload -Uz compinit
compinit -d "$ZSH_CACHE_DIR/zcompdump"
zinit cdreplay -q

# --- Completion Style ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:completion:cd:*' fzf-preview use-cache 'ls --color $realpath'
