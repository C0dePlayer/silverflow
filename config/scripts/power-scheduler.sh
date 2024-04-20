#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

curl -o /etc/yum.repos.d/_copr_kylegospo_system76_scheduler_fedora.repo "https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/repo/fedora-$(rpm -E %fedora)/kylegospo-system76-scheduler-fedora-$(rpm -E %fedora).repo"

curl -o /etc/yum.repos.d/_copr_ublue-os-staging.repo "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo?arch=x86_64"

if rpm -qa | grep power-profiles-daemon; then
    rpm-ostree override remove power-profiles-daemon gamemode --install=system76-scheduler --install=gnome-shell-extension-system76-scheduler \
        --install=tuned --install=tuned-ppd --install=tuned-utils --install=tuned-profiles-atomic --install=tuned-profiles-cpu-partitioning
else
    rpm-ostree install system76-scheduler gnome-shell-extension-system76-scheduler tuned tuned-ppd tuned-utils tuned-utils-systemtap \
        tuned-profiles-atomic tuned-profiles-cpu-partitioning
fi

systemctl enable com.system76.Scheduler.service
systemctl enable tuned.service

mkdir -p /usr/etc/system76-scheduler
curl -o /usr/etc/system76-scheduler/config.kdl https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/usr/etc/system76-scheduler/config.kdl

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo_system76_scheduler_fedora.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo
