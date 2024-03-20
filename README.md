# SilverFlow

[![build-ublue](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml/badge.svg)](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml)

SilverFlow is based on [build-blue/template](https://github.com/blue-build/template), which makes it easy to create your own custom image-based Fedora experience. 

See the [BlueBuild](https://blue-build.org/how-to/setup/) docs for quick setup instructions for setting up your own repository.

## Installation

> [!NOTE]
> You can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes.

1. Rebase to the unsigned image to install the proper signing keys and policies:
     
     ```
     rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:latest
     ```
      This repository builds date tags as well, so if you want to rebase to a particular day's build:
        
        ```
        rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:20231005
        ```
  1. Reboot to complete the rebase:
     
      ```
      systemctl reboot
      ```
      
  2. After first boot, the first time that [ublue-update](https://github.com/ublue-os/ublue-update) runs it will automatically rebase you onto the signed image.


## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/c0deplayer/silverflow-nvidia
