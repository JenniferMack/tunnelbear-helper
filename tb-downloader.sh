#!/usr/bin/env bash

# Check if the 'curl' command is installed.
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed. Install curl and try again.' >&2
  exit 1
fi

echo "Downloading openvpn config files..."
if [ -f openvpn.zip ]
then
  echo "Found file..."
else
  curl -O https://s3.amazonaws.com/tunnelbear/linux/openvpn.zip
fi

echo "Extracting files..."
unzip openvpn.zip

echo "Renaming folder..."
mv openvpn tunnelbear.d

echo "Renaming files..."
rename -v 'TunnelBear ' '' tunnelbear.d/*
rename -v ' ' '' tunnelbear.d/*

echo "Changing file permissions..."
chmod 600 tunnelbear.d/*

echo "Changing file ownership..."
if [ -f /usr/bin/sudo ]; then
  sudo chown root.root tunnelbear.d/*
else
  chown root.root tunnelbear.d/*
fi

echo "Ready to install."
