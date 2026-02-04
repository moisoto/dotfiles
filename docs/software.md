# Corresponding Software

This chezmoi repository contains configuration files as well as
aliases, scripts and functions to simplify usage of several software
tools.

In this document you'll find installation instructions for them.

## Homebrew

To install the tools and utilities covered in this document you'll need to install [homebrew](brew.sh) in your system.

If not installed please use the following command:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

If you have homebrew installed already, it is recommended to make sure it is up to date:

```shell
# Update taps
brew update

# Upgrade formulae
brew upgrade
```

## GNU Privacy Guard

Some [aliased functions](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#gpg-utils) are provided for GPG.

To install GNU Privacy Guard via Homebrew:

```shell
brew install gpg
```

## TMUX & TMUXINATOR

The [alias muxinate and the muxi function](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#tmux--tmuxinator) work with TMUX & TMUXINATOR.

To install via Homebrew:

```shell
brew install tmux
brew install tmuxinator
```

## Todo-Txt

Some [aliases](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#aliases-for-todo-txt) are provided for todo-txt.

To install this utility use:

```shell
brew install todo-txt
```

## Klog Utility

Several [functions](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#functions-for-for-klog) are provided for the klog utility.

To install klog use:

```shell
brew install klog
```

## Warp Directory Plugin (wd via Oh-My-Zsh)

Some [aliases](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#aliases-for-wd) are provided for the Warp Diretory utility.

If you use Oh-My-Zsh just add the wd plugin on your .zshrc script.
For other types of installations please refer to the [GitHub Repository Documentation](https://github.com/mfaerevaag/wd/blob/master/README.md).

Example for wd, tmux and tmuxinator plugins:

```config
# Add this line after the original plugins variable asignation statement
plugins+=(wd tmux tmuxinator)
```

## EZA (ls command replacement)

[Aliases](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#aliases-for-ls--eza) for eza are also included in this repo. To Install eza:

```shell
brew install eza
```

## Fuzzy Finder (fzf)

Fuzzy Finder integration with vim has been included as a [function (vf)](https://github.com/moisoto/dotfiles/blob/main/docs/tools.md#other-aliases) and also via the [.vimrc](https://github.com/moisoto/dotfiles/blob/main/dot_vimrc) configuration file (plugin and autorun sections).
