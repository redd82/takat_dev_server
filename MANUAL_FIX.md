# Manual Ubuntu 24.04 Python Environment Fix

If the scripts are not working, run these commands manually step by step:

## Step 1: Update system and install prerequisites
```bash
sudo apt update
sudo apt install -y python3-full python3-venv python3-pip
```

## Step 2: Install pipx using pip
```bash
python3 -m pip install --user pipx
```

## Step 3: Add pipx to PATH
```bash
export PATH="$HOME/.local/bin:$PATH"
python3 -m pipx ensurepath
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

## Step 4: Install essential development tools
```bash
python3 -m pipx install poetry
python3 -m pipx install black
python3 -m pipx install flake8
python3 -m pipx install pytest
python3 -m pipx install mypy
```

## Step 5: Reload your shell environment
```bash
source ~/.bashrc
```

## Step 6: Test the installation
```bash
poetry --version
black --version
```

## Alternative: Use system packages where available
If pipx continues to have issues, you can install some tools via apt:

```bash
sudo apt install -y python3-poetry python3-black python3-flake8 python3-pytest
```

## For new Python projects:
```bash
# Create project directory
mkdir ~/projects/myproject
cd ~/projects/myproject

# Initialize with poetry
poetry init

# Or create virtual environment manually
python3 -m venv venv
source venv/bin/activate
pip install your-packages
```
