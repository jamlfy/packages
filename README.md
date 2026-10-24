# 📦 Universal Package Manager (`packages`)

A lightweight, fully customizable, and extensible **Zsh plugin/script** that unifies system package managers (`apt`, `pacman`, `dnf`), universal package formats (`flatpak`, `snap`, `nix`), language toolchains (`cargo`, `pipx`, `npm`, `brew`), and **Zsh plugin managers (`antigen`, `zinit`, `zplug`)** under a single, intuitive interface.

Never struggle to remember distinct CLI commands again. Search, update, install, and uninstall tools or shell plugins across your entire Linux ecosystem with one command.

---

## ✨ Features

- 🔍 **Universal Search:** Query all enabled package and plugin managers simultaneously.
- 🚀 **One-Command Upgrade:** Update all system packages, standalone apps, language binaries, and Zsh plugins (`antigen update`, `zinit update`, etc.) in a single sweep.
- 🎯 **Smart Priority Cascade:** Automatically attempts installation following a configurable priority order, or force a specific manager using `-g` / `--manager`.
- 🔌 **Native Zsh Plugin Support:** Integrates seamlessly with **Antigen**, **Oh My Zsh**, **Zinit**, **Zplug**, and other shell frameworks.
- 🗑️ **Universal Uninstallation:** Search and remove packages automatically across managers or target a specific one directly.
- ⚙️ **Fully Configurable (`~/.packages_config`):** Enable, disable, edit, or register brand-new custom package/plugin managers dynamically without modifying source code.

---

## 🚀 Installation

### Option 1: Using Antigen (Recommended)

Add `packages` to your `~/.zshrc` alongside your other Antigen bundles:

```zsh
antigen bundle jamlfy/packages@main

```

---

### Option 2: Using Oh My Zsh

1. Clone the repository into your Oh My Zsh custom plugins directory:
```zsh
git clone [https://github.com/jamlfy/packages.git](https://github.com/jamlfy/packages.git) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/packages

```


2. Add `packages` to your plugin array in `~/.zshrc`:
```zsh
plugins=(... packages)

```


3. Reload Zsh:
```zsh
source ~/.zshrc

```



---

### Option 3: Using Zinit

Add the following line to your `~/.zshrc`:

```zsh
zinit light jamlfy/packages

```

---

### Option 5: Manual Installation

1. Clone the repository anywhere on your system:
```zsh
git clone [https://github.com/jamlfy/packages.git](https://github.com/jamlfy/packages.git) ~/.local/share/packages

```


2. Source the plugin in your `~/.zshrc`:
```zsh
echo '[ -f "$HOME/.local/share/packages/packages.plugin.zsh" ] && source "$HOME/.local/share/packages/packages.plugin.zsh"' >> ~/.zshrc
source ~/.zshrc

```



---

## 📖 Usage Examples

### 🔍 Search Across All Managers

Search for a package across all enabled and loaded package/plugin managers:

```zsh
packages search discord

```

### 🚀 Update Everything

Update all enabled system package managers, flatpaks, snaps, CLI tools, and Zsh plugins:

```zsh
packages update

```

### 📥 Install Packages

**Automatic Mode:** Attempts installation following the priority cascade defined in `~/.packages_config`:

```zsh
packages install vlc

```

**Targeted Mode:** Specify the target package manager using `-g` or `--manager`:

```zsh
packages install -g flatpak spotify
packages install -g cargo ripgrep
packages install -g apt neovim
packages install -g antigen zsh-users/zsh-autosuggestions

```

### 🗑️ Uninstall Packages

**Automatic Mode:** Scans enabled managers and removes the package where found:

```zsh
packages uninstall vlc

```

**Targeted Mode:** Force uninstallation from a specific manager:

```zsh
packages uninstall -g flatpak spotify
packages remove -g apt neovim
packages uninstall -g antigen zsh-users/zsh-autosuggestions

```

---

## ⚙️ Configuration (`~/.packages_config`)

All configuration is automatically generated and managed in `~/.packages_config`.

### View Manager Statuses

Check which package/plugin managers are configured, enabled, and installed on your system:

```zsh
packages config list

```

### Enable or Disable Managers

Toggle managers on or off without editing code:

```zsh
packages config enable npm
packages config disable snap

```

### Add a Custom Package / Plugin Manager

Register new package managers dynamically using:
`packages config add <name> "<search_cmd>" "<update_cmd>" "<install_cmd>" "<uninstall_cmd>"`

*Example (Adding `yarn`):*

```zsh
packages config add yarn "yarn search {packages}" "yarn global upgrade" "yarn global add {packages}" "yarn global remove {packages}"

```

*Example (Adding `yay` for Arch/AUR):*

```zsh
packages config add yay "yay -Ss {packages}" "yay -Syu --noconfirm" "yay -S {packages} --noconfirm" "yay -R {packages} --noconfirm"

```

### Edit Configuration Directly

Open `~/.packages_config` in your default terminal text editor (`nano`, `vim`, etc.):

```zsh
packages config edit

```

---

## 🛠️ Configuration File Format

The `~/.packages_config` file uses a pipe-separated (`|`) structure:

```text
manager_name | search_cmd | update_cmd | install_cmd | uninstall_cmd | enabled

```

* **`{packages}`**: Dynamic variable replaced with the target package/plugin name.
* **`enabled`**: Set to `true` or `false` to include or exclude a manager from auto operations.
* **Priority:** Top-to-bottom order in `~/.packages_config` dictates the priority cascade during automatic operations.

---

## 📄 License

MIT License. See [LICENSE](https://www.google.com/search?q=LICENSE) for more information.
