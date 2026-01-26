#!/bin/sh

# Set variables
configfile=$(chezmoi data --format=yaml | grep "configFile:" | awk '{ print $2 }')
fileext="${configfile##*.}"
filedir="${configfile%/*}"
gpgkey=$(gpg --list-secret-keys --keyid-format LONG --with-colons | awk -F: '/^sec/ {print $5}' | tail -1)
fullkey=$(gpg --list-secret-keys --keyid-format LONG --with-colons | grep "$gpgkey" | awk -F: '/^fpr/ {print $10}')

if command -v gpg >/dev/null 2>&1; then
  gpginst="yes"
fi

if [ "$fileext" != "toml" ]; then
  echo "Extension $fileext not supported."
  exit 1
fi

if [[ -f "$configfile" && "$1" != "--force" ]]; then
  echo "Config file $configfile already exist."
  echo "Please edit manually with: \"chezmoi edit-config\"."
  echo
  exit 1
fi

if [ ! -d "$filedir" ]; then
  echo "Creating config folder $filedir."
  mkdir -p $filedir
fi

echo "Creating config file at: $configfile"
read -r -p "Proceed? [Y/n] " answer

case "$answer" in
  [Yy]|"")
    echo "[data.config.machine]" > $configfile
    echo "name  = \"$(scutil --get LocalHostName)\"" >> $configfile
    echo "owner = \"$USER\"" >> $configfile
    echo "role  = \"laptop|desktop|office\"" >> $configfile
    echo "id    = \"${USER}.$(scutil --get LocalHostName)\"" >> $configfile
    echo >> $configfile
    echo "[data.config.secrets]" >> $configfile
    if [[ -z "$gpginst" || -z "$fullkey" ]] ; then
      echo "gpg_key    = \"put-your-gpp-here\"" >> $configfile
      echo "gpg_defkey = \"put-your-default-gpg-here\"" >> $configfile
    else
      echo "gpg_key    = \"$gpgkey\"" >> $configfile
      echo "gpg_defkey = \"$fullkey\"" >> $configfile
    fi
    echo "gemini_key = \"put-your-gemini-apikey-here\"" >> $configfile
    echo "Config file created."
    ;;
  *)
    exit 1
    ;;
esac
echo
