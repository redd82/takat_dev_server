# Ubuntu 24.04 Server Setup for Remote Development

## Initial Server Configuration

### 1. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Create Development User
```bash
# Create a new user for development (replace 'devuser' with your preferred username)
sudo adduser devuser
sudo usermod -aG sudo devuser

# Switch to the new user
su - devuser
```

### 3. Install Essential Development Tools
```bash
sudo apt install -y \
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
```

### 4. Install Python and Development Tools
```bash
# Python 3.12 is included in Ubuntu 24.04 by default
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel

# Install poetry for Python package management
curl -sSL https://install.python-poetry.org | python3 -

# Add poetry to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Install Node.js (for additional tooling)
```bash
# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 6. Install Docker (Optional but recommended)
```bash
# Add Docker's official GPG key
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
```

### 7. Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

### 8. Set Up Development Directory Structure
```bash
mkdir -p ~/projects
mkdir -p ~/scripts
mkdir -p ~/.local/bin
```

### 9. Install Additional Python Tools
```bash
# Install commonly used Python development tools
pip3 install --user \
    black \
    flake8 \
    pylint \
    mypy \
    pytest \
    jupyter \
    ipython \
    requests \
    fastapi \
    uvicorn
```

### 10. Configure Timezone and Locale
```bash
sudo timedatectl set-timezone YOUR_TIMEZONE  # e.g., America/New_York
sudo locale-gen en_US.UTF-8
```

## Firewall Configuration

### Basic UFW Setup
```bash
# Enable UFW firewall
sudo ufw enable

# Allow SSH
sudo ufw allow ssh

# Allow specific port if SSH is on non-standard port
# sudo ufw allow 2222/tcp

# Check status
sudo ufw status
```

## Performance Tuning

### Increase File Watchers (for development tools)
```bash
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Configure Swap (if needed)
```bash
# Check current swap
sudo swapon --show

# Create swap file if none exists (adjust size as needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## System Monitoring Setup

### Install monitoring tools
```bash
sudo apt install -y \
    htop \
    iotop \
    nethogs \
    ncdu
```

## Automatic Updates Configuration

### Enable unattended upgrades for security updates
```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Next Steps

After completing this server setup:
1. Configure SSH access (see `ssh-configuration.md`)
2. Set up VS Code Remote-SSH (see `vscode-remote.md`)
3. Configure your Python development environment (see `python-environment.md`)

## Verification Commands

Run these commands to verify your setup:
```bash
# System info
lsb_release -a
python3 --version
pip3 --version
node --version
npm --version
git --version
docker --version

# Check services
sudo systemctl status ssh
sudo ufw status

# Check development tools
poetry --version
black --version
pytest --version
```
