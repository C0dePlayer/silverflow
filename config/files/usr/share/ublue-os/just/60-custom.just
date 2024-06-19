# Install pdm (modern Python package and dependency manager) | https://pdm-project.org/latest/
install-pdm:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    curl -sSLO https://pdm-project.org/install-pdm.py
    curl -sSL https://pdm-project.org/install-pdm.py.sha256 | sha256sum -c -
    python3 install-pdm.py --path "${HOME}/pdm"

# Install conda with mamba (fast, robust, and cross-platform package manager) | https://mamba.readthedocs.io/en/latest/index.html
install-mamba:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    bash Miniforge3.sh -b

# Install JetBrains Toolbox | https://www.jetbrains.com/toolbox-app/
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    echo "Get latest JetBrains Toolbox version"
    # Get the json with latest releases
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    # Extract information
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    echo "Launching JetBrains Toolbox"
    ./jetbrains-toolbox-"${BUILD_VERSION}"/jetbrains-toolbox

# Removes pdm from the system
remove-pdm:
    #!/usr/bin/env bash
    pushd "$(mktemp -d)"
    curl -sSLO https://pdm-project.org/install-pdm.py
    curl -sSL https://pdm-project.org/install-pdm.py.sha256 | sha256sum -c -
    python3 install-pdm.py --path "${HOME}/pdm" --remove

# Removes conda and mamba from the system
remove-mamba:
    #!/usr/bin/env bash
    conda init --reverse
    CONDA_BASE_ENVIRONMENT=$(conda info --base)
    echo "The next command will delete all files in ${CONDA_BASE_ENVIRONMENT}"
    rm -rf ${CONDA_BASE_ENVIRONMENT}
    echo "${HOME}/.condarc will be removed if it exists"
    rm -f "${HOME}/.condarc"
    echo "${HOME}/.conda and underlying files will be removed if they exist"
    rm -rf ${HOME}/.conda

# Add additional boot parameters for hardening (requires reboot)
set-kargs-hardening ACTION="prompt":
    #!/usr/bin/env bash
    bold=$(tput bold)
    normal=$(tput sgr0)
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
      echo "${bold}Additional boot parameters for hardening${normal}"
      echo 'Press ESC to exit.'
      OPTION=$(ugum choose "Append" Delete)
    fi
    if [ "${OPTION,,}" == "append" ]; then
      rpm-ostree kargs \
        --append-if-missing="init_on_alloc=1" \
        --append-if-missing="init_on_free=1" \
        --append-if-missing="slab_nomerge" \
        --append-if-missing="page_alloc.shuffle=1" \
        --append-if-missing="randomize_kstack_offset=on" \
        --append-if-missing="vsyscall=none" \
        --append-if-missing="lockdown=confidentiality" \
        --append-if-missing="random.trust_cpu=off" \
        --append-if-missing="random.trust_bootloader=off" \
        --append-if-missing="iommu=force" \
        --append-if-missing="intel_iommu=on" \
        --append-if-missing="amd_iommu=force_isolation" \
        --append-if-missing="iommu.passthrough=0" \
        --append-if-missing="iommu.strict=1" \
        --append-if-missing="pti=on" \
        --append-if-missing="module.sig_enforce=1" \
        --append-if-missing="mitigations=auto,nosmt"
    elif [ "${OPTION,,}" == "delete" ]; then
      rpm-ostree kargs \
        --delete-if-present="init_on_alloc=1" \
        --delete-if-present="init_on_free=1" \
        --delete-if-present="slab_nomerge" \
        --delete-if-present="page_alloc.shuffle=1" \
        --delete-if-present="randomize_kstack_offset=on" \
        --delete-if-present="vsyscall=none" \
        --delete-if-present="lockdown=confidentiality" \
        --delete-if-present="random.trust_cpu=off" \
        --delete-if-present="random.trust_bootloader=off" \
        --delete-if-present="iommu=force" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="amd_iommu=force_isolation" \
        --delete-if-present="iommu.passthrough=0" \
        --delete-if-present="iommu.strict=1" \
        --delete-if-present="pti=on" \
        --delete-if-present="module.sig_enforce=1" \
        --delete-if-present="mitigations=auto,nosmt" \
        --delete-if-present="efi=disable_early_pci_dma" \
        --delete-if-present="debugfs=off"
    fi

