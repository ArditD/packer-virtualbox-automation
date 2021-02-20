# ArchLinux 

Change the URL and point it to your local ISO, you might need to change the sha256sum as well.

## Includes
- basic installation with bare bone tools but including terminator, firefox, chromium, xarchiver, tcpdump, nmap, networkmanager plus plugins and other common tools used during debug (it's why I choose archlinux which in contrast with other distros [they come with allot of preinstalled stuff] we install only what we really need to use.
- httpd, sshd servers enabled by default
- virtualbox guest additions already integrated with drag & drop and copy/paste bidirectional from host <=> guest for a pleasant experience.
- latest software by default and *real* rolling release (the arch way)
- sudo won't ask for password (faster)
- automatic login
- "desktop_choice": "cinnamon" 
Currenlty Supported : cinnamon, gnome , mate (gnome 2 fork)

## Note
- To get the full resolution working click on View > AutoResize Guest Display twice after maxing the screen.
- Username / password : qacicd
- do not try to login before packer has fully build the VM, the automatic login will work when you start up the VM after the import.