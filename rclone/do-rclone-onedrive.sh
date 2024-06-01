#!/bin/bash

echo "rclone sync"

if [[ -z "$RCLONE_CONFIG_PASS" ]]; then
  echo "Enter password:"
  read -s RCLONE_CONFIG_PASS
  export RCLONE_CONFIG_PASS
fi

config_dir="$HOME/Scripts"
base_dir="$HOME"
os=$(uname | perl -ne 'print lc')
filters_file="$config_dir/rclone-filters-$os.txt"
backup_dir1="$HOME/Rclone/Backups" 
backup_dir2="onedrive:Rclone/Backups" 

echo "Running: $os"
if [[ ! -f "$filters_file" ]]; then
  echo "Failed to find filters-file: $filters_file"
  exit 1
fi

rclone bisync \
  --check-access \
  --progress \
  --progress-terminal-title \
  --filters-file="$filters_file" "$@" \
  --verbose \
  --recover \
  --resilient \
  --backup-dir1 "$backup_dir1" \
  --backup-dir2 "$backup_dir2" \
  "$HOME" \
  onedrive:/   
