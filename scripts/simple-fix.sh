#!/bin/bash

# Simple Ubuntu 24.04 Python Environment Fix
# This is a minimal fix for the pipx installation issue

echo "🔧 Simple Python Environment Fix for Ubuntu 24.04"
echo "================================================="

# Update package list
echo "Updating package list..."
sudo apt update

# Install essential Python packages
echo "Installing Python essentials..."
sudo apt install -y python3-full python3-venv python3-pip

# Install pipx using pip (the official way)
echo "Installing pipx..."
python3 -m pip install --user pipx

# Add pipx to PATH
echo "Setting up PATH..."
export PATH="$HOME/.local/bin:$PATH"
python3 -m pipx ensurepath

# Update .bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install essential development tools
echo "Installing development tools..."
python3 -m pipx install poetry
python3 -m pipx install black
python3 -m pipx install flake8
python3 -m pipx install pytest

echo "✅ Setup complete!"
echo ""
echo "Please run: source ~/.bashrc"
echo "Or restart your terminal session."
echo ""
echo "Test with: poetry --version"
