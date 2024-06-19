#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

for repo in /etc/yum.repos.d/*.repo; do
    sed -i 's/metalink?/metalink?protocol=https\&/g' "$repo"
done