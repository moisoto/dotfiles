# Chezmoi Configuration File Documentation

This chezmoi dotfiles repo requires some custom keys
to be present in the chezmoi.toml configuration files.

The usual location of the `chezmoi.toml` file is at
`~/.config/chezmoi` and the required files are:

```toml
[data.config.machine]
name  = "machine-name"
owner = "machine-owner"
role  = "machine-role"
id    = "machine-id"

[data.config.secrets]
gpg_key    = "default-short-gpg-key"
gpg_defkey = "default-long-gpg-key"
gemini_key = "put-your-gemini-apikey-here"
```

## Machine section fields

The fields in this section are used by some of this repo's chezmoi templates to
generate certain configurations only for specific machines, or machine owners.
For this we use the `owner` and `id` fields.

You can also use them if you plan to share your configuration files, to avoid
generation of configurations that are very specific to you.

**Here is a description of the fields:**

  * **name:** Identifies the machine name. The `cr_config.sh` script
will set this to the machine hostname, you can change this to your liking.
  * **owner:** Identifies the machine owner. The `cr_config.sh` script
will set this to the machine username, however it is recommended you set this
to something unique. It can be a mail address, reverse domain address, or even
an UUID.
  * **role:** Decribes the mahine role. Is set to a place-holder by `cr_config.sh`.
  * **id:** The purpose of this id to server as a unique id for the machine. Set by
`cr_config.sh` to the combination of fields name and owner separated by a dot.

## Secrets section

This section is intended to contain keys and secrets you don't want to include in your dotfiles.
It currently has keys for GPG and Google's Gemini.

They are used as follows:

* **gpg_key:** It will be used as default by some aliases/functions included in this repo.
* **gpg_defkey:** It's used in the GPG configuration file.
* **gemini_key:** Needed for Google's Gemini Coding Assistant.

