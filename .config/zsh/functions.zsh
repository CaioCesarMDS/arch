# =========================================
# Functions Configuration
#
# Contains commonly used functions for Zsh
# =========================================

# --- Add a directory to PATH, avoiding duplicates ---
add_to_path() {
  local dir="$1"
  local current
  local path_list=()

  # Split PATH into an array
  IFS=':' read -r -A current <<<"$PATH"

  # Add the directory if not already in PATH
  if [[ ! " ${current[*]} " =~ " ${dir} " ]]; then
    path_list+=("$dir")
  fi

  # Add all other directories, skipping duplicates
  for d in "${current[@]}"; do
    [[ "$d" != "$dir" ]] && path_list+=("$d")
  done

  # Join array back into PATH string
  PATH="${path_list[*]}"
  PATH="${PATH// /:}"
  export PATH
}

# --- Update system tools ---
update() {
  echo "Updating system tools..."
  sudo pacman -Syu --noconfirm
  command -v yay >/dev/null && yay -Syu --noconfirm
  command -v zinit >/dev/null && zinit self-update && zinit update --all
  echo "Everything's is up to date!"
}

# --- Extract files from various formats ---
extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xvf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
