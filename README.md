# The Complete XML Developer - Virtual Machine

The following instructions will configure a Virtual Machine for the purposes of teaching "The Complete XML Developer" training course.

By the following these instructions you will have a Virtual Environment with the following software configured:

* Ubuntu 22.04 (x86_64 or arm64)

* Desktop Environment
	* X.org
	* LXQt
	* Chromium
	* Firefox

* Java Development Environment
	* JDK 17
	* Apache Maven 3
	* IntelliJ IDEA CE
	* Eclipse IDE

* XML Environment
	* eXist-db 7.0.0-SNAPSHOT (build from source)
	* Oxygen XML Editor

* Visual Studio Code

* Miscellaneous Tools
	* Zsh and OhMyZsh
	* Git
	* cURL
	* wget
	* Screen
	* tar, gzip, bzip2, zstd, zip (and unzip)


We expect to start from a clean Ubuntu Server, or Ubuntu Cloud Image install. This has been tested with Ubuntu version 22.04.3 LTS.


This can be setup either in AWS EC2, or another Virtual Environment such as KVM on Linux.


## Setting up a new AWS EC2 Instance

If you wish to set this up in AWS EC2, then you should setup a new EC2 instance with the following properties:

1. Name the instance 'xmldev1'.

2. Select the `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type` AMI image, and the Architecture `arm64`.

3. Select `m6g.xlarge` instance type. (i.e.: 4vCPU, 16GB Memory, 1x237 NVMe SSD, $0.1776 / hour).

4. Select the `xmldev` keypair.

5. Select the `xmldev vm` Security Group.

6. Set the default Root Volume as an `EBS` `30 GiB` volume on `GP3` at `3000 IOPS` and `125 MiB throughput`.


## Setting up a new Linux KVM VM

If you wish to set this up in a KVM VM, then on the KVM host (assuming Ubuntu as the host OS) you should run the following commands (assuming an Evolved Binary Server in Hetzner):

```
git clone --single-branch --branch hetzner https://github.com/adamretter/soyoustart hetzner
cd ~/hetzner
sudo uvt-simplestreams-libvirt sync --source=http://cloud-images.ubuntu.com/minimal/releases arch=amd64 release=jammy
./create-uvt-kvm.sh --hostname xmldev1 --release jammy --memory 16384 --disk 30 --cpu 4 --bridge virbr1 --ip 5.9.214.101 --ip6 2a01:4f8:212:be9::101 --gateway 136.243.43.238 --gateway6 2a01:4f8:212:be9::2 --dns 213.133.100.100 --dns 213.133.99.99 --dns 213.133.98.98 --dns-search evolvedbinary.com --autostart
```

NOTE: The VM specific settings are:
* `--hostname` `xmldev1`
* `--ip` `5.9.214.101`
* `--ip6` `2a01:4f8:212:be9::101`

NOTE: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway` `136.243.43.238`
* `--gateway6` `2a01:4f8:212:be9::2`

NOTE: The network settings specific to the hosting provider are:
* `--dns 213.133.100.100`, `--dns 213.133.99.99`, `--dns 213.133.98.98`



## Installing and Running Puppet to Configure the VM

```
git clone https://github.com/evolvedbinary/xml-developer-vm-setup.git
cd xml-developer-vm-setup
rm -rf guacamole
sudo ./install-puppet-agent.sh

sudo /opt/puppetlabs/bin/puppet apply locale-gb.pp

sudo FACTER_default_user_password=mypassword \
     /opt/puppetlabs/bin/puppet apply base.pp
```

**NOTE:** you should set your own passwords appropriately above!

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `xml-developer-vm-setup` repo checkout:

```
cd xml-developer-vm-setup
sudo FACTER_default_user_password=mypassword \
     FACTER_existdb_db_admin_password=xmldev \
     FACTER_existdb_version=7.0.0-SNAPSHOT \
     /opt/puppetlabs/bin/puppet apply .
```

We have to restart the system after the above as it installs a new desktop login manager.

```
sudo shutdown -r now
```

(-[1-9A-Za-z-][0-9A-Za-z-]*(\.[1-9A-Za-z-][0-9A-Za-z-]*)*)?


### Load the data into the db

TODO(AR)

## Install Guacamole Server

On a separate VM:

```
git clone https://github.com/evolvedbinary/xml-developer-vm-setup.git
cd xml-developer-vm-setup
sudo ./install-puppet-agent.sh

cd guacamole

sudo FACTER_default_user_password=mypassword2 \
     /opt/puppetlabs/bin/puppet apply base.pp
```

**NOTE:** you should set your own passwords appropriately above!

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `xml-developer-vm-setup/guacamole` repo checkout:

```
cd xml-developer-vm-setup/guacamole

sudo FACTER_default_user_password=mypassword2 \
     FACTER_xmldev_default_user_password=mypassword
     /opt/puppetlabs/bin/puppet apply .
```

