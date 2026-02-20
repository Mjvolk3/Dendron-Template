#!/bin/bash
# scripts/setup-worktree
# [[scripts.setup-worktree]]
# https://github.com/Mjvolk3/Dendron-Template/tree/main/scripts/setup-worktree

# PROJECT-SPECIFIC EDITS REQUIRED:
# 1. Update conda environment name - change "project-name" to your project name
# 2. Update config file paths - adjust to your project's config structure
# 3. Update mplstyle path - change "project-name.mplstyle" to your style file
# 4. Update verification message - change "project_name.__file__" to your package name
# 5. Remove/modify biocypher-specific paths if not using BioCypher

# One-command setup for new git worktrees

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
DATA_MODE="shared"  # default: share data with main repo

while [[ $# -gt 0 ]]; do
    case $1 in
        --data-local)
            DATA_MODE="local"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./scripts/setup-worktree.sh [--data-local]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Setting up worktree...${NC}"

# Get the main repo path dynamically (works across all devices/clusters)
# git rev-parse --git-common-dir returns the shared .git directory (always in main repo)
MAIN_REPO="$(cd "$(git rev-parse --git-common-dir)/.." && pwd)"
WORKTREE_DIR="$(pwd)"

echo -e "\n${BLUE}1. Setting up .env file (worktree-specific)...${NC}"

# Function to update env var paths
update_env_paths() {
    local env_file="$1"
    local data_mode="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed requires '' after -i
        sed -i '' "s|^ASSET_IMAGES_DIR=.*|ASSET_IMAGES_DIR=\"$WORKTREE_DIR/notes/assets/images\"|" "$env_file"
        sed -i '' "s|^EXPERIMENT_ROOT=.*|EXPERIMENT_ROOT=\"$WORKTREE_DIR/experiments\"|" "$env_file"
        sed -i '' "s|^WORKSPACE_DIR=.*|WORKSPACE_DIR=\"$WORKTREE_DIR\"|" "$env_file"
        # PROJECT-SPECIFIC: Update or remove these config paths based on your project
        sed -i '' "s|^BIOCYPHER_CONFIG_PATH=.*|BIOCYPHER_CONFIG_PATH=\"$WORKTREE_DIR/biocypher/config/linux-arm_biocypher_config.yaml\"|" "$env_file"
        sed -i '' "s|^SCHEMA_CONFIG_PATH=.*|SCHEMA_CONFIG_PATH=\"$WORKTREE_DIR/biocypher/config/schema_config.yaml\"|" "$env_file"
        sed -i '' "s|^MPLSTYLE_PATH=.*|MPLSTYLE_PATH=\"$WORKTREE_DIR/project-name/project-name.mplstyle\"|" "$env_file"

        # Update DATA_ROOT only if --data-local was specified
        if [[ "$data_mode" == "local" ]]; then
            sed -i '' "s|^DATA_ROOT=.*|DATA_ROOT=\"$WORKTREE_DIR\"|" "$env_file"
        fi
    else
        # Linux sed doesn't need '' after -i
        sed -i "s|^ASSET_IMAGES_DIR=.*|ASSET_IMAGES_DIR=\"$WORKTREE_DIR/notes/assets/images\"|" "$env_file"
        sed -i "s|^EXPERIMENT_ROOT=.*|EXPERIMENT_ROOT=\"$WORKTREE_DIR/experiments\"|" "$env_file"
        sed -i "s|^WORKSPACE_DIR=.*|WORKSPACE_DIR=\"$WORKTREE_DIR\"|" "$env_file"
        # PROJECT-SPECIFIC: Update or remove these config paths based on your project
        sed -i "s|^BIOCYPHER_CONFIG_PATH=.*|BIOCYPHER_CONFIG_PATH=\"$WORKTREE_DIR/biocypher/config/linux-arm_biocypher_config.yaml\"|" "$env_file"
        sed -i "s|^SCHEMA_CONFIG_PATH=.*|SCHEMA_CONFIG_PATH=\"$WORKTREE_DIR/biocypher/config/schema_config.yaml\"|" "$env_file"
        sed -i "s|^MPLSTYLE_PATH=.*|MPLSTYLE_PATH=\"$WORKTREE_DIR/project-name/project-name.mplstyle\"|" "$env_file"

        # Update DATA_ROOT only if --data-local was specified
        if [[ "$data_mode" == "local" ]]; then
            sed -i "s|^DATA_ROOT=.*|DATA_ROOT=\"$WORKTREE_DIR\"|" "$env_file"
        fi
    fi
}

if [ -f .env ] && [ ! -L .env ]; then
    echo "  ✓ .env file already exists (not a symlink)"
    echo "  → Updating worktree-specific paths..."
    update_env_paths ".env" "$DATA_MODE"
    echo "  ✓ Updated paths to point to worktree"
elif [ -L .env ]; then
    echo "  ! .env is a symlink - removing and creating worktree-specific copy"
    rm .env
    cp "$MAIN_REPO/.env" .env
    update_env_paths ".env" "$DATA_MODE"
    echo "  ✓ Created worktree-specific .env"
else
    echo "  → Creating new .env from main repo template..."
    cp "$MAIN_REPO/.env" .env
    update_env_paths ".env" "$DATA_MODE"
    echo "  ✓ Created worktree-specific .env"
fi

echo "  → Worktree-specific paths configured:"
echo "    - ASSET_IMAGES_DIR → $WORKTREE_DIR/notes/assets/images"
echo "    - EXPERIMENT_ROOT → $WORKTREE_DIR/experiments"
echo "    - WORKSPACE_DIR → $WORKTREE_DIR"

# Handle data storage based on mode
if [[ "$DATA_MODE" == "local" ]]; then
    echo -e "  → ${YELLOW}Data storage: LOCAL (worktree-specific)${NC}"
    echo "    - DATA_ROOT → $WORKTREE_DIR"
    echo "    - Datasets will be stored in this worktree's data/ directory"
    # Create local data directory structure
    mkdir -p "$WORKTREE_DIR/data"
else
    echo "  → Data storage: SHARED (symlinked to main repo)"
    echo "    - DATA_ROOT → $MAIN_REPO (unchanged)"

    # Create symlink to main repo's data directory
    if [ -L "$WORKTREE_DIR/data" ]; then
        echo "    - data/ symlink already exists"
    elif [ -d "$WORKTREE_DIR/data" ]; then
        echo -e "    - ${YELLOW}Warning: data/ directory exists (not a symlink)${NC}"
        echo "      To use shared data, remove it first: rm -rf data"
    else
        ln -s "$MAIN_REPO/data" "$WORKTREE_DIR/data"
        echo "    - Created symlink: data/ → $MAIN_REPO/data"
    fi
fi

echo -e "\n${BLUE}2. Verifying VS Code configs...${NC}"
if [ -f .vscode/launch.json ]; then
    echo "  ✓ launch.json exists"
else
    echo "  ✗ launch.json missing (should be tracked in git)"
fi

if [ -f .vscode/tasks.json ]; then
    echo "  ✓ tasks.json exists"
else
    echo "  ✗ tasks.json missing (should be tracked in git)"
fi

if [ -f .vscode/settings.json ]; then
    echo "  ✓ settings.json exists"
else
    echo "  ✗ settings.json missing (should be tracked in git)"
fi

echo -e "\n${BLUE}3. Verifying Python environment...${NC}"
# Check if conda environment exists - PROJECT-SPECIFIC: change "project-name" to your env name
if command -v conda &> /dev/null; then
    if conda env list | grep -q "^project-name "; then
        echo "  ✓ project-name conda environment exists"
        # Try to get Python path from conda
        CONDA_PYTHON=$(conda run -n project-name which python 2>/dev/null || echo "")
        if [ -n "$CONDA_PYTHON" ]; then
            echo "  → Python: $CONDA_PYTHON"
            conda run -n project-name python --version
        fi
    else
        echo "  ℹ project-name conda environment not found"
        echo "  → Create it with: conda create -n project-name python=3.13 -y"
    fi
else
    echo "  ℹ conda not found in PATH"
    echo "  → Python interpreter will be configured in VS Code settings"
fi

echo -e "\n${BLUE}4. Configuring VS Code for worktree...${NC}"
# Use VS Code settings to prioritize worktree over installed package
# This is safer than pip install -e which would break other worktrees

if [ ! -d .vscode ]; then
    mkdir -p .vscode
fi

# Check if settings.json needs PYTHONPATH update
if [ -f .vscode/settings.json ]; then
    if grep -q "python.envFile" .vscode/settings.json; then
        echo "  ✓ VS Code settings already configured"
    else
        echo "  ℹ VS Code settings exist but may need PYTHONPATH configuration"
        echo "  → Check .vscode/settings.json has 'python.envFile': '\${workspaceFolder}/.env.vscode'"
    fi
else
    echo "  ✗ .vscode/settings.json missing"
fi

# Create .env.vscode for PYTHONPATH override (if not exists)
if [ ! -f .env.vscode ]; then
    echo "  Creating .env.vscode with PYTHONPATH..."
    echo "PYTHONPATH=$WORKTREE_DIR:\${PYTHONPATH}" > .env.vscode
    echo "  ✓ Created .env.vscode"
else
    echo "  ✓ .env.vscode already exists"
fi

echo -e "\n${BLUE}5. Sharing Claude Code auto memory with main repo...${NC}"
# Claude Code stores per-project auto memory at ~/.claude/projects/<encoded-path>/memory/
# The encoding replaces / and . with - in the absolute path.
# Worktrees get separate memory dirs by default, but we want to share the main repo's memory.
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
MAIN_CLAUDE_DIR="$CLAUDE_PROJECTS_DIR/$(echo "$MAIN_REPO" | tr '/.' '-')"
WT_CLAUDE_DIR="$CLAUDE_PROJECTS_DIR/$(echo "$WORKTREE_DIR" | tr '/.' '-')"
MAIN_MEMORY="$MAIN_CLAUDE_DIR/memory"
WT_MEMORY="$WT_CLAUDE_DIR/memory"

# Ensure main repo memory dir exists
mkdir -p "$MAIN_MEMORY"

if [ -L "$WT_MEMORY" ]; then
    echo "  ✓ memory/ symlink already exists → $(readlink "$WT_MEMORY")"
elif [ -d "$WT_MEMORY" ]; then
    # Real directory exists - check if empty (safe to replace) or has content
    if [ -z "$(ls -A "$WT_MEMORY")" ]; then
        rmdir "$WT_MEMORY"
        ln -s "$MAIN_MEMORY" "$WT_MEMORY"
        echo "  ✓ Replaced empty memory/ dir with symlink → $MAIN_MEMORY"
    else
        echo -e "  ${YELLOW}Warning: memory/ directory has content (not replacing)${NC}"
        echo "    To share memory, merge contents then: rm -rf $WT_MEMORY && ln -s $MAIN_MEMORY $WT_MEMORY"
    fi
else
    mkdir -p "$WT_CLAUDE_DIR"
    ln -s "$MAIN_MEMORY" "$WT_MEMORY"
    echo "  ✓ Created symlink: memory/ → $MAIN_MEMORY"
fi

echo -e "\n${BLUE}6. Installing pre-commit hooks...${NC}"
if command -v pre-commit &> /dev/null; then
    pre-commit install
    echo "  ✓ pre-commit hooks installed"
else
    echo "  ✗ pre-commit not found — install with: pip install pre-commit"
fi

echo -e "\n${GREEN}✓ Worktree setup complete!${NC}"
echo -e "\n${BLUE}How this works:${NC}"
echo "  - .env is COPIED (not symlinked) from main repo with worktree-specific overrides"
echo "  - Worktree-specific paths (tracked in git):"
echo "    • ASSET_IMAGES_DIR → worktree's notes/assets/images"
echo "    • EXPERIMENT_ROOT → worktree's experiments/"
echo "    • WORKSPACE_DIR → worktree root"
echo "    • Config paths → worktree versions"

if [[ "$DATA_MODE" == "local" ]]; then
    echo -e "  - ${YELLOW}Data storage: LOCAL${NC}"
    echo "    • DATA_ROOT → this worktree (datasets stored locally)"
    echo "    • Use this for dataset experimentation or isolated builds"
else
    echo "  - Data storage: SHARED"
    echo "    • DATA_ROOT → main repo (via .env, data/ symlinked)"
    echo "    • Datasets are shared across all worktrees (saves disk space)"
fi

echo "  - .env.vscode sets PYTHONPATH to prioritize this worktree's code"
echo "  - Claude Code auto memory symlinked to main repo (shared across worktrees)"
echo "  - Other worktrees and main repo are NOT affected"
echo -e "\n${BLUE}Quick start:${NC}"
echo "  - Open this folder in VS Code (or reload window)"
echo "  - Press F5 to debug (uses 'Python: Workspace Folder' config)"
echo "  - Press Cmd+Shift+P -> 'Tasks: Run Task' to see all available tasks"
echo -e "\n${BLUE}Verify worktree is active:${NC}"
echo "  python -c 'import project_name; print(project_name.__file__)'"
echo "  (should show path to this worktree, not main repo)"
