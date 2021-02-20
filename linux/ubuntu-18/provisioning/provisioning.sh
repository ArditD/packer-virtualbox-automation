#!/bin/bash -eux
# Don't ask for password when sudo-ing
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_qacicd
echo 'qacicd ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_qacicd
/bin/chmod 0440 /etc/sudoers.d/10_qacicd

# Install the Updates
export DEBIAN_FRONTEND="noninteractive"
apt-get update -qq > /dev/null
apt-get dist-upgrade -qq -y > /dev/null

# Install Ansible repository and Ansible.
apt -y install software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update -qq > /dev/null
apt-get install ansible -qq -y > /dev/null

exit 0