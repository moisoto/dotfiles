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
