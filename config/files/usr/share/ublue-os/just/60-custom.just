# Install pdm (modern Python package and dependency manager) | https://pdm-project.org/latest/
install-pdm:
    #!/usr/bin/env bash
    cd "${HOME}/Downloads" || exit
    curl -sSLO https://pdm-project.org/install-pdm.py
    curl -sSL https://pdm-project.org/install-pdm.py.sha256 | sha256sum -c -
    python3 install-pdm.py --path "${HOME}/pdm"
    rm -f install-pdm.py

# Install conda with mamba (fast, robust, and cross-platform package manager) | https://mamba.readthedocs.io/en/latest/index.html
install-mamba:
    #!/usr/bin/env bash
    cd "${HOME}/Downloads" || exit
    wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    bash Miniforge3.sh -b
    rm -f Miniforge3.sh

# Removes pdm from the system
remove-pdm:
    #!/usr/bin/env bash
    cd "${HOME}/Downloads" || exit
    curl -sSLO https://pdm-project.org/install-pdm.py
    curl -sSL https://pdm-project.org/install-pdm.py.sha256 | sha256sum -c -
    python3 install-pdm.py --path "${HOME}/pdm" --remove
    rm -f install-pdm.py

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
        --append-if-missing="debugfs=off" \
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
        --delete-if-present="debugfs=off" \
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
        --delete-if-present="mitigations=auto,nosmt"
    fi

# Configure GRUB screen with various options
configure-grub ACTION="prompt":
    #!/usr/bin/env bash
    bold=$(tput bold)
    normal=$(tput sgr0)
    OPTION={{ ACTION }}
    if [ "$OPTION" == "prompt" ]; then
      echo "${bold}Configuring GRUB${normal}"
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
      sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
      output=$(echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 2>&1) || echo "$output" && false
      output=$(echo 'GRUB_HIDDEN_TIMEOUT=1' | sudo tee -a /etc/default/grub 2>&1) || echo "$output" && false
      if [ -d /sys/firmware/efi ]; then
        output=$(sudo grub2-mkconfig -o /etc/grub2-efi.cfg 2>&1) || echo "$output" && false
            echo 'Hide UEFI GRUB logs during boot setting applied.'  
      else
        output=$(sudo grub2-mkconfig -o /etc/grub2.cfg 2>&1) || echo "$output" && false
            echo 'Hide BIOS GRUB logs during boot setting applied.'   
      fi
    elif [ "$OPTION" == "Unhide (Default)" ] || [ "${OPTION,,}" == "unhide" ]; then
      sudo sed -i '/GRUB_HIDDEN_TIMEOUT=1/d' /etc/default/grub
      sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
      sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
      if [ -d /sys/firmware/efi ]; then
        output=$(sudo grub2-mkconfig -o /etc/grub2-efi.cfg 2>&1) || echo "$output" && false
            echo 'Reverted setting "UEFI GRUB logs during boot" to defaults.'  
      else
        output=$(sudo grub2-mkconfig -o /etc/grub2.cfg 2>&1) || echo "$output" && false
            echo 'Reverted setting "BIOS GRUB logs during boot" to defaults.'   
      fi
    fi