#!/bin/bash


if command -v rpm &> /dev/null
then

  echo "RPM-based Linux distro detected."
  
  # https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
  
  # Then update the package cache and install the package using dnf (Fedora 22 and above):
  if command -v dnf &> /dev/null
  then
    dnf check-update
    sudo dnf install code # or code-insiders
  # Or on older versions using yum:
  elif command -v yum &> /dev
  then
    yum check-update
    sudo yum install code # or code-insiders
  fi
fi
