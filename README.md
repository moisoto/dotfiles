# MoiSoto's Chezmoi dotfiles repository

This is my Chezmoi dotfiles repository.
It's intended to be easily used by other people who run macOS.


This will also be included as a submodule of a more detailed
macOS Initial-Dev-Setup Guide I currently use privately but
will publish soon.

The scripts, aliases and functions contained in this repository's
files are meant to be used with a set of programs that are described
in the macOS-dev-setup Guide. If you are going to use this repo to
setup a new machine, it is recommended you use the guide instead, which
will use this repository as part of the instructions.

If you just want to use these scripts in your current machine, detailed
documentation will be comming soon.

## Using this repository

Install chezmoi if not already on your system:

```shell
brew install chezmoi
```

Initialize with this repo:

```shell
chezmoi init https://github.com/moisoto/dotfiles.git
```

## Change the remote

If you plan to use chezmoi to maintain your evolving set of
dotfiles it is recommended to create your own repository.

Assuming you used github to create a repository named _dotfiles_
use these commands to point to it:

```shell
# Go to chezmoi repo folder
chezmoi cd

# Point to your repository
GITHUB_USERNAME="your-github-account"
git remote set-url origin git@github.com:$GITHUB_USERNAME/dotfiles.git

# Push into your new repo
git branch -M main
git push -u origin main

# Check new remote
git remote -v
```

## Create your configuration file

The dotfiles on my repository use some entries from a
chezmoi.toml configuration file. You can generate the
file by running the following command:

```shell
# Go to chezmoi repo folder
chezmoi cd

# Create config file
./cr_config.sh
```
These entries will be described and explained in the detailed documentation.

## Apply configuration

Now you are ready to apply the configuration files to your machine.
But first let's check how what changes will be applied to your current configuration:

```shell
chezmoi diff
```

If you are satisfied with the changes, apply them:

```shell
chezmoi apply
```
