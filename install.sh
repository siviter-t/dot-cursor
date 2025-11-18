#!/bin/bash

# Install script for dot-cursor submodule
# This script adds the dot-cursor repository as a git submodule to .cursor

set -e

TARGET_DIR=".cursor"
REPO_ORG="${REPO_ORG:-siviter-t}"

REPO_URL="${1:-https://github.com/$REPO_ORG/dot-cursor.git}"

if [ -d "$TARGET_DIR" ]; then
    echo "$TARGET_DIR directory already exists."
    read -p "Do you want to overwrite it entirely? (y/n): " choice
    case "$choice" in
        y|Y )
            echo "Removing existing $TARGET_DIR directory..."
            rm -rf "$TARGET_DIR"
            ;;
        * )
            echo "Installation aborted."
            exit 1
            ;;
    esac
fi

echo "Adding dot-cursor as submodule to $TARGET_DIR..."
git submodule add "$REPO_URL" "$TARGET_DIR"

echo "Initializing submodule..."
git submodule update --init --recursive

echo "Installation complete! The dot-cursor repository is now available at $TARGET_DIR"
