# dot-cursor 🤖

A curated set of reusable rules, commands, and hooks designed to enhance the workflows of Software Engineers (and, let's be honest, me primarily).

It's intended to be added as a submodule to other repositories so that a single set may be curated.

For customization or adjustments for particular software houses or processes (e.g., job-specific versions), forking is recommended. Contributions back upstream are most welcome!

## Getting Started 🚀

### Adding as a Submodule

To add this repository as a submodule to your project:

**Using the install script:**

```bash
# Using curl (defaults to siviter-t/dot-cursor)
DOTCURSOR_REPO="siviter-t/dot-cursor" sh -c 'curl -LsSf https://raw.githubusercontent.com/$DOTCURSOR_REPO/main/install.sh | sh'

# Using wget (defaults to siviter-t/dot-cursor)
DOTCURSOR_REPO="siviter-t/dot-cursor" sh -c 'wget -qO- https://raw.githubusercontent.com/$DOTCURSOR_REPO/main/install.sh | sh'

# To use a different repository:
DOTCURSOR_REPO="your-org/dot-cursor" sh -c 'curl -LsSf https://raw.githubusercontent.com/$DOTCURSOR_REPO/main/install.sh | sh'
```

The script is executed directly from the pipe, so no files are written to disk and no cleanup is needed.

The install script will:
- Check if `.cursor` directory already exists
- Prompt to overwrite if it exists (declining will exit with error code 1)
- Add this repository as a git submodule to `.cursor`

**Manually using git commands:**

```bash
git submodule add https://github.com/siviter-t/dot-cursor.git .cursor
```

After adding, initialize and update submodules:

```bash
git submodule update --init --recursive
```

### Using a Symlink

Instead of adding as a submodule, you can create a symlink to the `dot-cursor` directory. This is useful for:
- Adding to repository directories without committing the submodule
- Linking to a local copy of `dot-cursor` stored elsewhere on disk
- Quick testing or development of the dot-cursor configuration

**Using the symlink script:**

```bash
# From within the dot-cursor directory
bash symlink.sh
```

The script will:
- Create a symlink from `../.cursor` pointing to the `dot-cursor` directory
- Prompt to replace if `.cursor` already exists as a symlink
- Error if `.cursor` exists as a non-symlink directory

**Manually creating a symlink:**

```bash
# From the repository root where you want .cursor
ln -s /path/to/dot-cursor .cursor
```

### Updating the Submodule

**Using the update script:**

```bash
bash .cursor/update.sh
```

The update script will:
- Check if submodule exists
- Update the submodule to latest
- Error if there are local changes, detailing how to commit them back upstream

**Manually using git commands:**

```bash
cd .cursor
git fetch origin
git pull origin main
cd ..
git add .cursor
git commit -m "Update .cursor submodule"
```

If you have local changes in the submodule that you want to contribute back:

```bash
cd .cursor
git checkout -b your-feature-branch
# Make your changes
git add .
git commit -m "Your changes"
git push origin your-feature-branch
# Create a pull request on the upstream repository
```

## Features ✨

- [Commands](commands/) - Reusable chat commands for common workflows
- [Rules](rules/) - Project-specific rules and guidelines
- [Hooks](hooks/README.md) - Pre-commit and pre-apply hooks for quality checks

Read the individual commands and rule sets for guidance on their intended purpose - filenames should be self-descriptive.

## Contributing 🤝

**Ways to contribute:**
- Add new commands or hooks that would be useful to others
- Improve existing commands with better prompts or structure
- Fix bugs or clarify documentation
- Suggest improvements via issues

**Process:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with a clear description

For job-specific or highly customized versions, consider maintaining your own fork whilst contributing useful improvements upstream.

## License 📄

MIT License - see [LICENSE](LICENSE) file for details.
