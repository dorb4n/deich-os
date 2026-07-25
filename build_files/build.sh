#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y podman-compose podman-docker fuse-overlayfs

# install ddev
echo '[ddev]
name=ddev
baseurl=https://pkg.ddev.com/yum/
gpgcheck=0
enabled=1' | sed 's/^ \+//' | sudo tee /etc/yum.repos.d/ddev.repo >/dev/null

# Install DDEV
dnf5 install -y ddev

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

## ddev related podman configuration
if [ -f /proc/sys/user/max_user_namespaces ]; then
  if [ "0" = "$(cat /proc/sys/user/max_user_namespaces)" ]; then
    echo 'user.max_user_namespaces=28633' | sudo tee -a /etc/sysctl.d/60-rootless.conf
    sudo sysctl --system
  fi
fi
# Allow privileged port access if needed
if [ -f /proc/sys/net/ipv4/ip_unprivileged_port_start ]; then
  if [ "1024" = "$(cat /proc/sys/net/ipv4/ip_unprivileged_port_start)" ]; then
    echo 'net.ipv4.ip_unprivileged_port_start=0' | sudo tee -a /etc/sysctl.d/60-rootless.conf
    sudo sysctl --system
  fi
fi
