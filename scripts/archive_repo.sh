#!/bin/bash

# Usage: ./archive_repo.sh <repo_name>
REPO_NAME=$1

if [ -z "$REPO_NAME" ]; then
    echo "Error: No repository name provided."
    echo "Usage: $0 <repo_name>"
    exit 1
fi

# Configuration
CACHE_DIR="$HOME/.cache/archived_repo"
SOURCE_REMOTE="odp:R/archived/$REPO_NAME"
export RESTIC_PASSWORD_FILE="$HOME/.restic_pass"
export RESTIC_PACK_SIZE=128
export RESTIC_REPOSITORY="rclone:ods:Backup/repos/restic-$REPO_NAME"
# export RESTIC_REPOSITORY="$HOME/.cache/archived_repo_test"
RESTIC_COMPRESSION=max

# Setup workspace
mkdir -p "$CACHE_DIR"

echo "--- Syncing $REPO_NAME to local cache ---"
rclone sync "$SOURCE_REMOTE" "$CACHE_DIR/$REPO_NAME" -P

# Enter the repo directory so the snapshot path is just "."
cd "$CACHE_DIR/$REPO_NAME" || exit 1

echo "--- Ensuring Repository is Initialized ---"
restic snapshots > /dev/null 2>&1 || restic init

echo "--- Starting Restic Backup ---"
if restic backup . --tag archived --tag "$REPO_NAME" --host "archived-repo"; then
    echo "--- Backup Successful. Latest Snapshot: ---"
    restic snapshots --latest 1
    rclone size "$CACHE_DIR"
    rclone size "ods:Backup/repos/restic-$REPO_NAME"
    
    echo "--- Running Integrity Check ---"
    if restic check --read-data-subset=1%; then
        echo "--- Check Passed. Purging Source ---"
        # Purge local cache (we are inside it, so we need to be careful)
        cd "$CACHE_DIR" || exit 1
        rclone purge "./$REPO_NAME" -i
        # Purge remote source
        rclone purge "$SOURCE_REMOTE" -i
    else
        echo "Error: Restic check failed. Source will not be purged."
        exit 1
    fi
else
    echo "Error: Restic backup failed. Source will not be purged."
    exit 1
fi
