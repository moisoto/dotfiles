# Tools, Aliases, and Scripts Documentation

This chezmoi repo includes a set of scripts that will be called by
the startup script .zshrc and are located at `~/.zsh_custom`.

These scripts contain the user configuration part of .zshrc
(the rest of .zshrc will be the oh-my-zsh configuration).

This document describes the tools, aliases and scripts contained in
the scripts inside `.zsh_custom`.


## Git Utils

This repo will define aliases to the scripts from Git Utils, which is installed
as part of the macOS Dev Setup Guide.

These aliases are:

| Description            | Command         | Type                            |
|------------------------|-----------------|---------------------------------|
| Interactive Git Commit | gcommit         | Alias to *commit.sh*            |
| Git Full Diff          | gdf             | Alias to *git_df.sh*            |
| Git Full Diff          | git df          | Git Alias for *git_df.sh*       |
| Git Trail Trim         | git tt          | Git Alias for *git_tt.sh*       |
| Git Drop               | git drop        | Git Alias for *git_drop.sh*     |
| Git Undo               | git undo        | Git Alias for *git_undo.sh*     |
| Git Compact Log        | git clog        | Custom Git Log - Compact Format |
| Git Stat Log           | git slog        | Custom Git Log - Stat Format    |


## GPG Utils

A suit of aliases and functions are included in this repo that simplify GPG usage:

| Description            | Command         | Type                                             |
|------------------------|-----------------|--------------------------------------------------|
| GPG Encrypt            | genc            | Alias to *gpg_enc_file_or_folder* zsh function   |
| GPG Decrypt            | gdec            | Alias to *gpg_decrypt* zsh function              |
| GPG Armor Encrypt      | genca           | Alias to *gpg_armor_file_or_folder* zsh function |
| GPG Get Key            | gkey            | Alias to *gpg_getkey* zsh function               |
| GPG Signing            | gsig            | Alias for Signing a File                         |


## TMUX & TMUXINATOR

This repository includes aliases and functions that simplify usage of TMUX & TMUXINATOR:

| Description            | Command         | Type                                                     |
|------------------------|-----------------|----------------------------------------------------------|
| Muxinate               | muxinate        | Alias - Creates and starts a new TMUXINATOR session      |
| TMUX Interactive       | muxi            | Function - Let's you select a TMUX Session interactively |


## Functions for for klog

A suit of functiones are included in this repo that simplify Klog usage:

| Description            | Command         | Type                                  |
|------------------------|-----------------|---------------------------------------|
| Klog Report            | krep            | Function - Prints a klog Report       |
| Klog Start Task        | kstart          | Function - Adds a new klog task       |
| Klog Pause             | kpause          | Function - Pause current klog task    |
| Klog Stop              | kstop           | Function - Finishes current klog task |


## Aliases for todo-txt


| Description       | Command         | Type                    |
|-------------------|-----------------|-------------------------|
| Call todo.sh      | todo            | Alias to _todo.sh_      |
| Add Todo Task     | tadd            | Alias to _todo.sh add_  |
| List Todo Tasks   | tls             | Alias to _todo.sh ls_   |


## Aliases for wd

Working Directory (wd) is a oh-my-zsh plugin that let's you cd into specific folders using aliases.

We have defined a few aliases to simplify usage:

| Description       | Command         | Type            |
|-------------------|-----------------|-----------------|
| Add warp point    | wadd [point]    | Alias           |
| List warp points  | wls             | Alias           |
| Remove warp point | wd rm [point]   | Command         |


## Aliases for ls & eza

For listing files several aliases have been defined:

| Description       | Command         | Type            |
|-------------------|-----------------|-----------------|
| List by Mod. Time | lst             | Alias to _ls_   |
| List by Mod. Time | lz              | Alias to _eza_  |
| List tree format  | lzt             | Alias to _eza_  |


## Other aliases

| Description        | Command         | Type                                  |
|--------------------|-----------------|---------------------------------------|
| Python             | python          | Alias to _python3_                    |
| Python Pkg Mng     | pip             | Alias to _pip3_                       |
| Trail Trim         | trail-trim      | Alias to *git_tt.sh*                  |
| Apple Silicon Top  | asitop          | Alias to _sudo asitop_                |
| Chezmoi Change Dir | chezcd          | Alias for changing to chezmoi folder  |
| Reverse Paged Cat  | mcat            | Function - does a reverse paged cat   |
| Vim File Picker    | vf              | Function - opens selected file in vim |
