#!/bin/bash

# Simple Ubuntu 24.04 Python Environment Fix
# This is a minimal fix for the pipx installation issue

echo "🔧 Simple Python Environment Fix for Ubuntu 24.04"
echo "================================================="

# Update package list and enable universe repository
echo "Updating package list and enabling universe repository..."
sudo apt update
sudo add-apt-repository universe -y
sudo apt update

# Try to install pipx from universe repository first
echo "Attempting to install pipx from repository..."
if sudo apt install -y pipx; then
    echo "✅ pipx installed from repository"
else
    echo "Repository installation failed, using alternative method..."
    
    # Install prerequisites
    sudo apt install -y python3-full python3-venv curl
    
    # Use the official pipx installer
    echo "Installing pipx using official installer..."
    curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 - --user
    python3 -m pip install --user --break-system-packages pipx
fi

# Ensure pipx is in PATH
echo "Setting up PATH..."
export PATH="$HOME/.local/bin:$PATH"
pipx ensurepath

# Update .bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install essential development tools
echo "Installing development tools..."
pipx install poetry
pipx install black
pipx install flake8
pipx install pytest

echo "✅ Setup complete!"
echo ""
echo "Please run: source ~/.bashrc"
echo "Or restart your terminal session."
echo ""
echo "Test with: poetry --version"
