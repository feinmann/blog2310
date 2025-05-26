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

