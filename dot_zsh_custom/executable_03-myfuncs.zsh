# mtac: Reverse of cat with a healthy dose of more
function mtac()
{
  if [[ "$1" == "--help" ]]; then
    echo "mtac:  Show a file in reverse line order, page by page."
    echo "Usage: mtac filename"
    return 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: No file specified. Use --help for usage."
    return 1
  fi

  tail -r "$1" | more
}

function vf()
{
  local curdir=$(pwd)
  if [[ "$curdir" == "$HOME" ]] ; then
    echo "Running vf on the home directory is disabled"
    return 0
  fi

  local ftl=$(fzf)
  if [ ! -z "$ftl" ] ; then
    echo "Running vim $ftl"
    vim $ftl
  else
    echo "No file was selected"
  fi
}

function muxi()
{
  if ! command -v gum &> /dev/null; then
    printf "\033[38;2;255;85;85m✖ The gum utility is required to run this script.\033[0m\n" >&2
    printf "\033[38;2;255;85;85m  For install instructions please visit https://github.com/charmbracelet/gum.\033[0m\n" >&2
    return 1
  fi

  # Check if tmux is installed
  if ! command -v tmux >/dev/null 2>&1; then
    printf "\033[38;2;255;85;85m✖ tmux is not installed.\033[0m\n" >&2
    return 1
  fi

  # Get list of sessions
  local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

  # Get list of tmuxinator projects
  local projects=$(tmuxinator list | grep -v "projects:" | tr -s ' ' '\n')

  local selected
  if [[ -n "$1" ]] # A session was specified
  then
    if printf '%s\n' "$sessions" | grep -Fxq "$1"; then
      selected=$1
    else
      if printf '%s\n' ${projects} | grep -Fxq "$1"; then
        echo "Found tmuxinator project $1. Starting it..."
        selected=$1
        tmuxinator start $selected --no-attach
      else
        echo "Session $1 not found!"
        # don't return so the user can pick one from a list
      fi
    fi
  fi

  if [[ -z "$selected" ]]; then
    if [[ -z "$sessions" && -z "$projects" ]]; then
      echo "No tmux sessions found."
      return 0
    fi

    list=$(echo "${sessions}\n${projects}" | sort -u)
    # Let the user pick a session with gum
    selected=$(printf "%s\n" "$list" | gum choose --height 10 --cursor "➤" --header="Choose a Session:" --padding="1 0" --header.foreground="300")

    # If user canceled, exit
    if [ -z "$selected" ]; then
      return 0
    else
      if [[ "$sessions" != *"$selected"* ]]; then
        echo "Starting tmuxinator project $selected..."
        tmuxinator start $selected --no-attach
      fi
    fi

  fi

  echo "Attaching to $selected..."
  # Attach to the selected session
  if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    tmux -CC attach -t "$selected"
  else
    tmux attach -t "$selected"
  fi
}

# Decrypt a file and extract if .tar[.gz]
function gpg_decrypt() {
  local encrypted_file="$1"

  if [[ -z "$encrypted_file" ]]; then
    echo "Usage: gpg_decrypt <file>"
    return 1
  fi

  if [[ ! -f "$encrypted_file" ]]; then
    echo "Error: file not found: $encrypted_file"
    return 1
  fi

  # Remove .gpg or .asc extension
  local base="$encrypted_file"
  if [[ "${base%*.gpg}" != "$base" ]]; then
    base="${base%.gpg}"
  elif [[ "${base%*.asc}" != "$base" ]]; then
    base="${base%.asc}"
  fi

  if [[ "$base" == "$encrypted_file" ]]; then
    base="${base}.decrypted"
  fi

  if [[ -e "$base" ]]; then
    echo "Output file $base already exists."
    base=""
    while [[ -z "$base" ]]; do
      printf "Enter new name for output file: "
      read base
    done
  fi

  echo "Decrypting $encrypted_file…"
  gpg --output "$base" --decrypt "$encrypted_file" || return 1

  # Detect tar.gz or tar
  if [[ "$base" == *.tar.gz || "$base" == *.tar.gz.decrypted ]]; then
    echo
    echo "*** Compressed tar file detected *** "
    echo "Extracting $base…"
    tar -xvzf "$base"
  elif [[ "$base" == *.tar || "$base" == *.tar.decrypted ]]; then
    echo
    echo "*** tar file detected *** "
    echo "Extracting $base…"
    tar -xvf "$base"
  else
    echo "Decrypted file is: $base"
    return 0
  fi

  echo "Done."
}

