#!/usr/bin/env bash

echo "Downloading openvpn config files..."
curl -O https://s3.amazonaws.com/tunnelbear/linux/openvpn.zip

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
