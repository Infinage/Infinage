# dotfiles-winp

> A portable Windows development environment

This repository contains my personal setup for using Git Bash, `tmux`, `micromamba`, `nvim`, and other utilities on Windows. It's **completely portable**: you can drop it in a folder, configure Windows Terminal, and start working without installing a full Linux VM or WSL.

---

## Requirements

* [Git Bash Portable](https://git-scm.com/download/win)
* [Windows Terminal](https://aka.ms/terminal)
* Optional: `tmux` (packed as `tmux.tar.zst`)
* [Micromamba](https://github.com/mamba-org/micromamba-releases/releases/) for package management

---

## Setup Instructions

### 1. Windows Terminal Configuration

1. Open windows terminal
2. Insert the relevant snippets from: `winterm-settings\settings.json`

---

### 2. Folder Setup

Inside your Git Bash portable folder:

```text
nj/git/
├── home/
│   ├── .bashrc
│   └── .tmux.conf  # optional
└── bin/
    └── micromamba.exe
```

* Create `/home` to store configuration files.
* Copy `.bashrc` and `.tmux.conf` from this repo into `/home`.

---

### 3. Installing `tmux` (optional)

1. Decompress `tmux.tar.zst`:

```bash
zstd -d tmux.tar.zst
tar -xf tmux.tar
```

2. Copy contents into `/usr/bin` to make `tmux` available in Git Bash.

---

### 4. Install Micromamba

Download the latest [micromamba release](https://github.com/mamba-org/micromamba-releases/releases/) and place it in `~/bin`.

```bash
chmod +x ~/bin/micromamba
```

---

### 5. Create Development Environment

```bash
micromamba create -n dev
micromamba activate dev
```

> `.bashrc` assumes an environment named `dev`.

---

### 6. Install Essential Packages

```bash
micromamba install -n dev fzf zoxide neovim binutils cmake make \
    bat clang-tools gxx tealdeer
```

* You can add any extra tools you like.
* For packages unavailable via `conda`, check [MSYS2 packages](https://repo.msys2.org/).
* Self update & all packages: `micromamba self-update && micromamba update --all`

---

### 7. `.bashrc` Features

* XDG directory structure in `$HOME`
* Auto-download of `vim-plug` for Neovim
* `fzf` + `zoxide` integration for fast navigation
* `tmux` integration with popups and notifications
* Activates `dev` environment automatically
* Configures `fzf` and `zoxide` in Bash

> Most of the Linux workflow now works on Windows through Git Bash + Micromamba.

---

### 8. Cleanup

* To remove everything, delete the `nj/git` folder.
* Portable: no system-wide changes.
