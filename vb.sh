#!/bin/bash
while true; do
read -p "Do you want to install Virtualbox? (y/n)" answer
case $answer in
  [Yy]* )
# execute command yes
echo "Virtualbox Pack setup..."
# optional repository
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | tee /etc/apt/sources.list.d/virtualbox.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
# step 1: stop VMs and kill virtualbox
vboxmanage list runningvms | sed -r 's/.*\{(.*)\}/\1/' | xargs -L1 -I {} VBoxManage controlvm {} savestate
killall vboxwebsrv && pkill virtualbox
systemctl stop vboxweb-service.service
# step 2: Create variable and remove Extension Pack
export VBOX_VER=`VBoxManage --version|awk -Fr '{print $1}'`
VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
# Step 3: remove virtualbox and folders
apt -y autoremove --purge virtualbox*
rm -rf /etc/vbox /opt/VirtualBox /usr/lib/virtualbox ~/.config/VirtualBox
# Step 4: update
apt update && apt autoclean && apt clean && apt autoremove && apt-get -y dist-upgrade && apt -y --fix-broken install
# Step 5: install virtualbox and Extension Pack
apt -y install virtualbox-6.0 bridge-utils
dpkg --configure -a && apt-get -f -y install
wget -c http://download.virtualbox.org/virtualbox/$VBOX_VER/Oracle_VM_VirtualBox_Extension_Pack-$VBOX_VER.vbox-extpack
VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-$VBOX_VER.vbox-extpack
# Step 6: configure and start virtualbox
usermod -a -G vboxusers $USER
systemctl enable vboxweb-service && systemctl start vboxweb-service
update-grub
vboxconfig
echo "Done"
    break;;
        [Nn]* )
    # execute command no
        break;;
    * ) echo; echo "Select: YES (y) or NO (n)";;
 esac
done
