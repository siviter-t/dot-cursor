#!/bin/bash

# Update script for dot-cursor submodule
# This script updates the .cursor submodule to the latest version

set -e

TARGET_DIR=".cursor"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: $TARGET_DIR directory does not exist."
    echo "Please install the submodule first using install.sh"
    exit 1
fi

cd "$TARGET_DIR"

# Check for local changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: Local changes detected in $TARGET_DIR"
    echo ""
    echo "You have uncommitted changes in the submodule. To update:"
    echo "1. Commit your changes: cd $TARGET_DIR && git add . && git commit -m 'Your changes'"
    echo "2. Push to your fork: git push origin your-branch"
    echo "3. Create a pull request to contribute back upstream"
    echo "4. Or stash changes: cd $TARGET_DIR && git stash"
    echo ""
    exit 1
fi

# Check if we're on a branch (not detached HEAD)
if git symbolic-ref -q HEAD > /dev/null; then
    CURRENT_BRANCH=$(git symbolic-ref -q HEAD --short)
    echo "Updating $TARGET_DIR from origin/$CURRENT_BRANCH..."
    git fetch origin
    git merge origin/"$CURRENT_BRANCH" || git pull origin "$CURRENT_BRANCH"
else
    echo "Warning: Submodule is in detached HEAD state."
    echo "Fetching latest from origin..."
    git fetch origin
    echo "To update, manually checkout a branch: cd $TARGET_DIR && git checkout main"
fi

cd ..

echo "Update complete!"
