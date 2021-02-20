#!/usr/bin/env bash
PATH=$PATH 
if [[ $PACKER_BUILDER_TYPE == "qemu" ]]; then
	DISK='/dev/vda'
else
	DISK='/dev/sda'
fi
PASSWORD=$(/usr/bin/openssl passwd -crypt 'qacicd')
set -e
set -x
pacman -Sy reflector python python-ply glibc man-pages archlinux-keyring --noconfirm
#generate a good local mirrorlist
reflector --country Italy --country Germany --country Romania --country Greece --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

#format the disk (since this is virtual we are going with dos partition table)
#Some automated formating with a boot 250M bootable partition and the rest for root
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISK}
  o
  n
  p
  1
   
  +250M
  n
  p
  2
   
   
  a
  1
  p
  w
  q
EOF

#filesystem
mkfs.ext4 ${DISK}1
mkfs.ext4 ${DISK}2

#Mount partitions
mount ${DISK}2 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot


#Install basesystem
pacstrap /mnt base base-devel linux linux-firmware 
#update new fstab with partition table
genfstab -U /mnt >> /mnt/etc/fstab

# We have to workaround the chrooting otherwise the script will stop executing commands after the chroot

cat <<EOF > /mnt/root/setup.sh
#!/usr/bin/env bash
PATH=$PATH 
set -e
set -x

pacman -S terminator xarchiver zip unzip flashplugin nmap reflector --noconfirm
pacman -S nm-connection-editor apache network-manager-applet networkmanager-strongswan --noconfirm
pacman -S volumeicon libotf otf-overpass ttf-bitstream-vera lxdm --noconfirm
pacman -S firefox mate gdm chromium tcpdump nano xorg-fonts-100dpi geany --noconfirm
pacman -S xorg-fonts-75dpi xf86-video-fbdev xf86-video-vesa openssh xorg-xrandr mesa-demos --noconfirm
pacman -S pulseaudio-alsa networkmanager ttf-liberation gdk-pixbuf2 --noconfirm
pacman -S acpid grub networkmanager-openvpn unrar zip alsa pulseaudio xterm --noconfirm


systemctl enable NetworkManager
systemctl enable httpd
systemctl enable gdm
systemctl enable sshd

#Virtualbox utilities
pacman -S virtualbox-guest-utils xf86-video-vmware --noconfirm -q
systemctl enable vboxservice.service

#LXDM
#sed -i "/# autologin=dgod/c\autologin=qacicd" /etc/lxdm/lxdm.conf
#sed will get confused by the / so better use % (grrrrr!!!)
#sed -i  "/# session=%usr%bin%startlxde/c\session=%usr%bin%cinnamon-session-cinnamon2d" /etc/lxdm/lxdm.conf

#LightDM Configuration
#sed -i '/#greeter-session=example-gtk-gnome/c\greeter-session=lightdm-webkit2-greeter' /etc/lightdm/lightdm.conf
#sed -i '/#user-session=default/c\user-session=cinnamon2d' /etc/lightdm/lightdm.conf
#sed -i '/#autologin-user=/c\autologin-user=qacicd' /etc/lightdm/lightdm.conf
#sed -i '/#autologin-session=/c\autologin-session=cinnamon2d' /etc/lightdm/lightdm.conf

groupadd -r autologin
# Add user and give him some decent permissions
useradd -m -g users -G wheel,games,autologin,power,optical,storage,scanner,lp,audio,video,log,systemd-network,http,daemon -s /bin/bash qacicd --password ${PASSWORD}
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_qacicd
echo 'qacicd ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_qacicd
/usr/bin/chmod 0440 /etc/sudoers.d/10_qacicd

#some other stuff , locale , timezone etc..
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen  && hwclock --systohc
echo LANG=en_US.UTF-8 > /etc/locale.conf && export LANG=en_US.UTF-8 && echo KEYMAP=it > /etc/vconsole.conf && echo LC_COLLATE=C >> /etc/locale.conf && locale-gen
ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime && echo arch > /etc/hostname

#set /etc/hosts
cat <<EOT >> /etc/hosts
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1	localhost
::1			  localhost
127.0.1.1	arch.cicd	arch
EOT

#Enable automated login with GDM
sed -i "/daemon]/aAutomaticLogin=qacicd\nAutomaticLoginEnable=True\nTimedLoginEnable=true\nTimedLogin=qacicd\nTimedLoginDelay=1" /etc/gdm/custom.conf
#Set default session to mate
cat <<EOT >> /var/lib/AccountsService/users/qacicd
[User]
Language=
XSession=mate
Icon=/home/qacicd/.face
SystemAccount=false
EOT

#Grub stuff before we finish
grub-install --recheck ${DISK}
grub-mkconfig -o /boot/grub/grub.cfg

#generate a good local mirrorlist
reflector --country Italy --country Germany --country Romania --country Greece --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo '==> Done deal'
exit
EOF
chmod +x /mnt/root/setup.sh
#We need to redefine the var before executing the in-chroot script.
sed '/set -x/a DISK=${DISK}' /mnt/root/setup.sh
#Chrooting and installing our system
arch-chroot /mnt /root/setup.sh


sleep 3
umount -R /mnt/boot
umount -R /mnt
systemctl reboot
