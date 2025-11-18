#!/bin/bash

# symlink.sh - Create a symlink from dot-cursor to .cursor in the parent directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$PARENT_DIR/.cursor"
SOURCE_DIR="$SCRIPT_DIR"

# Check if .cursor already exists
if [ -e "$TARGET_DIR" ]; then
    if [ -L "$TARGET_DIR" ]; then
        echo ".cursor already exists as a symlink pointing to: $(readlink "$TARGET_DIR")"
        read -p "Do you want to replace it? (y/n): " choice
        case "$choice" in
            y|Y )
                rm "$TARGET_DIR"
                ;;
            * )
                echo "Symlink creation aborted."
                exit 1
                ;;
        esac
    else
        echo "Error: .cursor already exists and is not a symlink."
        echo "Please remove it manually if you want to create a symlink."
        exit 1
    fi
fi

# Create the symlink
echo "Creating symlink from $TARGET_DIR -> $SOURCE_DIR"
ln -s "$SOURCE_DIR" "$TARGET_DIR"

echo "Symlink created successfully!"
echo "$TARGET_DIR -> $SOURCE_DIR"
