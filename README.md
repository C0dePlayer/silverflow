# SilverFlow

[![build-ublue](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml/badge.svg)](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml)

SilverFlow is based on [build-blue/template](https://github.com/blue-build/template), which makes it easy to create your own custom image-based Fedora experience. 

See the [BlueBuild](https://blue-build.org/how-to/setup/) docs for quick setup instructions for setting up your own repository.

## Installation

> [!NOTE]
> I recommend either using one of the main uBlue images or creating your own

**Recommended:** Use the latest ISO from [the Releases page](https://github.com/C0dePlayer/silverflow/releases)

<details>
  <summary><b>Rebase an existing Silverblue/Kinoite installation</b></summary>

  1. Rebase to the unsigned image to install the proper signing keys and policies:
     
     ```
     rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:latest
     ```
      This repository builds date tags as well, so if you want to rebase to a particular day's build:
        
        ```
        rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:20231005
        ```
  2. Reboot to complete the rebase:
     
      ```
      systemctl reboot
      ```
      
  3. After first boot, the first time that [ublue-update](https://github.com/ublue-os/ublue-update) runs it will automatically rebase you onto the signed image.
</details>

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/c0deplayer/silverflow-nvidia
