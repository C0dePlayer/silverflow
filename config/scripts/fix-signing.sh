#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

cp "/usr/etc/containers/$IMAGE_NAME.pub" "/usr/etc/pki/containers/$IMAGE_NAME.pub"