# Encrypt an file or folder using gpg
function gpg_enc_file_or_folder() {
  if [[ $# -lt 1 || "$1" == "--armor" ]]; then
    echo "Usage: gpg_enc_file_or_folder <file_or_folder> [recipient] [--armor]"
    return 1
  fi

  local fof="$1"
  local sign_key="$GPG_KEY_ID"
  local recipient
  local file
  local encfile
  local armor

  # Check for missing recipient
  if [[ $# -lt 2 || "$2" == "--armor" ]]; then
    echo "No recipient specified, encrypting with your own public key for personal use."
    echo "Your Key ID: $GPG_KEY_ID"
    recipient=$GPG_KEY_ID
  else
    recipient="$2"
  fi

  # Check if --amor was specified (otherwise $armor will be empty).
  if [[ "$2" = "--armor" || "$3" == "--armor" ]]; then
    armor="--armor"
  fi

  if [[ -d "$fof" ]]; then
    file="${fof%/}.tar.gz"

    echo "Folder detected. Creating archive: $file"
    tar -czf "$file" "$fof"
  else
    file="$fof"
  fi

  if [[ "$armor" == "--armor" ]]; then
    encfile="${file}.asc"
  else
    encfile="${file}.gpg"
  fi

  echo "Encrypting to: $encfile"
  gpg $armor --local-user "$sign_key" --encrypt --sign --recipient "$recipient" "$file"

  echo "Done. Encrypted file: $encfile"
}

function gpg_armor_file_or_folder() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gpg_armor_file_or_folder <file_or_folder> [recipient]"
    return 1
  fi
  gpg_enc_file_or_folder $1 $2 --armor
}

function gpg_getkey() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gpg_getkey <fingerprint> [keyserver]"
    return 1
  fi

  if [[ -z $2 ]]; then
    gpg --recv-keys $1
  else
    local keyserver
    if [[ $2 == "ubuntu" ]]; then
      keyserver="keyserver.ubuntu.com"
    else
      keyserver=$2
    fi
    gpg --keyserver $keyserver --recv-keys $1
  fi
}

function krep() {
  if ! command -v gum &> /dev/null; then
    printf "\033[38;2;255;85;85m✖ The gum utility is required to run this script.\033[0m\n" >&2
    printf "\033[38;2;255;85;85m  For install instructions please visit\033[38;5;117m https://github.com/charmbracelet/gum\033[0m\n" >&2
    return 1
  fi

  if ! command -v klog &> /dev/null; then
    printf "\033[38;2;255;85;85m✖ The klog utility is required to run this script.\033[0m\n" >&2
    printf "\033[38;2;255;85;85m  Install using homebrew with: brew install klog For more information please visit\033[38;5;117m https://klog.jotaen.net\033[0m\n" >&2
    return 1
  fi

  local valid_opts=(--bookmark --default --edit --uselast --help)
  if [[ $1 == -* && ${valid_opts[(Ie)$1]} -eq 0 ]]; then
    echo "Invalid option: $1"
    printf "Use \033[38;5;117mkrep --help\033[0m for more details.\n"
    return 1
  fi

  if [[ "$1" == "--help" ]]; then
    printf "krep:  Shows Time Tracking information from klog utility.\n"
    printf "Usage: \033[38;5;117mkrep [ filename.klg | --bookmark | --uselast | --edit ]\033[0m\n"
    echo
    echo "Examples:"
    printf "\033[38;5;117m  krep --uselast          \033[38;5;114m# Show report using most recent file.\033[0m\n"
    printf "\033[38;5;117m  krep --edit             \033[38;5;114m# Edit klog file.\033[0m\n"
    printf "\033[38;5;117m  krep --default          \033[38;5;114m# Creates a default bookmark.\033[0m\n"
    printf "\033[38;5;117m  krep --bookmark         \033[38;5;114m# Creates a @current bookmark.\033[0m\n"
    printf "\033[38;5;117m  krep --bookmark [@name] \033[38;5;114m# Creates bookmark with specific name.\033[0m\n"
    printf "\033[38;5;117m  krep @bookmark_name     \033[38;5;114m# Show report from specific bookmark.\033[0m\n"
    printf "\033[38;5;117m  krep my_klog_file.klg   \033[38;5;114m# Show report from specific file.\033[0m\n"
    printf "\033[38;5;117m  krep \033[38;5;114m# Smart Mode:\n"
    printf "    - If a file is found in current folder it will be used.\n"
    printf "    - If several files are found in current folder it will let you select one.\n"
    printf "    - If no file is found and @current bookmark is set, it will use that file.\033[0m\n\n"
    printf "Note: The\033[38;5;117m --default\033[0m option will create a default\n"
    printf "bookmark for direct use with the klog command.\n\n"
    return 0
  fi

  local filename
  if [[ $1 == @* ]]; then
      if klog bookmarks list | grep -q "$1"; then
        filename=$1
      else
        printf "Bookmark \033[38;5;117m$1\033[0m does not exists.\n"
        local bklist=$(klog bookmarks list)
        if [[ $bklist == @* ]]; then
          echo
          echo "Defined bookmarks are:"
          echo $bklist
        fi
        return 1
      fi
  elif [[ -z "$1" || "$1" == "--bookmark" || "$1" == "--edit" || "$1" == "--default" ]]; then
    local files=( *.klg(N) )
    if (( #files )); then # Found some .klg files
      filename=$(
        find . -type f -name "*.klg" |
          gum choose \
          --select-if-one \
          --padding="1 0" \
          --header.foreground="300" \
          --header="Please select file:"
      )
      if [[ "$1" == "--bookmark" && -f $filename ]]; then
        if [[ "$2" == @* ]];then
          klog bookmarks set $filename $2
        else
          klog bookmarks set $filename @current
        fi
      elif [[ "$1" == "--default" && -f $filename ]]; then
        klog bookmarks set $filename
      fi
    else # No .klg found, use @current bookmark
      if klog bookmarks list | grep -q '@current'; then
        local actualfile=$(klog bookmarks info @current)
        if [[ -f $actualfile ]]; then
          filename="@current"
        else
          echo "Found @current bookmark but file is no longer present."
          echo "The bookmark will be removed."
          printf "Use \033[38;5;117mkrep --help\033[0m for more details.\n"
          klog bookmark unset @current
        fi
      else
        echo "There are no .klg files in current folder and there's no bookmarked file."
        echo "Run from a folder with .klg files, and optionally use --bookmark to set it as default."
        printf "Use \033[38;5;117mkrep --help\033[0m for more details.\n"
      fi

      if [[ "$1" == "--default" || "$1" == "--bookmark" ]]; then
        printf "\033[38;2;255;85;85mThere are no .klg files in current folder.\033[0m\n"
        printf "\033[38;2;255;85;85mIgnoring $1 flag.\033[0m\n"
        return 1
      fi
    fi
  elif [[ $1 == "--uselast" ]]; then
    filename=(*.klg(.om[1]N))
    if [[ -z $filename ]]; then
      echo "There are no .klg files in current folder."
      printf "Use \033[38;5;117mkrep --help\033[0m for more details.\n"
    fi
  else
    filename=$1
  fi

  if [[ -z $filename ]]; then
    return 1
  fi

  if [[ ! -f $filename && $filename != @* ]]; then
    echo "File $filename not found!"
    printf "Use \033[38;5;117mkrep --help\033[0m for more details.\n"
    return 1
  fi

  if [[ "$1" == "--edit" ]]; then
    klog edit $filename
    return 1
  fi

  clear
  echo "---------------------"
  echo "This Week Activities:"
  echo "---------------------"
  klog print $filename --with-totals --this-week
  echo "------------"
  echo "Time Expent:"
  echo "------------"
  klog report $filename --chart
  echo
  echo "------------"
  echo "Tags Report:"
  echo "------------"
  klog tags $filename --count


  if [[ "$1" == "--bookmark" ]]; then
    local bookmark_name
    if [[ $2 == @* ]]; then
      bookmark_name="$2"
    else
      bookmark_name="@current"
    fi
    print "\nBookmark \033[38;5;117m$bookmark_name\033[0m was created, which points to \033[38;5;117m${filename:t}\033[0m\n\n"
  elif [[ "$1" == "--default" && "$filename" != "@current" ]]; then
    printf "\n\033[38;5;117m${filename:t}\033[0m is now set as default.\n"
    printf "Now you can issue klog commands without specifying the file.\n\n"
    printf "Examples:\n"
    printf "\033[38;5;117m   krep edit   \033[38;5;114m# Edit ${filename:t}\033[0m\n"
    printf "\033[38;5;117m   krep report \033[38;5;114m# Show report of ${filename:t}\033[0m\n"
    printf "\033[38;5;117m   krep print  \033[38;5;114m# Pretty-Print ${filename:t}\033[0m\n\n"
  fi
}

function kstart() {
  if [[ $# -eq 0 ]]; then
    echo "kstart: Adds an entry to @current klog aliased file."
    echo "Usage: kstart \"summary text\""
    return 1
  fi
  klog start @current --summary="$*"
}

function kpause() {
  if [[ $# -eq 0 ]]; then
    echo "kpause: Pauses ongoing activity from @current klog aliased file."
    echo "Usage: kpause \"summary text\""
    return 1
  fi
  klog pause @current --summary="$*"
}

function kstop() {
  if [[ "$1" = "--help" ]]; then
    echo "kstop: Closes ongoing activity from @current klog aliased file."
    echo "Usage: kstop [\"summary text\"]"
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    klog stop @current
  else
    klog pause @current --summary="$*"
  fi
}
