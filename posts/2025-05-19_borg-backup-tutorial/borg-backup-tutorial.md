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

For more information about `borg create` visit
https://borgbackup.readthedocs.io/en/stable/usage/create.html

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

- `--keep-daily=7`: Keep the most recent 7 daily backups.
- `--keep-weekly=4`: Keep the most recent 4 weekly backups.
- `--keep-monthly=6`: Keep the most recent 6 monthly backups.

So after running this command:

- You’ll have up to 7 daily backups from the last 7 days.
- Up to 4 weekly backups (from the past 4 weeks).
- Up to 6 monthly backups (from the past 6 months).
- Older archives beyond this retention policy will be deleted to save
  space.

## Automating Backups with a Script

You can create a script to automate backups:

<div class="code-with-filename">

**Terminal**

``` bash
$ vim ~/bin/borg-backup.sh
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

For regular backups, you should create a `systemd service` as well as a
`systemd timer`.

## Arch Linux Daily Backups

For the interested, here are the files that I use for daily backups of
`$HOME`:

<div class="code-with-filename">

**~/bin/backup-home.sh**

``` bash
#!/bin/bash

echo "$(date "+%Y-%m-%d %H:%M:%S") Starting backup" >> /home/bd/logs/borg-backup.log

# Set variables
REPO="borg@192.168.178.172:/volume1/home-backup"
HOSTNAME="$(hostname)"
ARCHIVE="${HOSTNAME}-$(date +%Y-%m-%d_%H:%M:%S)"

# Default to real run
DRY_RUN=""
LIST_BACKUPS=false
SHOW_HELP=false
PRUNE_BACKUPS=false
DELETE_ARCHIVE=""

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Home directory backup script using Borg."
    echo ""
    echo "OPTIONS:"
    echo "  -n, --dry-run       Perform a dry run (no data will be written)"
    echo "  -l, --list          List all backups in the repository"
    echo "  -p, --prune         Prune old backups (keeps: 7 daily, 4 weekly, 12 monthly)"
    echo "  -d, --delete ARCH   Delete a specific archive by name"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  Run normal backup"
    echo "  $0 --dry-run        Test backup without writing data"
    echo "  $0 --list           Show all existing backups"
    echo "  $0 --prune          Remove old backups according to retention policy"
    echo "  $0 --delete arch123 Delete specific archive named 'arch123'"
    echo ""
}

# Parse arguments
i=1
while [[ $i -le $# ]]; do
    arg="${!i}"
    if [[ "$arg" == "--dry-run" || "$arg" == "-n" ]]; then
        DRY_RUN="--dry-run --list"
        echo "Running in dry-run mode (no data will be written)..."
    elif [[ "$arg" == "--list" || "$arg" == "-l" ]]; then
        LIST_BACKUPS=true
    elif [[ "$arg" == "--prune" || "$arg" == "-p" ]]; then
        PRUNE_BACKUPS=true
    elif [[ "$arg" == "--delete" || "$arg" == "-d" ]]; then
        ((i++))
        if [[ $i -le $# ]]; then
            DELETE_ARCHIVE="${!i}"
        else
            echo "Error: --delete requires an archive name"
            exit 1
        fi
    elif [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        SHOW_HELP=true
    else
        echo "Unknown option: $arg"
        echo "Use --help for usage information"
        exit 1
    fi
    ((i++))
done

# If help option is used, show help and exit
if [[ "$SHOW_HELP" == true ]]; then
    show_help
    exit 0
fi

# If list option is used, show backups and exit
if [[ "$LIST_BACKUPS" == true ]]; then
    echo "Listing backups in repository..."
    borg list "${REPO}"
    exit 0
fi

# If prune option is used, prune backups and exit
if [[ "$PRUNE_BACKUPS" == true ]]; then
    echo "Pruning old backups..."
    echo "Retention policy: 7 daily, 4 weekly, 12 monthly"
    borg prune --list --stats \
        --keep-daily=7 \
        --keep-weekly=4 \
        --keep-monthly=12 \
        "${REPO}"
    echo "Pruning completed."
    exit 0
fi

# If delete option is used, delete specific archive and exit
if [[ -n "$DELETE_ARCHIVE" ]]; then
    echo "Deleting archive: $DELETE_ARCHIVE"
    read -p "Are you sure you want to delete archive '$DELETE_ARCHIVE'? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        borg delete "${REPO}::${DELETE_ARCHIVE}"
        echo "Archive '$DELETE_ARCHIVE' deleted."
    else
        echo "Deletion cancelled."
    fi
    exit 0
fi

mkdir -p ~/pkg_backup
pacman -Qe > ~/pkg_backup/pkglist.txt
pacman -Qm > ~/pkg_backup/aur-pkglist.txt
pacman -Qq > ~/pkg_backup/full-pkglist.txt

# Run Borg backup
borg create --stats --show-rc $DRY_RUN \
    "${REPO}::${ARCHIVE}" \
    ~ \
    --exclude ~/.cache \
    --exclude ~/.local/share/docker \
    --exclude ~/.local/share/Trash \
    --exclude ~/Bilder \
    --exclude ~/Downloads \
    --exclude '**/.cache' \
    --exclude '**/.thumbnails' \
    --exclude '**/node_modules' \
    --exclude '**/__pycache__' \
    --exclude '*.pyc' \
    --exclude '*.tmp' \
    --exclude '**/venv' \
    --exclude '**/.venv' \
    --exclude '**/env' \
    --exclude '**/.env' \
    --exclude '**/renv'; exit_code=${PIPESTATUS[0]}

# Check if the Borg command was successful
if [ $exit_code -eq 0 ]; then
  echo "$(date "+%Y-%m-%d %H:%M:%S") Backup completed successfully with exit code $exit_code!" >> /home/bd/logs/borg-backup.log
  exit 0
else
  echo "$(date "+%Y-%m-%d %H:%M:%S") Backup failed with exit code $exit_code!" >> /home/bd/logs/borg-backup.log
  exit 1
fi

```

</div>

<div class="code-with-filename">

**~/.config/systemd/user/borg-backup.service**

``` bash
[Unit]
Description=Run Borg Backup Script

[Service]
Type=oneshot
Environment="BORG_REPO=ssh://borg@192.168.178.172:/volume1/home-backup"
Environment="BORG_PASSPHRASE=xxxxxxXXXxxxxxxx"
ExecStart=/home/bd/bin/backup-home.sh
StandardOutput=append:/home/bd/logs/borg-backup.log
StandardError=inherit
```

</div>

<div class="code-with-filename">

**~/.config/systemd/user/borg-backup.service**

``` bash
[Unit]
Description=Run Borg Backup Daily

[Timer]
OnCalendar=10:00
Persistent=true

[Install]
WantedBy=timers.target

```

</div>

<div class="code-with-filename">

**Terminal**

``` bash
$ systemctl --user daemon-reload
$ systemctl --user restart borg-backup.timer
$ systemctl --user enable borg-backup.timer
```

</div>

## Interesting Fact

BorgBackup uses **content-defined chunking** for deduplication. This
means that even if a file is moved, renamed, or slightly changed,
unchanged data blocks are reused, saving massive amounts of space over
time compared to simple file-based backups.
