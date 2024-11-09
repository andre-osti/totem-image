#!/bin/bash

# This script provides common customization options for the ISO
# 
# Usage: Copy this file to config.sh and make changes there.  Keep this file (default_config.sh) as-is
#   so that subsequent changes can be easily merged from upstream.  Keep all customiations in config.sh

# The version of Ubuntu to generate.  Successfully tested LTS: bionic, focal, jammy, noble
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
export TARGET_UBUNTU_VERSION="noble"

# The Ubuntu Mirror URL. It's better to change for faster download.
# More mirrors see: https://launchpad.net/ubuntu/+archivemirrors
export TARGET_UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"

# The packaged version of the Linux kernel to install on target image.
# See https://wiki.ubuntu.com/Kernel/LTSEnablementStack for details
export TARGET_KERNEL_PACKAGE="linux-generic"

# The file (no extension) of the ISO containing the generated disk image,
# the volume id, and the hostname of the live environment are set from this name.
export TARGET_NAME="totem"

# The text label shown in GRUB for booting into the live environment
export GRUB_LIVEBOOT_LABEL="Try Ubuntu without installing"

# The text label shown in GRUB for starting installation
export GRUB_INSTALL_LABEL="Install Ubuntu"

# Packages to be removed from the target system after installation completes succesfully
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

# Package customisation function.  Update this function to customize packages
# present on the installed system.
function customize_image() {
    # install graphics and desktop
    echo "Install graphics and desktop"
    apt-get install -y \
        plymouth-themes \
        ubuntu-wallpapers \
        ubuntu-desktop-minimal # Works for xubuntu-desktop-minimal, but network needs restart. Why?
                               # If we create a new user, then live mode does not automatically opens the sessions.
                               # However, I think it is ok to ask for password, given it is the full system running?

    # install expected locales
    locale-gen en_US.UTF-8 pt_BR.UTF-8
    update-locale LANG=pt_BR.UTF-8 LANGUAGE="pt_BR:en_US" LC_ALL=pt_BR.UTF-8

    # useful tools
    echo "Install useful tools"
    apt-get install -y \
	    ansible \
        apt-transport-https \
        curl \
        vim \
        nano \
        less

    # apply totem playbooks
    LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 ansible-playbook --connection=local --inventory 127.0.0.1, /root/playbooks/create_user/create_user.yml
    # Wont run in livecd mode because of lack of apparmor profile. To test, it is possible to run chrome with --no-sandbox (insecure).
    LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 ansible-playbook --connection=local --inventory 127.0.0.1, /root/playbooks/install_chrome/install_chrome.yml
    ## TODO: add all backend needed here... Be careful to add it to the totem user.
    ## TODO: In the future, we may want to allow the totem user to start the application, but not change anything in the system.

    # Should be executed after the first login
    # LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 ansible-playbook --skip-tags "apparmor" --connection=local --inventory 127.0.0.1, /root/playbooks/hardening/hardening.yml

    # purge
    apt-get purge -y \
        ansible \
	    transmission-gtk \
        transmission-common \
        gnome-mahjongg \
        gnome-mines \
        gnome-sudoku \
        aisleriot \
        hitori
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.5"
