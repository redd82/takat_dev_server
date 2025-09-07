#!/bin/bash

# Fix for Ubuntu 24.04 PEP 668 externally-managed-environment error
# Run this print_status "Installing system Python packages..."
sudo apt install -y python3-requests

print_status "Setting up PATH..."
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrcif you encountered the pip install error

set -e

echo "🔧 Fixing Python environment for Ubuntu 24.04"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Installing prerequisites for Python package management..."
sudo apt update
sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y python3-full python3-venv python3-pip

print_status "Installing pipx from universe repository..."
if sudo apt install -y pipx; then
    print_status "pipx installed successfully from repository"
    pipx ensurepath
    export PATH="$HOME/.local/bin:$PATH"
    PIPX_AVAILABLE=true
else
    print_warning "pipx repository installation failed, using fallback method"
    # Fallback: install system packages
    sudo apt install -y python3-poetry python3-black python3-flake8 python3-pytest python3-mypy
    PIPX_AVAILABLE=false
fi

print_status "Installing development tools..."

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

if [ "$PIPX_AVAILABLE" = true ] && command -v pipx &> /dev/null; then
    for tool in "${tools[@]}"; do
        echo "Installing $tool via pipx..."
        if pipx install "$tool"; then
            echo "✅ $tool installed successfully"
        else
            echo "⚠️  Failed to install $tool via pipx, trying system package"
            case $tool in
                "poetry") sudo apt install -y python3-poetry ;;
                "black") sudo apt install -y python3-black ;;
                "flake8") sudo apt install -y python3-flake8 ;;
                "pylint") sudo apt install -y python3-pylint ;;
                "mypy") sudo apt install -y python3-mypy ;;
                "pytest") sudo apt install -y python3-pytest ;;
                "jupyter") sudo apt install -y python3-jupyter-core ;;
                *) echo "No system package available for $tool" ;;
            esac
        fi
    done
else
    print_status "Installing development tools via system packages..."
    sudo apt install -y 
        python3-poetry 
        python3-black 
        python3-flake8 
        python3-pylint 
        python3-mypy 
        python3-pytest 
        python3-jupyter-core
fi

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