# Configure GRUB screen with various options
configure-grub ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_STATE="Unhidden"
    if sudo grub2-editenv list | grep -q "menu_auto_hide=1"; then
      CURRENT_STATE="Hidden"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
    echo "${bold}Configuring GRUB${normal}"
    echo "GRUB screen is currently: ${bold}${CURRENT_STATE}${normal}"
    echo 'GRUB hiding option can be useful for making boot-times faster.'
    echo 'Hide or Unhide GRUB? Press ESC to exit.'
    OPTION=$(ugum choose "Unhide (Default)" Hide)
    elif [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-grub <option>"
      echo "  <option>: Specify the quick option - 'hide' or 'unhide'"
      echo "  Use 'hide' to hide GRUB boot screen."
      echo "  Use 'unhide' to revert to defaults."
      exit 0
    fi    
    if [ "${OPTION,,}" == "hide" ]; then
      if ! sudo grub2-editenv list | grep -q "menu_auto_hide=1"; then
        sudo grub2-editenv - set menu_auto_hide=1
        if [ -d /sys/firmware/efi ]; then
          output=$(sudo grub2-mkconfig -o /etc/grub2-efi.cfg 2>&1) || echo "$output" && false
              echo 'Hide UEFI GRUB logs during boot setting applied.'  
        else
          output=$(sudo grub2-mkconfig -o /etc/grub2.cfg 2>&1) || echo "$output" && false
              echo 'Hide BIOS GRUB logs during boot setting applied.'   
        fi
      else
        printf "\e[1;31mERROR: GRUB screen is already hidden, no change is made.\e[0m\n" 1>&2
      fi
    elif [ "$OPTION" == "Unhide (Default)" ] || [ "${OPTION,,}" == "unhide" ]; then
      if sudo grub2-editenv list | grep -q "menu_auto_hide=1"; then    
        sudo grub2-editenv - unset menu_auto_hide
        if [ -d /sys/firmware/efi ]; then
          output=$(sudo grub2-mkconfig -o /etc/grub2-efi.cfg 2>&1) || echo "$output" && false
              echo 'Reverted setting "UEFI GRUB logs during boot" to defaults.'  
        else
          output=$(sudo grub2-mkconfig -o /etc/grub2.cfg 2>&1) || echo "$output" && false
              echo 'Reverted setting "BIOS GRUB logs during boot" to defaults.'   
        fi
      else
        printf "\e[1;31mERROR: GRUB screen is already present, no change is made.\e[0m\n" 1>&2
      fi  
    fi

# Toggle bluetooth kernel modules on/off (requires reboot)
toggle-bluetooth-modules:
    #!/usr/bin/pkexec /usr/bin/bash
    BLUE_MOD_FILE="/etc/modprobe.d/99-bluetooth.conf"
    if test -e $BLUE_MOD_FILE; then
      sudo rm -f $BLUE_MOD_FILE
      echo "Bluetooth kernel modules disabled. Reboot to take effect."
    else
      sudo sh -c 'echo "install bluetooth /sbin/modprobe --ignore-install bluetooth" >> "$1"' _ "$BLUE_MOD_FILE"
      sudo sh -c 'echo "install btusb /sbin/modprobe --ignore-install btusb" >> "$1"' _ "$BLUE_MOD_FILE"
      sudo chmod 644 $BLUE_MOD_FILE
      echo "Bluetooth kernel modules enabled. Reboot to take effect."
    fi

# enable a kernel module that is disabled by modprobe.d (requires restart)
override-enable-module mod_name:
    #!/usr/bin/pkexec /usr/bin/bash
    MOD_NAME="{{ mod_name }}"
    MOD_FILE="/etc/modprobe.d/99-$MOD_NAME.conf"
    if test -e $MOD_FILE; then
      echo "$MOD_NAME module is already enabled."
    else
      sudo sh -c 'echo "install $1 /sbin/modprobe --ignore-install $1" >> "$2"' _ "$MOD_NAME" "$MOD_FILE" 
      sudo chmod 644 $MOD_FILE
      echo "Override created to enable $MOD_NAME module. Reboot to take effect."
    fi
  
# reset the override by `just override-enable-module`, i.e. disable the module again (requires restart)
override-reset-module mod_name:
    #!/usr/bin/pkexec /usr/bin/bash
    MOD_NAME="{{ mod_name }}"
    MOD_FILE="/etc/modprobe.d/99-$MOD_NAME.conf"
    if test -e $MOD_FILE; then
      sudo rm -f $MOD_FILE
      echo "The override for $MOD_NAME module has been reset. Reboot to take effect."
    else
      echo "No override found for $MOD_NAME module."
    fi

# Configure scheduled nightly reboot
scheduled-reboot ACTION="prompt":
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    CURRENT_STATE="Disabled"
    if systemctl is-enabled nightly-reboot.timer | grep -q enabled; then
      CURRENT_STATE="Enabled"
    fi  
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
      echo "${bold}Configuring scheduled nightly reboot${normal}"    
      echo "Scheduled nightly reboot is currently: ${bold}${CURRENT_STATE}${normal}"
      echo 'Configure scheduled nightly reboot, which happens in 03:00.'
      echo 'Enable or Disable scheduled nightly reboot? Press ESC to exit.'
      OPTION=$(ugum choose "Disable (Default)" Enable)
    elif [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-scheduled-reboot <option>"
      echo "  <option>: Specify the quick option - 'enable' or 'disable'"
      echo "  Use 'enable' to enable scheduled nightly reboot systemd service."
      echo "  Use 'disable' to revert to defaults."      
      exit 0
    fi
    if [ "${OPTION,,}" == "enable" ]; then
      if systemctl is-enabled nightly-reboot.timer | grep -q disabled; then
        sudo systemctl enable nightly-reboot.timer
        sudo systemctl start nightly-reboot.timer
        echo "Nightly scheduled reboot is enabled!"
      else
        printf "\e[1;31mERROR: Nightly scheduled reboot is already enabled, no change is made.\e[0m\n" 1>&2
      fi  
    elif [ "$OPTION" == "Disable (Default)" ] || [ "${OPTION,,}" == "disable" ]; then
      if systemctl is-enabled nightly-reboot.timer | grep -q enabled; then
        sudo systemctl disable nightly-reboot.timer
        sudo systemctl stop nightly-reboot.timer
        echo 'Reverted setting "nightly scheduled reboot" to defaults.'
      else
        printf "\e[1;31mERROR: Nightly scheduled reboot is already disabled, no change is made.\e[0m\n" 1>&2
      fi
    fi  
