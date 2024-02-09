#!/usr/bin/env bash

set -euox pipefail

echo "Installing Brave Browser"

# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system. /var is
# a separate mutable, stateful FS that's overlaid onto
# the ostree rootfs. Therefore we need to install it into
# /usr/lib/brave.com instead, and dynamically create a
# symbolic link /opt/brave.com => /usr/lib/brave.com upon
# boot.

# Prepare staging directory
mkdir -p /var/opt # -p just in case it exists
# for some reason...

# Setup repo
cat << EOF > /etc/yum.repos.d/brave-browser.repo
[brave-browser]
name=Brave Browser
enabled=1
autorefresh=1
baseurl=https://brave-browser-rpm-release.s3.brave.com/\$basearch
EOF

# Import signing key
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Now let's install the packages.
rpm-ostree install brave-browser

# Clean up the yum repo (updates are baked into new images)
rm /etc/yum.repos.d/brave-browser.repo -f

# And then we do the hacky dance!
mv /var/opt/brave.com /usr/lib/brave.com # move this over here

# Create a symlinks
rm /usr/bin/brave-browser-stable
ln -s /opt/brave.com/brave/brave-browser /usr/bin/brave-browser
ln -s /opt/brave.com/brave/brave-browser /usr/bin/brave-browser-stable

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/brave-browser.conf <<EOF
L  /opt/brave.com  -  -  -  -  /usr/lib/brave.com
EOF
