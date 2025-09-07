#!/bin/bash

# Ubuntu 24.04 Remote Development Server Setup Script (No Firewall)
# Run this script on your Ubuntu server as a regular user (not root)
# This version skips firewall configuration for safety

set -e  # Exit on any error

echo "🚀 Starting Ubuntu 24.04 Remote Development Server Setup (No Firewall)"
echo "======================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

print_warning "This version skips firewall configuration for safety."
print_warning "You should configure UFW manually after the setup is complete."
echo ""

# Update system
print_status "Updating system packages and enabling universe repository..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y
sudo add-apt-repository universe -y
sudo apt update

# Install essential development tools
print_status "Installing essential development tools..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    htop \
    vim \
    nano \
    unzip \
    tree \
    jq

# Install Python and development tools
print_status "Installing Python development tools..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel \
    python3-full

# Install pipx from universe repository (Ubuntu 24.04 compatible)
print_status "Installing pipx from universe repository..."
if sudo DEBIAN_FRONTEND=noninteractive apt install -y pipx; then
    print_status "pipx installed successfully from repository"
    pipx ensurepath
    export PATH="$HOME/.local/bin:$PATH"
    PIPX_AVAILABLE=true
else
    print_warning "pipx repository installation failed, will use system packages"
    PIPX_AVAILABLE=false
fi

# Install Poetry for Python package management
print_status "Installing Poetry..."
if [ "$PIPX_AVAILABLE" = true ] && command -v pipx &> /dev/null; then
    pipx install poetry || sudo apt install -y python3-poetry
elif ! command -v poetry &> /dev/null; then
    # Try system package first, then fallback to official installer
    if ! sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-poetry; then
        curl -sSL https://install.python-poetry.org | python3 -
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# Install Node.js 20.x LTS
print_status "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Configure Git (prompt for user input)
print_status "Configuring Git..."
read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor "nano"

# Set up development directory structure
print_status "Creating development directory structure..."
mkdir -p ~/projects
mkdir -p ~/scripts
mkdir -p ~/.local/bin

# Install Python development tools
print_status "Installing Python development packages..."
if [ "$PIPX_AVAILABLE" = true ] && command -v pipx &> /dev/null; then
    print_status "Installing development tools via pipx..."
    pipx install black || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-black
    pipx install flake8 || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-flake8
    pipx install pylint || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-pylint
    pipx install mypy || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-mypy
    pipx install pytest || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-pytest
    pipx install jupyter || sudo DEBIAN_FRONTEND=noninteractive apt install -y python3-jupyter-core
    pipx install pre-commit || echo "pre-commit will be available via pip in virtual environments"
else
    print_status "Installing development tools via system packages..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        python3-black \
        python3-flake8 \
        python3-pylint \
        python3-mypy \
        python3-pytest \
        python3-jupyter-core
fi

# Install some packages via apt that are available
print_status "Installing additional Python packages via apt..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    python3-requests

# Increase file watchers for development tools
print_status "Configuring system for development..."
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Enable unattended upgrades for security
print_status "Enabling automatic security updates..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y unattended-upgrades
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

# Create useful aliases
print_status "Setting up useful aliases..."
cat >> ~/.bashrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Python aliases
alias python='python3'
alias pip='pip3'
alias py='python3'
alias venv='python3 -m venv'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# System aliases
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias ports='sudo netstat -tulpn'
alias processes='ps aux'
EOF

# Create development environment activation script
print_status "Creating development environment script..."
cat > ~/scripts/dev-env.sh << 'EOF'
#!/bin/bash
# Development environment setup script

echo "🐍 Python Development Environment"
echo "================================="

# Show Python version
echo "Python version: $(python3 --version)"
echo "Poetry version: $(poetry --version 2>/dev/null || echo 'Not installed')"
echo "Node.js version: $(node --version 2>/dev/null || echo 'Not installed')"

# Show system info
echo ""
echo "📊 System Information"
echo "===================="
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "CPU: $(nproc) cores"
echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $4 " available"}')"

echo ""
echo "Ready for development! 🚀"
EOF

chmod +x ~/scripts/dev-env.sh

# Create SSH key generation helper
print_status "Creating SSH key generation helper..."
cat > ~/scripts/generate-ssh-key.sh << 'EOF'
#!/bin/bash
# SSH key generation helper

echo "🔑 SSH Key Generation Helper"
echo "==========================="

read -p "Enter your email address: " email
read -p "Enter key name (default: id_ed25519): " keyname
keyname=${keyname:-id_ed25519}

