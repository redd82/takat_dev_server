#!/bin/bash

# Fix for Ubuntu 24.04 PEP 668 externally-managed-environment error
# Run this script if you encountered the pip install error

set -e

echo "🔧 Fixing Python environment for Ubuntu 24.04"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_status "Installing pipx for proper Python package management..."
sudo apt install -y python3-pipx python3-full

print_status "Ensuring pipx is in PATH..."
python3 -m pipx ensurepath

print_status "Installing development tools with pipx..."

# Install tools one by one to handle any errors gracefully
tools=(
    "black"
    "flake8" 
    "pylint"
    "mypy"
    "pytest"
    "jupyter"
    "ipython"
    "pre-commit"
    "poetry"
)

for tool in "${tools[@]}"; do
    echo "Installing $tool..."
    if pipx install "$tool"; then
        echo "✅ $tool installed successfully"
    else
        echo "⚠️  Failed to install $tool (may already be installed)"
    fi
done

print_status "Installing system Python packages via apt..."
sudo apt install -y \
    python3-requests \
    python3-pip

print_status "Setting up PATH..."
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc 2>/dev/null || true

echo ""
echo "🎉 Fix completed!"
echo ""
echo "Please run the following command to update your current session:"
echo "source ~/.bashrc"
echo ""
echo "Or close and reopen your terminal."
echo ""
echo "You can now:"
echo "- Use 'poetry' for project dependency management"
echo "- Use 'black', 'flake8', etc. for code quality tools"
echo "- Create virtual environments with 'python3 -m venv venv'"
echo "- Install project dependencies inside virtual environments"
