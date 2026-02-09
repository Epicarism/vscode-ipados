# Setting up a Mac Development Server for VSCode iPadOS

This guide explains how to configure your Mac to act as a backend development server for VSCode iPadOS. This allows you to run heavy compilations, language servers, and terminal sessions remotely while editing on your iPad.

## 1. Enabling SSH (Remote Login)

To allow the iPad to connect to your Mac, you need to enable the SSH service.

### macOS Ventura, Sonoma, and newer:
1. Open **System Settings**.
2. Navigate to **General** > **Sharing**.
3. Toggle the switch for **Remote Login** to **ON**.
4. Click the `i` (info) button next to Remote Login.
5. Ensure "Allow access for" is set to **All users** or includes your specific user account.
6. Note the command displayed at the top (e.g., `ssh user@192.168.1.15`). This contains your local IP address.

### macOS Monterey and older:
1. Open **System Preferences**.
2. Go to **Sharing**.
3. Check the box for **Remote Login** in the service list.

## 2. Setting up SSH Keys for Passwordless Authentication

For a seamless experience (and better security), set up SSH keys so you don't have to type your password every time.

### On your iPad (using a terminal app like Blink or Termius):
1. Generate a new key pair (if you haven't already):
   ```bash
   ssh-keygen -t ed25519 -C "ipad-key"
   ```
2. Copy the public key to your Mac. If `ssh-copy-id` is available:
   ```bash
   ssh-copy-id user@<mac-ip-address>
   ```
3. Alternatively, manually copy the content of `id_ed25519.pub` from your iPad and append it to `~/.ssh/authorized_keys` on your Mac.

### Verifying Key Auth:
Try connecting again. You should be logged in without a password prompt.

## 3. Installing Development Tools

Ensure your Mac has the necessary tools to build and run your projects.

### Homebrew (Package Manager)
If not installed, install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Xcode Command Line Tools
Essential for git, make, and compilers:
```bash
xcode-select --install
```

### Common Runtimes
Install the languages you plan to use:
```bash
# Node.js and NPM
brew install node

# Python
brew install python

# Go
brew install go

# Rust
brew install rust
```

## 4. Firewall Configuration

If you have the macOS Application Firewall enabled, ensure it allows incoming SSH connections.

1. Open **System Settings** > **Network** > **Firewall**.
2. Click **Options**.
3. Ensure **"Block all incoming connections"** is unchecked.
4. Ensure **"Remote Login"** (SSH) is allowed in the list of services.

**Note:** If you use a third-party firewall (like Little Snitch), make sure to allow incoming connections on port 22.

## 5. Testing Connection from iPad

1. Ensure both devices are on the same Wi-Fi network.
2. On your iPad, open your terminal or the VSCode application.
3. Initiate a connection:
   ```bash
   ssh <username>@<mac-ip-address>
   ```
4. If successful, you will see your Mac's terminal prompt.

## 6. Troubleshooting Common Issues

### Connection Refused
- **Cause:** SSH service is not running or blocked.
- **Fix:** Check **System Settings > Sharing > Remote Login** is ON. Check Firewall settings.

### Permission Denied (publickey, password)
- **Cause:** Wrong username or SSH key issues.
- **Fix:** Verify your username (run `whoami` on Mac). Check permissions on `~/.ssh/authorized_keys` (should be `600`) and `~/.ssh` (should be `700`).

### IP Address Changes
- **Cause:** DHCP assigned a new IP to your Mac.
- **Fix:** 
  - Set a **Static IP** for your Mac in your router settings.
  - OR use the Mac's local hostname (e.g., `daniel-macbook.local`). You can find this in the **Sharing** settings.

### Slow Connection
- **Cause:** DNS lookup timeouts.
- **Fix:** Set `UseDNS no` in `/etc/ssh/sshd_config` on the Mac (requires sudo/root access to edit). restart sshd after changing.