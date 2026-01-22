# Global associative array: repo → last fetch timestamp (epoch seconds)
typeset -A FETCHED_REPOS

# Time-to-live for fetches
# Set to 2 hours (7,200 seconds)
GIT_AUTO_FETCH_TTL=7200

# Hook into change directory action
chpwd() {
  now=$EPOCHSECONDS # zsh built-in, current time in seconds
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    if git config --get remote.origin.url &>/dev/null; then
        local repo
        repo=$(git rev-parse --show-toplevel)
        last=${FETCHED_REPOS[$repo]:-0} # default 0 if never fetched
        if (( now - last > GIT_AUTO_FETCH_TTL )); then
          echo "[auto-fetch] Fetching in $(basename "$repo")..."
          git fetch --quiet &!
          FETCHED_REPOS[$repo]=$now
        fi
    fi
  fi
}
