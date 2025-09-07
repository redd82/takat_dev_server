# VS Code Remote-SSH Setup

## Prerequisites

- SSH access configured (see `ssh-configuration.md`)
- VS Code installed on your local machine
- SSH keys set up and working

## Install Remote-SSH Extension

### 1. Install Required Extensions

In VS Code, install these extensions:

- **Remote - SSH** (`ms-vscode-remote.remote-ssh`)
- **Remote - SSH: Editing Configuration Files** (`ms-vscode-remote.remote-ssh-edit`)
- **Remote Development** (`ms-vscode-remote.vscode-remote-extensionpack`) - Extension pack

Install via VS Code Command Palette:
1. Press `Ctrl+Shift+P`
2. Type "Extensions: Install Extensions"
3. Search for "Remote - SSH" and install

Or install via command line:
```powershell
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
```

## Configure Remote Connection

### 1. Access SSH Configuration

Method 1 - Command Palette:
1. Press `Ctrl+Shift+P`
2. Type "Remote-SSH: Open SSH Configuration File"
3. Select your SSH config file (usually `C:\Users\<username>\.ssh\config`)

Method 2 - Direct edit:
```powershell
code ~\.ssh\config
```

### 2. Add Your Server Configuration

Add this to your SSH config file:
```
Host mydevserver
    HostName your-server-ip-or-domain
    User devuser
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    # VS Code specific settings
    RemoteCommand none
    RequestTTY no
```

### 3. Connect to Remote Server

Method 1 - Command Palette:
1. Press `Ctrl+Shift+P`
2. Type "Remote-SSH: Connect to Host"
3. Select your server from the list

Method 2 - Remote Explorer:
1. Click the Remote Explorer icon in the sidebar
2. Expand "SSH Targets"
3. Click the folder icon next to your server

Method 3 - Status Bar:
1. Click the green remote indicator in the bottom-left corner
2. Select "Connect to Host"
3. Choose your server

## Install Extensions on Remote Server

### Essential Extensions for Python Development

Once connected to your remote server, install these extensions:

**Python Development:**
- Python (`ms-python.python`)
- Pylance (`ms-python.vscode-pylance`)
- Python Debugger (`ms-python.debugpy`)
- Jupyter (`ms-toolsai.jupyter`)

**Code Quality:**
- Black Formatter (`ms-python.black-formatter`)
- Flake8 (`ms-python.flake8`)
- MyPy Type Checker (`ms-python.mypy-type-checker`)

**General Development:**
- GitLens (`eamodio.gitlens`)
- Git Graph (`mhutchie.git-graph`)
- Thunder Client (`rangav.vscode-thunder-client`) - for API testing
- REST Client (`humao.rest-client`)

**Productivity:**
- Auto Rename Tag (`formulahendry.auto-rename-tag`)
- Bracket Pair Colorizer 2 (`CoenraadS.bracket-pair-colorizer-2`)
- Path Intellisense (`christian-kohler.path-intellisense`)
- TODO Highlight (`wayou.vscode-todo-highlight`)

### Bulk Install Extensions

Create a script to install all extensions:
```bash
# On the remote server, create this script
cat > ~/install-vscode-extensions.sh << 'EOF'
#!/bin/bash

extensions=(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.debugpy"
    "ms-toolsai.jupyter"
    "ms-python.black-formatter"
    "ms-python.flake8"
    "ms-python.mypy-type-checker"
    "eamodio.gitlens"
    "mhutchie.git-graph"
    "rangav.vscode-thunder-client"
    "humao.rest-client"
    "formulahendry.auto-rename-tag"
    "CoenraadS.bracket-pair-colorizer-2"
    "christian-kohler.path-intellisense"
    "wayou.vscode-todo-highlight"
)

for ext in "${extensions[@]}"; do
    echo "Installing $ext..."
    code --install-extension "$ext"
done
EOF

chmod +x ~/install-vscode-extensions.sh
./install-vscode-extensions.sh
```

## Configure VS Code Settings for Remote Development

### 1. Remote Settings

Create or edit settings for the remote workspace:

