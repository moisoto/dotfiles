gocloud() {
  # Set iCloud Folder as $base_dir
  local cur_dir=$(pwd)
  local base_dir="${HOME}/Library/Mobile Documents/com~apple~CloudDocs"

  # If inside $basedir then target is relative to current folder
  if [[ "$cur_dir" == "$base_dir"/* ]]; then
     local target_dir="$cur_dir/$1"
  fi

  # If folder doesn't exists then assume root of iCloud folder
  if [[ ! -d "$target_dir" ]] ; then
     local target_dir="$base_dir/$1"
  fi

  if [[ -d "$target_dir" ]]; then
      # Perform the `cd` operation with the resolved directory
      cd $target_dir
  else
      echo "Error: Folder '$1' does not exist in iCloud directory."
      echo
      echo "Usage: gocloud will allow you to cd into a folder inside your iCloud. It works relative to your iCloud folder and not your current directory."
      echo
      echo "Syntax: gocloud [folder]"
  fi
}
