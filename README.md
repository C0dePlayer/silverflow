# SilverFlow &nbsp; [![build-ublue](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml/badge.svg)](https://github.com/C0dePlayer/silverflow/actions/workflows/build.yml)

SilverFlow is based on [build-blue/template](https://github.com/blue-build/template), which makes it easy to create your own custom image-based Fedora experience. 

See the [BlueBuild](https://blue-build.org/how-to/setup/) docs for quick setup instructions for setting up your own repository.

## Installation

> [!NOTE]
> For most users, I would recommend looking into either [Bluefin](https://projectbluefin.io/) or [Bazzite](https://bazzite.gg/), or, for tinkerers, I recommend [making your own](https://blue-build.org/learn/getting-started/).

### ISOs

The currently-recommended method is to build an ISO using podman, then install SilverFlow from there

**Podman:**

```
mkdir ./iso-output
sudo podman run --rm --privileged --volume ./iso-output:/build-container-installer/build --security-opt label=disable --pull=newer \
ghcr.io/jasonn3/build-container-installer:latest \
IMAGE_REPO=ghcr.io/c0deplayer \
IMAGE_NAME=silverflow-nvidia \
IMAGE_TAG=latest \
VARIANT=Silverblue
```

**Docker:**

```
mkdir ./iso-output
sudo docker run --rm --privileged --volume ./iso-output:/build-container-installer/build --pull=always \
ghcr.io/jasonn3/build-container-installer:latest \
IMAGE_REPO=ghcr.io/c0deplayer \
IMAGE_NAME=silverflow-nvidia \
IMAGE_TAG=latest \
VARIANT=Silverblue
```

### Rebase

You *can* also rebase an existing Silverblue/Kinoite installation to the latest build:

  1. Rebase to the unsigned image to install the proper signing keys and policies:
     
     ```
     rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:latest
     ```
      This repository builds date tags as well, so if you want to rebase to a particular day's build:
        
          rpm-ostree rebase ostree-unverified-registry:ghcr.io/c0deplayer/silverflow-nvidia:20231005

  2. Reboot to complete the rebase:
     
      ```
      systemctl reboot
      ```
      
  3. Then, rebase onto the signed image:
      ```
      rpm-ostree rebase ostree-image-signed:docker://ghcr.io/c0deplayer/silverflow-nvidia:latest
      systemctl reboot
      ```


## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/c0deplayer/silverflow-nvidia
