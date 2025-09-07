# Remote Development Server Setup Guide

A comprehensive guide for setting up a remote development server running Ubuntu 24.04 for Python development, accessible via SSH from VS Code.

## Overview

This guide covers:
- Ubuntu 24.04 server configuration
- SSH setup and security
- Python development environment setup
- VS Code Remote-SSH extension configuration
- Best practices for remote development

## Prerequisites

- Ubuntu 24.04 server with root/sudo access
- VS Code installed on your local machine
- Basic familiarity with terminal/command line

## Quick Start

1. **Server Setup**: Run the provided setup script on your Ubuntu server
2. **SSH Configuration**: Configure SSH keys and connection
3. **VS Code Setup**: Install Remote-SSH extension and connect
4. **Python Environment**: Set up your Python development environment

## Documentation Structure

- `docs/server-setup.md` - Ubuntu server configuration
- `docs/ssh-configuration.md` - SSH setup and security
- `docs/vscode-remote.md` - VS Code Remote-SSH setup
- `docs/python-environment.md` - Python development environment
- `scripts/` - Automation scripts for setup
- `configs/` - Configuration files and templates

## Getting Started

Follow the setup guides in order:

1. [Server Setup](docs/server-setup.md)
2. [SSH Configuration](docs/ssh-configuration.md)
3. [VS Code Remote Setup](docs/vscode-remote.md)
4. [Python Environment Setup](docs/python-environment.md)

## Security Notes

- Always use SSH key authentication (disable password auth)
- Configure firewall properly
- Keep your system updated
- Use non-root user for development
- Consider using fail2ban for SSH protection
