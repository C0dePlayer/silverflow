# SilverFlow

[![build-ublue](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml/badge.svg)](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml)

SilverFlow is based on [ublue-os/startingpoint](https://github.com/ublue-os/startingpoint), which makes it easy to create your own custom image-based Fedora experience. For more information, see the [uBlue homepage](https://universal-blue.org/) and the [main uBlue repo](https://github.com/ublue-os/main/).

## Installation

> [!WARNING]
> Currently, the system is undergoing constant changes, such as system hardening, package replacement or other experiments (not sure how long).

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
