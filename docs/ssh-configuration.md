# SSH Configuration for Remote Development

## SSH Server Configuration

### 1. Configure SSH Server (on Ubuntu server)

Edit SSH configuration:
```bash
sudo nano /etc/ssh/sshd_config
```

Recommended settings:
```
# Change default port (optional but recommended for security)
Port 22

# Disable root login
PermitRootLogin no

# Enable public key authentication
PubkeyAuthentication yes

# Disable password authentication (after setting up keys)
PasswordAuthentication no

# Disable empty passwords
PermitEmptyPasswords no

# Disable X11 forwarding if not needed
X11Forwarding no

# Set login grace time
LoginGraceTime 120

# Maximum authentication attempts
MaxAuthTries 3

# Maximum sessions per connection
MaxSessions 10

# Allow specific users only
AllowUsers devuser

# Protocol version
Protocol 2
```

Restart SSH service:
```bash
sudo systemctl restart ssh
sudo systemctl enable ssh
```

### 2. Set Up SSH Keys

#### On your local Windows machine (PowerShell):

Generate SSH key pair:
```powershell
# Generate SSH key pair
ssh-keygen -t ed25519 -C "your.email@example.com"

# If ed25519 is not supported, use RSA
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

Default location: `C:\Users\<YourUsername>\.ssh\id_ed25519`

#### Copy public key to server:

**Option 1: Using ssh-copy-id (if available)**
```bash
ssh-copy-id devuser@your-server-ip
```

**Option 2: Manual copy**
```powershell
# Display your public key
Get-Content ~\.ssh\id_ed25519.pub

# Then SSH to server and add it manually
ssh devuser@your-server-ip
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key here
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
exit
```

**Option 3: Using SCP**
```powershell
scp ~\.ssh\id_ed25519.pub devuser@your-server-ip:~/
```

Then on the server:
```bash
mkdir -p ~/.ssh
cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
rm ~/id_ed25519.pub
```

### 3. Configure SSH Client (Windows)

Create SSH config file:
```powershell
# Create .ssh directory if it doesn't exist
mkdir ~\.ssh -Force

# Create/edit SSH config
notepad ~\.ssh\config
```

Add configuration:
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
```

### 4. Test SSH Connection

Test the connection:
```powershell
ssh mydevserver
```

You should be able to connect without entering a password.

## Advanced SSH Configuration

### SSH Agent Setup (Windows)

Start SSH agent and add your key:
```powershell
# Start SSH agent
Start-Service ssh-agent

# Add your private key
ssh-add ~\.ssh\id_ed25519

# List loaded keys
ssh-add -l
```

### Multiple SSH Keys

If you have multiple servers or GitHub accounts:
```
# ~/.ssh/config
Host devserver1
    HostName server1.example.com
    User devuser
    IdentityFile ~/.ssh/id_ed25519_server1

Host devserver2
    HostName server2.example.com
    User devuser
    IdentityFile ~/.ssh/id_ed25519_server2

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_work
```

### SSH Tunneling for Development

Forward local ports to remote services:
```bash
# Forward remote port 8000 to local port 8000
ssh -L 8000:localhost:8000 mydevserver

# Forward multiple ports
ssh -L 8000:localhost:8000 -L 5432:localhost:5432 mydevserver

# Background tunneling
ssh -f -N -L 8000:localhost:8000 mydevserver
```

## Security Enhancements

### 1. Install and Configure fail2ban

On the server:
```bash
sudo apt install -y fail2ban

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local
```

Configure SSH protection:
```ini
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
```

Start fail2ban:
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status sshd
```

### 2. Two-Factor Authentication (Optional)

Install Google Authenticator PAM module:
```bash
sudo apt install -y libpam-google-authenticator

# Set up for your user
google-authenticator
```

Configure SSH to use 2FA:
```bash
sudo nano /etc/pam.d/sshd
```

Add at the top:
```
auth required pam_google_authenticator.so
```

Edit SSH config:
```bash
sudo nano /etc/ssh/sshd_config
```

Add/modify:
```
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

Restart SSH:
```bash
sudo systemctl restart ssh
```

### 3. Port Knocking (Advanced)

Install knockd:
```bash
sudo apt install -y knockd
```

Configure port sequence:
```bash
sudo nano /etc/knockd.conf
```

Example configuration:
```ini
[options]
    UseSyslog

[openSSH]
    sequence    = 7000,8000,9000
    seq_timeout = 5
    command     = /sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn

[closeSSH]
    sequence    = 9000,8000,7000
    seq_timeout = 5
    command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
    tcpflags    = syn
```

## Troubleshooting SSH Issues

### Common Issues and Solutions

1. **Permission denied (publickey)**
   ```bash
   # Check key permissions
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

2. **Connection refused**
   ```bash
   # Check SSH service status
   sudo systemctl status ssh
   
   # Check firewall
   sudo ufw status
   ```

3. **Too many authentication failures**
   ```bash
   # Clear SSH agent
   ssh-add -D
   
   # Add specific key
   ssh-add ~/.ssh/id_ed25519
   ```

### Debug SSH Connection

Enable verbose output:
```powershell
ssh -v mydevserver
ssh -vv mydevserver  # More verbose
ssh -vvv mydevserver # Most verbose
```

Check server logs:
```bash
sudo tail -f /var/log/auth.log
```

## Next Steps

After SSH is configured:
1. Set up VS Code Remote-SSH extension (see `vscode-remote.md`)
2. Configure your development environment (see `python-environment.md`)

## SSH Best Practices

- Use strong SSH keys (ed25519 or RSA 4096-bit)
- Disable password authentication
- Use non-standard SSH port
- Implement fail2ban
- Regular key rotation
- Use SSH agent forwarding carefully
- Monitor SSH logs regularly
- Keep SSH server updated
