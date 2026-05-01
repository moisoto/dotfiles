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
  if [[ "$PWD" == "$HOME" ]] ; then
    echo "Running vf on the home directory is disabled"
    return 0
  fi

  local fzf_opts=(
    --color='bg:#4B4B4B,bg+:#3F3F3F,info:#BDBB72,border:#6B6B6B,spinner:#98BC99'
    --color='hl:#719872,fg:#D9D9D9,header:#719872,fg+:#D9D9D9'
    --color='pointer:#E12672,marker:#E17899,prompt:#98BEDE,hl+:#98BC99'
    --style=full
    --height=~100%
  )

  local ftl=$(fzf "${fzf_opts[@]}")
  if [[ -n "$ftl" ]] ; then
    echo "Running vim $ftl"
    vim "$ftl"
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

md2csv() {
  if [[ -z "$1" ]]; then
    echo "Converts a Markdown table to csv format."
    echo "Usage: md2csv <input.md> [output.csv]" >&2
    echo
    echo "*** For better results use a .md file that only contains a table ***"
    return 1
  fi

  local input="$1"
  local output="$2"

  if [[ ! -f "$input" ]]; then
    echo "File not found: $input" >&2
    return 1
  fi

  # === Clean + properly quoted CSV ===
  local awk_cmd='
    BEGIN { OFS=","; col_count = 0 }
    {
      # Skip separator lines
      if ($0 ~ /^\s*\|?[-:| ]+\|?\s*$/) next

      line = $0

      # trim leading spaces
      gsub(/^\s+/, "", line)

      # Normalize: ensure line starts and ends with |
      # This makes splitting consistent for both styles
      if (line !~ /^\s*\|/) line = "|" line
      if (line !~ /\|\s*$/) line = line "|"

      # Now split by |
      n = split(line, fields, /\|/)

      # On first data row, detect column count
      if (col_count == 0) {
        col_count = n
      }

      # Process each row
      for (i = 2; i < col_count; i++) {
        field = fields[i] ? fields[i] : ""

        # Trim spaces
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", field)

        # Quote if:
        #   - contains comma, quote, space, or newline
        #   - is empty
        #   - starts with 0 followed by digits (preserve leading zeros)
        if (field ~ /[,"\n]/ || field == "" || field ~ /^0[0-9]+$/) {
          gsub(/"/, "\"\"", field)
          field = "\"" field "\""
        }

        printf "%s%s", field, (i < col_count-1 ? OFS : ORS)
      }
    }
  '

  if [[ -n "$output" ]]; then # Output to file
    # Check if output file already exists
    if [[ -f "$output" ]]; then
      echo "Error: Output file already exists: $output" >&2
      echo "Remove it first or choose a different name." >&2
      return 1
    fi

    awk -F'\\|' "$awk_cmd" "$input" > "$output"
    echo "Converted: $input → $output" >&2
  else # Output to terminal
    if [[ -t 1 ]] && command -v bat >/dev/null 2>&1; then
      # [[ -t 1 ]] → checks if file descriptor 1 (stdout) is connected to a terminal.
      # If so, use bat with CSV syntax highlighting
      awk -F'\\|' "$awk_cmd" "$input" | bat --color=always --language=csv
    else
      # Fallback to plain output
      awk -F'\\|' "$awk_cmd" "$input"
    fi
  fi
}
