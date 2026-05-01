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
