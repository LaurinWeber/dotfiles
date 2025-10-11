# CKAD Practice Environment Setup (WSL + Docker + Kind)

This guide sets up a terminal environment optimized for CKAD exam practice, including useful aliases and shortcuts for kubectl commands.

## Prerequisites

- WSL (Windows Subsystem for Linux) installed
- Docker installed and running
- kubectl installed
- Kind (Kubernetes in Docker) installed

## Setup Steps

### 1. Navigate to Home Directory

```bash
cd ~
```

### 2. Check Current Directory

```bash
pwd
```

*Note: Should be `/home/<your-username>` — not `/mnt/c/...`*

### 3. Create .bashrc File

```bash
touch ~/.bashrc
```

### 4. Open .bashrc in Nano

```bash
nano ~/.bashrc
```

Paste this configuration:

```bash
# ----- CKAD Practice Environment Setup -----
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kr='kubectl run'
alias krm='kubectl delete'
alias kn='kubectl config set-context --current --namespace'
export dry='--dry-run=client -o yaml'
export PS1='[\u@\h \W $(kubectl config current-context 2>/dev/null)]\$ '
```

Save and exit:
- `Ctrl + O` (save)
- `Enter`
- `Ctrl + X` (exit)

### 5. Fix Permissions (if needed)

```bash
sudo chown $USER:$USER ~/.bashrc
sudo chmod 644 ~/.bashrc
```

### 6. Reload .bashrc

```bash
source ~/.bashrc
```

### 7. Test Aliases

```bash
alias
k version
kg pods -A
kn default
echo $dry
```

## Verification

After completing the setup, you should see:
- Your prompt shows the current Kubernetes context
- All aliases are working correctly
- The `$dry` variable contains `--dry-run=client -o yaml`

## Quick Reference

### Aliases
- `k` - kubectl
- `kg` - kubectl get
- `kd` - kubectl describe
- `ka` - kubectl apply -f
- `kc` - kubectl create
- `kr` - kubectl run
- `krm` - kubectl delete
- `kn` - kubectl config set-context --current --namespace

### Environment Variables
- `$dry` - `--dry-run=client -o yaml` (useful for generating YAML manifests)

### Prompt Enhancement
Your terminal prompt will now display the current Kubernetes context, making it easy to see which cluster/namespace you're working with.

## CKAD Nano Editor Setup

This section configures Nano as your default editor with YAML-friendly settings for Kubernetes manifests.

### 1. Create `.nanorc` Configuration

```bash
nano ~/.nanorc
```

Paste:

```bash
# ----- Minimal CKAD Nano Configuration -----

set linenumbers      # Show line numbers
set tabstospaces     # Use spaces instead of tabs (YAML-safe)
set tabsize 2        # Indent with 2 spaces (Kubernetes style)
set softwrap         # Wrap long lines
set constantshow     # Show cursor position
```

Save and exit:
- `Ctrl + O`
- `Enter`
- `Ctrl + X`

### 2. Set Nano as Default Editor

```bash
echo "export EDITOR=nano" >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
echo $EDITOR
# Output: nano
```

### 3. Add Nano Alias

Open .bashrc:

```bash
nano ~/.bashrc
```

Add:

```bash
# Short alias for nano
alias n='nano'
```

Reload configuration:

```bash
source ~/.bashrc
```

Test:

```bash
n test.yaml
```

## CKAD tmux Setup (Swiss-German QWERTZ Layout)

This configuration enables efficient multitasking within a single terminal window — ideal for the CKAD exam, where only one shell is provided.  
It allows you to split the screen into multiple panes, navigate easily, and edit or monitor resources simultaneously.

### 1. Install tmux

```bash
sudo apt update
sudo apt install tmux -y
```

Verify installation:

```bash
tmux -V
# Example: tmux 3.4
```

### 2. Create .tmux.conf

```bash
nano ~/.tmux.conf
```

Paste:

```bash
# ----- CKAD tmux Configuration (Swiss-German QWERTZ) -----

# Enable mouse support
set -g mouse on

# Reduce key response delay
set -sg escape-time 0

# ---- Keyboard Adjustments for Swiss Layout ----
# Instead of " (Shift+2) for horizontal split, use 'h'
# Instead of % (Shift+5) for vertical split, use 'v'

unbind '"'
unbind %
bind h split-window -v      # horizontal split (stacked)
bind v split-window -h      # vertical split (side by side)

# Pane movement with Alt+arrow keys
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Pane resizing with Ctrl+Alt+arrow
bind -n C-M-Left resize-pane -L 3
bind -n C-M-Right resize-pane -R 3
bind -n C-M-Up resize-pane -U 1
bind -n C-M-Down resize-pane -D 1

# Reload tmux configuration
bind r source-file ~/.tmux.conf \; display-message "Reloaded tmux.conf"
```

Save and exit:
- `Ctrl + O`
- `Enter`
- `Ctrl + X`

### 3. Launch tmux

```bash
tmux
```

You'll now have a mouse-enabled, keyboard-friendly shell environment.

### 4. Key Bindings (Swiss-Friendly)

| Action | Shortcut |
|--------|----------|
| Split vertically (side by side) | `Ctrl + B`, then `v` |
| Split horizontally (stacked) | `Ctrl + B`, then `h` |
| Move between panes | `Alt + Arrow keys` |
| Resize panes | `Ctrl + Alt + Arrow keys` |
| Reload config | `Ctrl + B`, then `r` |
| Detach session | `Ctrl + B`, then `d` |
| Reattach session | `tmux attach` |
| Close pane | `exit` or `Ctrl + D` |
