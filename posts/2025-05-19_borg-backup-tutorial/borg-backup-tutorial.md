# BorgBackup Tutorial
3atthias 3erger
2025-05-19

## Introduction

[`borgbackup`](https://www.borgbackup.org/) (or simply `borg`) is a
powerful and secure deduplicating backup tool. It is particularly
suitable for daily backups of your home directory or any important data.
Borg compresses, encrypts, and stores data incrementally, making it both
space-efficient and secure.

## Installation

On **Arch Linux**, install BorgBackup from the official repositories:

<div class="code-with-filename">

**Terminal**

``` bash
$ sudo pacman -S borg
```

</div>

## Initializing a Backup Repository

To start using Borg, initialize a repository. This can be on a local
disk or a remote server via SSH.

### Local Repository

<div class="code-with-filename">

**Terminal**

``` bash
$ borg init --encryption=repokey-blake2 /path/to/backup/location
Enter new passphrase:
Enter same passphrase again:
Do you want your passphrase to be displayed for verification? [yN]:

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!

Key storage location depends on the mode:
- repokey modes: key is stored in the repository directory.
- keyfile modes: key is stored in the home directory of this user.

For any mode, you should:
1. Export the borg key and store the result at a safe place:
   borg key export           REPOSITORY encrypted-key-backup
   borg key export --paper   REPOSITORY encrypted-key-backup.txt
   borg key export --qr-html REPOSITORY encrypted-key-backup.html
2. Write down the borg key passphrase and store it at safe place.
```

</div>

### Remote Repository

<div class="code-with-filename">

**Terminal**

``` bash
$ borg init --encryption=repokey-blake2 user@remote-host:/path/to/backup/location
```

</div>

## Creating a Backup

Create a backup archive of your home directory while excluding
unnecessary directories:

<div class="code-with-filename">

**Terminal**

``` bash
$ borg create --stats --progress \
    --exclude ~/.cache \
    --exclude ~/.conda \
    --exclude ~/.julia \
    --exclude ~/.cargo \
    --exclude ~/.rustup \
    --exclude ~/.local \
    --exclude ~/Bilder \
    --exclude ~/.fastai \
    /path/to/repo::home-backup-{now:%Y-%m-%d_%H-%M} \
    /home/your-username
```

</div>

- `--stats`: shows summary statistics.
- `--progress`: shows progress during the backup.
- `--exclude`: avoids backing up unnecessary data.

## Listing Backup Archives

<div class="code-with-filename">

**Terminal**

``` bash
$ borg list /path/to/repo
```

</div>

## Extracting a Backup

Restore a specific archive:

<div class="code-with-filename">

**Terminal**

``` bash
$ borg extract /path/to/repo::home-backup-2025-05-19_14-30
```

</div>

You can also restore to a specific location:

<div class="code-with-filename">

**Terminal**

``` bash
$ borg extract --target /home/your-username/restore /path/to/repo::home-backup-2025-05-19_14-30
```

</div>

## Pruning Old Backups

To keep only recent backups:

<div class="code-with-filename">

**Terminal**

``` bash
$ borg prune -v --list /path/to/repo \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=6
```

</div>

## Automating Backups with a Script

You can create a script to automate backups:

<div class="code-with-filename">

**Terminal**

``` bash
$ nano ~/bin/borg-backup.sh
```

</div>

Content:

<div class="code-with-filename">

**borg-backup.sh**

``` bash
#!/bin/bash
export BORG_REPO="/path/to/repo"
export BORG_PASSPHRASE='your-passphrase'

borg create --stats --progress \
    --exclude ~/.cache \
    --exclude ~/.conda \
    --exclude ~/.julia \
    --exclude ~/.cargo \
    --exclude ~/.rustup \
    --exclude ~/.local \
    --exclude ~/Bilder \
    --exclude ~/.fastai \
    ::home-backup-{now:%Y-%m-%d_%H-%M} \
    /home/your-username

borg prune -v --list \
    --keep-daily=7 --keep-weekly=4 --keep-monthly=6
```

</div>

Make it executable:

<div class="code-with-filename">

**Terminal**

``` bash
$ chmod +x ~/bin/borg-backup.sh
```

</div>

## Using Borg in Fish Shell vs Bash

Borg commands are mostly shell-independent, but **Fish shell** does not
support some Bash syntax like `$VAR` without parentheses. To export
variables in Fish:

### Fish Shell:

<div class="code-with-filename">

**Terminal**

``` bash
> set -x BORG_REPO "/path/to/repo"
> set -x BORG_PASSPHRASE "your-passphrase"
> borg create ::archive-name /home/your-username
```

</div>

### Bash Shell:

<div class="code-with-filename">

**Terminal**

``` bash
$ export BORG_REPO="/path/to/repo"
$ export BORG_PASSPHRASE="your-passphrase"
$ borg create ::archive-name /home/your-username
```

</div>

## Interesting Fact

BorgBackup uses **content-defined chunking** for deduplication. This
means that even if a file is moved, renamed, or slightly changed,
unchanged data blocks are reused, saving massive amounts of space over
time compared to simple file-based backups.
