#!/bin/bash

script=$(realpath "$0")
script_dir=$(dirname "$script")
config_dir="$HOME/.config/rclone/filter-lists"
base_dir="$HOME"
os=$(uname | perl -ne 'print lc')
filters_file="$config_dir/rclone-filters-$os.txt"
backup_dir1="$HOME/Rclone/Backups" 
backup_dir2="onedrive:OnlineOnly/Rclone/Backups" 
filters_dir="$HOME/.config/rclone/filter-lists/"
bin_dir="$HOME/.local/bin"

if [[ "$1" == "self-install" ]]; then
  echo "Script path: $script"
  echo "Script dir: $script_dir"

  cp -v "$script" "$bin_dir"/rclone-onedrive
  chmod +x "$bin_dir"/rclone-onedrive
  mkdir -p "$filters_dir"
  cp -v "$script_dir"/rclone-filters-*.txt "$filters_dir"
  exit 0
fi

if [[ -z "$RCLONE_CONFIG_PASS" ]]; then
  echo "Enter password:"
  read -s RCLONE_CONFIG_PASS
  export RCLONE_CONFIG_PASS
fi

echo "Running: $os"
if [[ ! -f "$filters_file" ]]; then
  echo "Failed to find filters-file: $filters_file"
  exit 1
fi

echo "rclone sync"

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
