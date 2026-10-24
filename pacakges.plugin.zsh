# ====================================================
# CONFIGURABLE & EXTENSIBLE PACKAGE MANAGER (packages)
# ====================================================
packages() {
  local config_file="$HOME/.packages_config"

  # Initialize default configuration if it does not exist
  if [ ! -f "$config_file" ]; then
    cat << 'EOF' > "$config_file"
# packages Configuration File
# ----------------------
# Format: manager_name|search_cmd|update_cmd|install_cmd|uninstall_cmd|enabled(true/false)
# Variables: {packages} represents the package name.

apt|apt search {packages} 2>/dev/null|sudo apt update && sudo apt full-upgrade -y|sudo apt install {packages} -y|sudo apt remove {packages} -y|true
flatpak|flatpak search {packages}|flatpak update -y|flatpak install flathub {packages} -y|flatpak uninstall {packages} -y|true
snap|snap search {packages} 2>/dev/null|sudo snap refresh|sudo snap install {packages}|sudo snap remove {packages}|true
cargo|cargo search {packages}|cargo install-update -a|cargo install {packages}|cargo uninstall {packages}|true
pipx|pipx search {packages} 2>/dev/null|pipx upgrade-all|pipx install {packages}|pipx uninstall {packages}|true
npm|npm search {packages}|npm update -g|sudo npm install -g {packages}|sudo npm uninstall -g {packages}|false
brew|brew search {packages}|brew update && brew upgrade|brew install {packages}|brew uninstall {packages}|false
pacman|pacman -Ss {packages}|sudo pacman -Syu --noconfirm|sudo pacman -S {packages} --noconfirm|sudo pacman -R {packages} --noconfirm|false
dnf|dnf search {packages}|sudo dnf upgrade -y|sudo dnf install {packages} -y|sudo dnf remove {packages} -y|false
zypper|zypper search {packages}|sudo zypper update -y|sudo zypper install {packages} -y|sudo zypper remove {packages} -y|false
EOF
    echo "Created default configuration file at $config_file"
  fi

  case "$1" in
    config)
      case "$2" in
        enable)
          if [ -z "$3" ]; then echo "Usage: packages config enable <manager>"; return 1; fi
          sed -i "s/^$3|\(.*\)|false$/$3|\1|true/" "$config_file"
          echo "Enabled '$3'."
          ;;
        disable)
          if [ -z "$3" ]; then echo "Usage: packages config disable <manager>"; return 1; fi
          sed -i "s/^$3|\(.*\)|true$/$3|\1|false/" "$config_file"
          echo "Disabled '$3'."
          ;;
        add)
          if [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ -z "$7" ]; then
            echo "Usage: packages config add <name> \"<search_cmd>\" \"<update_cmd>\" \"<install_cmd>\" \"<uninstall_cmd>\""
            echo "Example: packages config add yarn \"yarn search {packages}\" \"yarn global upgrade\" \"yarn global add {packages}\" \"yarn global remove {packages}\""
            return 1
          fi
          echo "$3|$4|$5|$6|$7|true" >> "$config_file"
          echo "Added new package manager '$3'."
          ;;
        list)
          echo "=== Configured Package Managers ==="
          printf "%-10s %-8s %-10s\n" "MANAGER" "STATUS" "INSTALLED"
          echo "----------------------------------"
          while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
            [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
            local is_installed="no"
            command -v "$name" >/dev/null 2>&1 && is_installed="yes"
            printf "%-10s %-8s %-10s\n" "$name" "$enabled" "$is_installed"
          done < "$config_file"
          ;;
        edit)
          ${EDITOR:-nano} "$config_file"
          ;;
        *)
          echo "Usage: packages config <enable|disable|add|list|edit>"
          ;;
      esac
      ;;

    search)
      if [ -z "$2" ]; then echo "Usage: packages search <package_name>"; return 1; fi
      echo "🔍 Searching for '$2'..."
      while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
        [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
        if [ "$enabled" = "true" ] && command -v "$name" >/dev/null 2>&1; then
          echo -e "\n=== [$name] ==="
          eval "${search_cmd//\{packages\}/$2}"
        fi
      done < "$config_file"
      ;;

    update|upgrade)
      echo "🚀 Updating enabled package managers..."
      while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
        [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
        if [ "$enabled" = "true" ] && command -v "$name" >/dev/null 2>&1; then
          echo -e "\n=== [$name] ==="
          eval "$update_cmd"
        fi
      done < "$config_file"
      ;;

    install)
      shift
      local manager=""
      local package=""

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -g|--manager) manager="$2"; shift 2 ;;
          *) package="$1"; shift ;;
        esac
      done

      if [ -z "$package" ]; then
        echo "Usage: packages install [-g <manager>] <package_name>"
        return 1
      fi

      if [ -n "$manager" ]; then
        local found=false
        while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
          [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
          if [ "$name" = "$manager" ]; then
            found=true
            if command -v "$name" >/dev/null 2>&1; then
              eval "${install_cmd//\{packages\}/$package}"
            else
              echo "Error: Binary '$name' is not installed on this system."
            fi
            break
          fi
        done < "$config_file"
        $found || echo "Error: Manager '$manager' not found in configuration."
      else
        echo "Installing '$package' using automatic priority cascade..."
        while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
          [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
          if [ "$enabled" = "true" ] && command -v "$name" >/dev/null 2>&1; then
            echo "Attempting installation via $name..."
            if eval "${install_cmd//\{packages\}/$package}" 2>/dev/null; then
              echo "Successfully installed '$package' via $name!"
              return 0
            fi
          fi
        done < "$config_file"
        echo "Failed to install '$package' automatically."
      fi
      ;;

    uninstall|remove)
      shift
      local manager=""
      local package=""

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -g|--manager) manager="$2"; shift 2 ;;
          *) package="$1"; shift ;;
        esac
      done

      if [ -z "$package" ]; then
        echo "Usage: packages uninstall [-g <manager>] <package_name>"
        return 1
      fi

      if [ -n "$manager" ]; then
        local found=false
        while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
          [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
          if [ "$name" = "$manager" ]; then
            found=true
            if command -v "$name" >/dev/null 2>&1; then
              eval "${uninstall_cmd//\{packages\}/$package}"
            else
              echo "Error: Binary '$name' is not installed on this system."
            fi
            break
          fi
        done < "$config_file"
        $found || echo "Error: Manager '$manager' not found in configuration."
      else
        echo "Attempting to uninstall '$package' across enabled managers..."
        local uninstalled=false
        while IFS='|' read -r name search_cmd update_cmd install_cmd uninstall_cmd enabled; do
          [[ "$name" =~ ^#.* ]] || [ -z "$name" ] && continue
          if [ "$enabled" = "true" ] && command -v "$name" >/dev/null 2>&1; then
            echo "Checking $name..."
            if eval "${uninstall_cmd//\{packages\}/$package}" 2>/dev/null; then
              echo "Successfully uninstalled '$package' via $name!"
              uninstalled=true
              break
            fi
          fi
        done < "$config_file"
        $uninstalled || echo "Could not find or uninstall '$package' automatically."
      fi
      ;;

    *)
      echo "=== Universal Package Manager (packages) ==="
      echo "Usage:"
      echo "  packages search <name>                         - Search across enabled managers"
      echo "  packages update                                - Update enabled managers"
      echo "  packages install <name>                        - Auto-install following configuration priority"
      echo "  packages install -g <manager> <package_name>   - Force installation via specific manager"
      echo "  packages uninstall <name>                      - Auto-uninstall across enabled managers"
      echo "  packages uninstall -g <manager> <package_name> - Force uninstallation via specific manager"
      echo "  packages config list                           - View manager statuses"
      echo "  packages config enable/disable <manager>       - Enable or disable a manager"
      echo "  packages config add <args...>                  - Dynamically register a new manager"
      echo "  packages config edit                           - Open raw config file in editor"
      ;;
  esac
}
