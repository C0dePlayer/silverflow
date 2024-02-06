#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

RPM_ROOT="/tmp/rpms"

wget -O "${RPM_ROOT}/brother-hl-1112E-CUPS.rpm" https://support.brother.com/g/b/files/dlf/dlf007073/hl1110cupswrapper-3.0.1-1.i386.rpm
wget -O "${RPM_ROOT}/brother-hl-1112E-LPR.rpm" https://support.brother.com/g/b/files/dlf/dlf007071/hl1110lpr-3.0.1-1.i386.rpm

cd "${RPM_ROOT}" || exit

rpm-ostree install brother-hl-1112E-CUPS.rpm brother-hl-1112E-LPR.rpm
