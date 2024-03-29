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

# Configure grub bootmenu visibility and fix duplicate entries
configure-grub ACTION="":
    #!/bin/bash
    source /usr/lib/ujust/ujust.sh
    GRUB_STATE="$(grep -P "^GRUB_TIMEOUT_STYLE=hidden" /etc/default/grub)"
    OPTION={{ ACTION }}
    if [ "$GRUB_STATE" == "GRUB_TIMEOUT_STYLE=hidden" ]; then
        GRUB_STATE="${b}Hidden${n}"
    else
        GRUB_STATE="${b}Not Hidden${n}"
    fi
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-grub <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'hide' to select Hide Grub"
      echo "  Use 'unhide' to select Unhide Grub"
      echo "  Use 'fix' to select Fix double ostree entry"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Grub menu configuration${normal}"
      echo "Grub menu is set to: $GRUB_STATE"
      OPTION=$(Choose "Hide Grub" "Unhide Grub" "Fix double ostree entry")
    fi
    if [[ "${OPTION,,}" =~ ^hide ]]; then
      sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
      echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
      echo 'GRUB_HIDDEN_TIMEOUT=1' | sudo tee -a /etc/default/grub 1>/dev/null
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    elif [[ "${OPTION,,}" =~ ^unhide ]]; then
      sudo sed -i '/GRUB_HIDDEN_TIMEOUT=1/d' /etc/default/grub
      sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
      sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    elif [[ "${OPTION,,}" =~ ^fix ]]; then
      sudo grub2-switch-to-blscfg
      if [ -d /sys/firmware/efi ]; then
        sudo grub2-mkconfig -o /etc/grub2-efi.cfg
      else
        sudo grub2-mkconfig -o /etc/grub2.cfg
      fi
    fi
