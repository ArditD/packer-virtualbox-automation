# Packer templates for Windows Server or Desktop, Linux (Arch, Centos 8 , ubuntu 18 / 20) etc.
Since this covers most or all methods of automation installation (kickstart , d-i, or manual / arch linux and Autounattended.xml ) it can be easely expanded.
It's however all I need at the moment so, not a big deal for me.

## Getting Started
```
git clone https://github.com/ArditDulemata/packer-virtualbox-automation.git
```


## Structure & Usage

We all like modular, so each folder has it's own subfolder and template, plus the templates are separated so you will need to run only the command to build the template for your env.
You can edit (if you like) some minor values , if you already have the iso downloaded (especially windows since the images are big) you point iso_url to your iso directory.
where the iso is at.

```
packer build machine-vbox.json 
```

### Packer fast track

Packer is an open source tool for creating identical machine images for multiple platforms from a single json source configuration. 
We can call this template.
In simple words, you have an ISO, you define what you want from that iso with a packer json template and packer can produce the virtual machine accordingly. 

### Packer template structure

**1. Variables**

here we define important variables for our installation, an example :

```
 "variables": {
        "cpus": "2",
        "disk_size": "40000",
        "headless": "false",
        "iso_checksum": "9f6d04032ae29fcffaa10349ff6a902bb21a26c19d8420d7364a589027cb3c4e",
        "iso_checksum_type": "sha256",
        "memory": "2048",
        "ssh_timeout": "60m"
    }
```
Basically we are defining variables that we are going to use later with the template where we say 2 cpu's a 40GB disk size.
Headless is if we want the GUI virtual machine pop-up when we run packer, if it's set to false then it will be supressed.

**2. Builders**
https://www.packer.io/docs/builders/index.html

This is where packer does the heavy lifting, i.e building the virtual machine from the ISO.
Here we define the type of the builder (virtualbox-iso) means that we are starting with a fresh iso and we want a new virtualbox machine.
What's important here (the rest is self explanatory) is the boot_command.
Those below are what we usually type during the manual installation, but this time packer does it for us.


```
    "builders": [{
        "type": "virtualbox-iso",
        "guest_os_type": "RedHat_64",
        "iso_url": "{{user `iso_dir`}}stuff_software-enterprise-x64_5.1.0.iso",
        "iso_checksum": "{{user `iso_checksum`}}",
        "iso_checksum_type": "{{user `iso_checksum_type`}}",
        "output_directory": "efw-software-enterprise-x64_5.1.0",
        "vm_name": "software-5.1-x86_64",
        "disk_size": "{{user `disk_size`}}",
        "headless": "{{user `headless`}}",
        "http_directory": "http",
        "guest_additions_mode": "disable",
        "boot_wait": "15s",
        "boot_command": ["<enter><wait><enter><wait>{{user `activation_code`}}<tab><enter><wait5><tab><enter><wait60>",
                        "<enter><wait3><tab><tab><enter><wait60><enter>"],
        "ssh_timeout": "10m",
        "ssh_username": "root",
        "ssh_password": "password",
        "shutdown_command": "init 0",
        "vboxmanage": [
            ["modifyvm", "{{.Name}}", "--memory", "{{user `memory`}}"],
            ["modifyvm", "{{.Name}}", "--cpus", "{{user `cpus`}}"],
            ["modifyvm", "{{.Name}}", "--natnet1", "192.168.0/24"],
            ["modifyvm", "{{.Name}}", "--nic2", "intnet"],
            ["modifyvm", "{{.Name}}", "--intnet2", "green"],
            ["modifyvm", "{{.Name}}", "--nic3", "intnet"],
            ["modifyvm", "{{.Name}}", "--intnet3", "orange"],
            ["modifyvm", "{{.Name}}", "--nic4", "intnet"],
            ["modifyvm", "{{.Name}}", "--intnet4", "blue"],
            ["modifyvm", "{{.Name}}", "--nic5", "natnetwork"]
        ]
    }]
```
This is how this part looks during execution : 
```
==> virtualbox-iso: Starting HTTP server on port 8677
==> virtualbox-iso: Creating virtual machine...
==> virtualbox-iso: Creating hard drive...
==> virtualbox-iso: Creating forwarded port mapping for communicator (SSH, WinRM, etc) (host port 3925)
==> virtualbox-iso: Executing custom VBoxManage commands...
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --memory 2048
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --cpus 2
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --natnet1 192.168.0/24
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --nic2 intnet
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --intnet2 green
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --nic3 intnet
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --intnet3 orange
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --nic4 intnet
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --intnet4 blue
    virtualbox-iso: Executing: modifyvm software-5.1-x86_64 --nic5 natnetwork
==> virtualbox-iso: Starting the virtual machine...
==> virtualbox-iso: Waiting 15s for boot...
==> virtualbox-iso: Typing the boot command...
```

Packer waits for the machine to finish the installation then SSH's into it (it uses WinRM for windows)
```
==> virtualbox-iso: Using ssh communicator to connect: 127.0.0.1
==> virtualbox-iso: Waiting for SSH to become available...
==> virtualbox-iso: Connected to SSH!
```
Depending on the operating system, "unatended" files are provided : 
- kickstart configuration is usually provided for CentOS / RedHat or anaconda.cfg based installers.
- Autounattend.xml is used in case of Microsoft Windows
- d-i (debian installer) , And Ubuntu has changed it's own recently switching to json, check the folder for more info.
There are systems that don't support neither of the above , in that case the automation is done
through boot_command https://www.packer.io/docs/builders/virtualbox-iso.html#boot-configuration that
can be combined with the build-in HTTP server on packer to download and execute scripts.

**3. Provisioning**

This part is when packer has finished installing the system and start executing post-installation-scripts via different hooks on the system.
The provisioning can be done simply with scripts , ansible, chef etc... Allot is supported
https://www.packer.io/docs/provisioners/index.html we are going to stick with Ansible / and scripts mostly.


**4. Post-processing**

After the provisioning is done packer halts the system and exports the virtual machine (we define
this on the post-processor's section): 
```
==> virtualbox-iso: Gracefully halting virtual machine...
==> virtualbox-iso: Preparing to export machine...
    virtualbox-iso: Deleting forwarded port mapping for the communicator (SSH, WinRM, etc) (host port 3925)
==> virtualbox-iso: Exporting virtual machine...
    virtualbox-iso: Executing: export software-5.1-x86_64 --output efw-software-enterprise-x64_5.1.0/software-5.1-x86_64.ovf
==> virtualbox-iso: Deregistering and deleting VM...
==> virtualbox-iso: Running post-processor: shell-local
```

And as we defined , we have our virtual machine : 
```
ls stuff-software-enterprise-x64_x.x.0/
software-x.x-x86_64-disk001.vmdk  software-x.x-x86_64.ovf
```
On the configuration we didn't define anything since we want the default vmdk / ovf output.
We can trigger as well scripts to be executed on the local machine during this phase.

