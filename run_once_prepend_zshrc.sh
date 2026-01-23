#!/bin/sh

FILE="$HOME/.zshrc"
MARKER="# >>> zsh_custom >>>"

if ! grep -q "$MARKER" "$FILE"; then
  tmp=$(mktemp)
  {
    echo "$MARKER"
    echo 'for file in $(ls ~/.zsh_custom/*.zsh | sort); do'
    echo '  source "$file"'
    echo 'done'
    echo "# <<< zsh_custom <<<"
    echo
    echo "#--------"
    echo "# Original .zshrc after this comment"
    echo "#--------"
    echo
    cat "$FILE"
  } > "$tmp"
  mv "$tmp" "$FILE"
fi
