alias python=python3
alias pip=pip3
alias wadd="wd add"
alias wls="wd list"
alias lst="ls -lrt"
alias lzt="eza -l --header --icons --git --group-directories-first --sort=modified --tree --level=3"
alias lz="eza  -l --header --icons --git --group-directories-first --sort=modified"
alias gdf="~/git-utils/git_df.sh"        # Also available as git alias (use "git df" instead)
alias gcommit="~/git-utils/commit.sh"    # Also available as git alias (use "git gcm" instead)
alias trail-trim="~/git-utils/git_tt.sh" # Also available as git alias (use "git tt" instead)
alias glow="glow -w0 -p"                 # Disable line wrap and use pagination
alias ls-dataless="~/icloud-utils/ls-dataless.sh"
alias meminfo="memory_pressure | sed -E 's/(.*:[[:space:]]*)$/\x1b[38;5;117m\1\x1b[0m/' && echo && top -l 1 | grep --color=never -E 'PhysMem|MemRegions'"
alias muxinate='echo $PWD|pbcopy ; tmuxinator new ${PWD##*/} ; tmuxinator start ${PWD##*/}'
alias genc="gpg_enc_file_or_folder"
alias gdec='gpg_decrypt'
alias genca="gpg_armor_file_or_folder"
alias gsig="gpg --sign --local-user $GPG_KEY_ID"
alias gkey="gpg_getkey"
# ~/git-utils/git_drop.sh doesn't have a zsh alias. It's available as "git drop".

# todo-txt
export TODOTXT_DEFAULT_ACTION=ls
alias todo='todo.sh'
alias tadd='todo.sh add'
alias tls='clear;todo.sh ls'

# Ensure sudo for asitop
# Note: This won't trigger a loop
alias asitop='sudo asitop'
