#!/bin/bash

# Install script for dot-cursor submodule
# This script adds the dot-cursor repository as a git submodule to .cursor

set -e

TARGET_DIR=".cursor"
DOTCURSOR_REPO="${DOTCURSOR_REPO:-siviter-t/dot-cursor}"
REPO_URL="${1:-https://github.com/$DOTCURSOR_REPO.git}"

# Check if .cursor already exists as a submodule or directory
if [ -d "$TARGET_DIR" ] || [ -f "$TARGET_DIR" ]; then
    # Check if it's a submodule - check multiple indicators (order matters)
    # Temporarily disable set -e for these checks
    set +e
    IS_SUBMODULE=0
    if [ -f "$TARGET_DIR/.git" ]; then
        IS_SUBMODULE=1
    fi
    if [ -d ".git/modules/$TARGET_DIR" ]; then
        IS_SUBMODULE=1
    fi
    if [ -f ".gitmodules" ] && grep -q "$TARGET_DIR" .gitmodules 2>/dev/null; then
        IS_SUBMODULE=1
    fi
    set -e
    
    if [ "$IS_SUBMODULE" = "1" ]; then
        echo "$TARGET_DIR exists as a submodule. Removing and replacing with $DOTCURSOR_REPO..."
        # Remove submodule properly
        set +e
        git submodule deinit -f "$TARGET_DIR" 2>/dev/null || true
        git rm -f "$TARGET_DIR" 2>/dev/null || true
        rm -rf ".git/modules/$TARGET_DIR" 2>/dev/null || true
        rm -rf "$TARGET_DIR" 2>/dev/null || true
        set -e
    else
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
fi

echo "Adding dot-cursor as submodule to $TARGET_DIR..."
git submodule add "$REPO_URL" "$TARGET_DIR"

echo "Initializing submodule..."
git submodule update --init --recursive

# Update to latest commit
echo "Updating to latest commit..."
cd "$TARGET_DIR"
git fetch origin
git checkout main 2>/dev/null || git checkout master 2>/dev/null || git checkout HEAD
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
cd ..

# Update parent repo to reference the new commit
git add "$TARGET_DIR"

echo "Installation complete! The dot-cursor repository is now available at $TARGET_DIR"
