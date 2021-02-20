# Ubuntu 20.04 server LTS automated installation.

Since this version (20.04) Ubuntu decided to drop the d-i (debian installer preseed) automated
installation opting for their own YAML based autoinstallation https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls

There's currently a "heated" discussion https://www.phoronix.com/forums/forum/software/distributions/1114394-ubuntu-20-04-lts-server-planning-a-new-means-for-automated-installations and the new format 
is yet to be finished and be stable so I decided to go with the preseed option since they still 
offer d-i with the legacy iso of the 20.04 (good option).

## Features
- tried to keep this as "vanilla" and clean as possible
- passwordless sudo for qacicd user
- updated with the latest updates by the end of the installation
- Ansible compatible (ansible-local) for some ansible provisioning

## ToDo
- OpenLDAP server 
- Radius server
- zabbix??
- else...