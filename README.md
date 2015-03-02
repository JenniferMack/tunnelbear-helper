# TunnelBear-Helper

A script and configuration files for ArchLinux for use with the TunnelBear VPN service.

[TunnelBear](https://www.tunnelbear.com) is a VPN service that recently started supporting Linux. They have provided the OpenVPN configuration files, and instructions for installation. The instructions are for systems running NetworkManager in a graphical environment. For headless servers that don’t run a window manager, it’s a bit more difficult.

The following instructions have been tested on a ArchLinux ARM system installed on a PogoPlug. This should work equally well on a Raspberry Pi running Arch. Overall, it should be compatible with any flavor of linux that uses `systemd` to manage services.

The basics steps are:

- Rename the files to something sensible.
- Install the config files.
- Install the `systemd` unit file.
- Install the helper script.

Requirements are:

- An up-to-date ArchLinux installation.
- A TunnelBear account at the Giant or Grizzly level.
- The ruby language needs to be installed to use the optional `tunnelbear` script.

---- 

## Initial setup

Install `openvpn` if it’s not already installed.

	sudo pacman -S openvpn
	
The TunnelBear OpenVPN config files need to be downloaded. They can be found at a link on the [Linux support page](https://www.tunnelbear.com/updates/linux_support/). The file is named `openvpn.zip`. This name may change in the future. Adjust the following commands if that happens.

After downloading, upzip the file and rename the folder.

	unzip openvpn.zip
	mv openvpn tunnelbear.d
	
## File renaming

The file names of the configuration files are not command line friendly. They are excessively long and contain spaces. Doing this step will save a lot of troubleshooting time.

The rename command is included in the default Arch installation. First, remove the `TunnelBear ` prefix.

	rename -v 'TunnelBear ' '' tunnelbear.d/TunnelBear*

Then remove the spaces from two remaining files.

	rename -v ' ' '' tunnelbear.d/*

## Authorization file

TunnelBear uses user/password authentication on top of the provided key files. OpenVPN can load this information from a file when it’s started. The TunnelBear `systemd` unit file expects a key file, if you don’t want to use one, delete the `--auth-user-pass /etc/openvpn/tunnelbear.d/tb-auth.key \` line from that file. But then the username and password will have to entered everytime a connection is started.

Create the auth file in the same folder as the config files.

	touch tunnelbear.d/tb-auth.key
	nano tunnelbear.d/tb-auth.key

The auth file is two lines only. This is the same information that is used to log into the TunnelBear website.
	email
	password

## File permissions

The files need to be owned by the root account, and not otherwise readable. Change the permissions, and then the ownership.

	chmod 600 tunnelbear.d/*
	sudo chown root:root tunnelbear.d/*

## Installation

Finally! First copy the the config folder into place.

	sudo cp -r tunnelbear.d /etc/openvpn/

Copy the systemd unit file into place.

	sudo cp tunnelbear\@.service /usr/lib/systemd/system/

Make the tunnelbear script executable, and copy it into place.

	chmod +x tunnelbear
	sudo cp tunnelbear /usr/local/bin

## Usage

To start the VPN manually, the `systemd` command is `tunnelbear@` followed by the country name.

	sudo systemctl start tunnelbear@Sweden

It functions as a regular `systemd` service, and the `start`, `stop`, `restart`, and `status` commands act as expected.

To start a connection on system startup, it must be enabled.

	sudo systemctl enable tunnelbear@Sweden

Once enabled, it still must be started manually the first time. Then it will start up automatically.

This method creates a unique `tunnelbear` service using the OpenVPN program. The `openvpn` service is still available, and can be run independently. But only one OpenVPN session can be active at any give time. If TunnelBear is the only service that will connected, then only use the the `tunnelbear` service. The `openvpn` service won’t recognize the TunnelBear configuration files.

## TunnelBear script

The tunnelbear script can start, stop, a connection. It can also query if a TunnelBear connection is active.

### TunnelBear menu

The command by itself will provide a menu of exit points. Choosing the number next to a country name will create a connection to there.

	$ tunnelbear

The menu:

	1 Australia
	2 Canada
	3 France
	4 Germany
	5 Ireland
	6 Japan
	7 Spain
	8 Sweden
	9 Switzerland
	10 UnitedKingdom
	11 UnitedStates
	==========
	VPN choice? (1 to 11):

Choosing the number of a country starts the connection and asks for a confirmation.

	VPN choice? (1 to 11): 4
	Tunneling to TunnelBear Germany? [Y/n]: 
	Connecting to Germany...

### TunnelBear direct

Starting the script with the name of a country as an option will bypass the menu.

	$ tunnelbear Japan
	Tunneling to TunnelBear Japan...

### TunnelBear query

The `up?` option will query the system for a running process and return the connected country and process ID.

	$ tunnelbear up?
	TunnelBear is roaring in Japan (pid: 20868).

### TunnelBear stop

To stop a running connections, simple start the script with the stop option.

	$ tunnelbear stop

### Errors

If the script is not run as root, `systemd` will complain. If a number is entered that is not on the menu, ruby will complain.

## DNS

Once the TunnelBear is roaring, make sure to check for Internet connectivity. Once the VPN is up and running, the name servers from the local ISP are not available. If this happens the `resolv.conf` file must be updated. With the default configuration of ArchLinux this file is a symlink that gets updated automatically. It's better to make the it a regular file with permanent settings.

First delete the symlink.

    $ sudo rm /etc/resolv.conf

Then create a new file.

    $ sudo touch /etc/resolv.conf

Then add the nameservers for OpenDNS with a Google fallback and a short timeout value.

    nameserver 208.67.220.220
    nameserver 208.67.222.222
    nameserver 8.8.8.8
    options timeout:1

Save the file, and check for Internet connectivity.

