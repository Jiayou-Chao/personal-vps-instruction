#!/usr/bin/env bash

# Add `0 18 * * 0 /home/ubuntu/projects/vps/scripts/maintainance/clean_cache.sh >> /home/ubuntu/logs/clean_cache.log 2>&1` to `crontab -e` to run this script every Sunday at 18:00 and log output to `/home/ubuntu/logs/clean_cache.log`.
# Ensure correct PATH and environment variables for Cron / non-interactive shells
export PATH="$HOME/.local/bin:$HOME/conda/bin:$PATH"

# Load NVM if present
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh" 2>/dev/null || true
fi

# Load Conda if present
if [ -f "$HOME/conda/etc/profile.d/conda.sh" ]; then
    . "$HOME/conda/etc/profile.d/conda.sh" 2>/dev/null || true
fi

echo "=== [$(date '+%Y-%m-%d %H:%M:%S')] Starting Home Directory Storage Cleanup ==="

# 1. VS Code & VS Code Server cleanup
VSCODE_PATHS=(
    "$HOME/.vscode/cli/servers"
    "$HOME/.vscode-server/cli/servers"
)

# Number of recent VS Code versions to keep
keep_vscode_count=2

for base_dir in "${VSCODE_PATHS[@]}"; do
    if [ -d "$base_dir" ]; then
        echo "Processing $base_dir..."
        
        # Clean up staging directories immediately
        find "$base_dir" -mindepth 1 -maxdepth 1 -name "*.staging" -exec rm -rf {} +
        
        # Keep the newest versions, delete the rest
        mapfile -t stable_dirs < <(find "$base_dir" -mindepth 1 -maxdepth 1 -type d -name "Stable-*" -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-)
        
        count=${#stable_dirs[@]}
        if [ "$count" -gt "$keep_vscode_count" ]; then
            echo "Found $count VS Code versions. Keeping the $keep_vscode_count newest versions..."
            for ((i=keep_vscode_count; i<count; i++)); do
                dir_to_delete="${stable_dirs[i]}"
                echo "Deleting old version: $dir_to_delete"
                rm -rf "$dir_to_delete"
            done
        else
            echo "Found $count VS Code versions. No cleanup needed."
        fi
    fi
done

# Clean VS Code cached extension VSIXs
for vsix_dir in "$HOME/.vscode-server/data/CachedExtensionVSIXs" "$HOME/.vscode/data/CachedExtensionVSIXs"; do
    if [ -d "$vsix_dir" ]; then
        echo "Cleaning $vsix_dir..."
        find "$vsix_dir" -mindepth 1 -delete 2>/dev/null || true
    fi
done

# 2. Package manager caches (pip, conda, npm)
if command -v pip &>/dev/null; then
    echo "Purging pip cache..."
    pip cache purge &>/dev/null || true
fi

if command -v conda &>/dev/null; then
    echo "Cleaning conda package & tarball cache..."
    conda clean --all -y &>/dev/null || true
fi

if command -v npm &>/dev/null; then
    echo "Cleaning npm cache..."
    npm cache clean --force &>/dev/null || true
fi

# 3. Claude CLI older versions (keeping only the newest version)
CLAUDE_VER_DIR="$HOME/.local/share/claude/versions"
if [ -d "$CLAUDE_VER_DIR" ]; then
    echo "Processing Claude CLI versions in $CLAUDE_VER_DIR..."
    # Sort files (versions) by modification time, newest first
    mapfile -t claude_vers < <(find "$CLAUDE_VER_DIR" -mindepth 1 -maxdepth 1 -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-)
    
    claude_count=${#claude_vers[@]}
    if [ "$claude_count" -gt 1 ]; then
        echo "Found $claude_count Claude CLI versions. Keeping the newest version..."
        for ((i=1; i<claude_count; i++)); do
            ver_to_delete="${claude_vers[i]}"
            echo "Deleting old Claude CLI version: $ver_to_delete"
            rm -f "$ver_to_delete"
        done
    else
        echo "Found $claude_count Claude CLI version(s). No cleanup needed."
    fi
fi

echo "=== [$(date '+%Y-%m-%d %H:%M:%S')] Cleanup finished successfully! ==="