# Generate SSH key
ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/$keyname

echo ""
echo "SSH key generated successfully!"
echo "Public key content:"
echo "==================="
cat ~/.ssh/$keyname.pub
echo ""
echo "Copy the above public key to your authorized_keys file or use:"
echo "ssh-copy-id -i ~/.ssh/$keyname.pub user@remote-server"
EOF

chmod +x ~/scripts/generate-ssh-key.sh

# Create project template script
print_status "Creating Python project template script..."
cat > ~/scripts/new-python-project.sh << 'EOF'
#!/bin/bash
# Python project template generator

if [ $# -eq 0 ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_DIR=~/projects/$PROJECT_NAME

echo "🐍 Creating Python project: $PROJECT_NAME"
echo "========================================="

# Create project directory
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Initialize Poetry project
poetry init --no-interaction --name $PROJECT_NAME

# Create project structure
mkdir -p src/$PROJECT_NAME tests docs scripts config
touch src/$PROJECT_NAME/__init__.py
touch tests/__init__.py
touch README.md
touch .env.example

# Create .gitignore
cat > .gitignore << 'GITEOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
venv/
env/
ENV/
.venv/
.env
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
.pytest_cache/
.coverage
htmlcov/
.tox/
.cache
nosetests.xml
coverage.xml
.mypy_cache/
.dmypy.json
dmypy.json
.ipynb_checkpoints
*.log
logs/
*.db
*.sqlite
tmp/
temp/
GITEOF

# Create basic main.py
cat > src/$PROJECT_NAME/main.py << 'PYEOF'
"""Main module for the application."""

def main():
    """Main function."""
    print(f"Hello from {PROJECT_NAME}!")

if __name__ == "__main__":
    main()
PYEOF

# Create basic test
cat > tests/test_main.py << 'TESTEOF'
"""Tests for main module."""
import pytest
from src.PROJECT_NAME.main import main

def test_main():
    """Test main function."""
    # Add your tests here
    assert True
TESTEOF

# Create README
cat > README.md << 'MDEOF'
# PROJECT_NAME

Description of your project.

## Setup

```bash
# Install dependencies
poetry install

# Activate virtual environment
poetry shell

# Run the application
python src/PROJECT_NAME/main.py

# Run tests
pytest
```

## Development

```bash
# Install development dependencies
poetry add --group dev pytest black flake8 mypy

# Format code
black src/ tests/

# Lint code
flake8 src/ tests/

# Type checking
mypy src/

# Run tests
pytest
```
MDEOF

# Replace PROJECT_NAME placeholders
sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" tests/test_main.py README.md

echo "Project $PROJECT_NAME created successfully in $PROJECT_DIR"
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. poetry install"
echo "3. poetry shell"
echo "4. Start coding!"
EOF

chmod +x ~/scripts/new-python-project.sh

# Display setup completion info
print_status "Setup completed successfully! 🎉"
echo ""
echo "=============================================="
echo "🎯 Next Steps:"
echo "=============================================="
echo "1. MANUALLY CONFIGURE FIREWALL:"
echo "   sudo ufw allow ssh"
echo "   sudo ufw enable"
echo ""
echo "2. CONFIGURE FAIL2BAN (optional):"
echo "   sudo apt install fail2ban"
echo "   sudo systemctl enable fail2ban"
echo "   sudo systemctl start fail2ban"
echo ""
echo "3. Set up SSH keys:"
echo "   Run: ~/scripts/generate-ssh-key.sh"
echo ""
echo "4. Configure SSH for remote access:"
echo "   - Edit /etc/ssh/sshd_config (see docs/ssh-configuration.md)"
echo "   - Copy your public key to authorized_keys"
echo ""
echo "5. Install VS Code Remote-SSH extension on your local machine"
echo ""
echo "6. Create your first Python project:"
echo "   Run: ~/scripts/new-python-project.sh myproject"
echo ""
echo "7. Check development environment:"
echo "   Run: ~/scripts/dev-env.sh"
echo ""
echo "=============================================="
echo "🔥 FIREWALL WARNING:"
echo "=============================================="
echo "This script skipped firewall configuration for safety."
echo "Please configure UFW manually:"
echo "1. sudo ufw allow ssh"
echo "2. sudo ufw enable"
echo "3. Make sure you can still connect via SSH!"
echo ""
echo "Your Ubuntu 24.04 development server is ready! 🚀"

# Source bashrc to apply aliases
source ~/.bashrc 2>/dev/null || true
