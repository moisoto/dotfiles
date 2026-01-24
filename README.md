# MoiSoto's Chezmoi dotfiles repository

This is my Chezmoi dotfiles repository.
It's intended to be easily used by other people who run macOS.

This will also be included as a submodule of a more detailed
macOS Initial-Dev-Setup Guide I currently use privately but
will publish soon.

## Using this repository

Install chezmoi if not already on your system:

```shell
brew install chezmoi
```

Initialize with this repo:

```shell
chezmoi init https://github.com/moisoto/dotfiles.git
```

Check how it will change your current configuration:

```shell
chezmoi diff
```

If you are satisfied with the changes, apply them:

```shell
chezmoi apply
```