```json
{
    "python.defaultInterpreterPath": "/usr/bin/python3",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": false,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length", "88"],
    "python.analysis.typeCheckingMode": "basic",
    "python.terminal.activateEnvironment": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "terminal.integrated.shell.linux": "/bin/bash",
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "workbench.colorTheme": "Dark+ (default dark)",
    "editor.minimap.enabled": false,
    "editor.lineNumbers": "on",
    "editor.rulers": [88],
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true
}
```

### 2. Workspace-Specific Settings

For each project, create `.vscode/settings.json`:
```json
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.analysis.extraPaths": ["./src"],
    "files.exclude": {
        "**/__pycache__": true,
        "**/*.pyc": true,
        "**/venv": true,
        "**/.pytest_cache": true
    }
}
```

## Set Up Development Workflow

### 1. Create Launch Configuration

Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: FastAPI",
            "type": "python",
            "request": "launch",
            "module": "uvicorn",
            "args": [
                "main:app",
                "--reload",
                "--host",
                "0.0.0.0",
                "--port",
                "8000"
            ],
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: Flask",
            "type": "python",
            "request": "launch",
            "program": "app.py",
            "env": {
                "FLASK_ENV": "development",
                "FLASK_DEBUG": "1"
            },
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "Python: Django",
            "type": "python",
            "request": "launch",
            "program": "manage.py",
            "args": [
                "runserver",
                "0.0.0.0:8000"
            ],
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}"
        }
    ]
}
```

### 2. Create Tasks Configuration

Create `.vscode/tasks.json`:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Install Dependencies",
            "type": "shell",
            "command": "pip install -r requirements.txt",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "python -m pytest",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Format Code",
            "type": "shell",
            "command": "black .",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Lint Code",
            "type": "shell",
            "command": "flake8 .",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
```

## Port Forwarding for Web Development

### Automatic Port Forwarding

VS Code automatically detects and forwards common ports (3000, 8000, 8080, etc.).

### Manual Port Forwarding

1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Remote-SSH: Port Forward"
3. Enter local port and remote port

Or use the Ports panel:
1. Open Terminal panel
2. Click "Ports" tab
3. Click "Add Port"
4. Enter port number

### Configure Port Forwarding in SSH Config

Add to your SSH config:
```
Host mydevserver
    # ... other settings ...
    LocalForward 8000 localhost:8000
    LocalForward 5432 localhost:5432
    LocalForward 3000 localhost:3000
```

## File Synchronization and Performance

### Optimize File Watching

Add to remote settings:
```json
{
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/venv/**": true,
        "**/__pycache__/**": true,
        "**/.pytest_cache/**": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/venv": true,
        "**/.git": true,
        "**/__pycache__": true
    }
}
```

### Git Configuration for Remote Development

Configure Git to work well with VS Code:
```bash
# On remote server
git config --global core.editor "code --wait"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
```

## Troubleshooting Remote Connections

### Common Issues

1. **Connection timeout:**
   - Check SSH configuration
   - Verify server is running
   - Check firewall settings

2. **Extensions not working:**
   - Reload window (`Ctrl+Shift+P` → "Developer: Reload Window")
   - Reinstall extensions on remote

3. **Slow performance:**
   - Exclude unnecessary files from watching
   - Increase connection timeout
   - Use compression in SSH config

4. **Git authentication issues:**
   - Set up SSH agent forwarding
   - Configure Git credentials

### Debug Connection Issues

Enable SSH debug logging:
```powershell
# In VS Code settings.json
{
    "remote.SSH.showLoginTerminal": true,
    "remote.SSH.logLevel": "debug"
}
```

Check VS Code logs:
1. Help → Toggle Developer Tools
2. Console tab for error messages

## Best Practices

1. **Use SSH agent forwarding** for Git operations
2. **Configure automatic reconnection** in SSH config
3. **Exclude large directories** from file watching
4. **Use workspace-specific settings** for different projects
5. **Set up consistent development environment** across team
6. **Regular backup** of SSH keys and configurations
7. **Monitor resource usage** on remote server
8. **Keep extensions updated** both locally and remotely

## Next Steps

After VS Code Remote-SSH is configured:
1. Set up your Python development environment (see `python-environment.md`)
2. Create your first remote project
3. Configure team development workflows
