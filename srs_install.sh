#!/bin/bash

## ---- Initial Questioning ---- ##
printf "Welcome to the Sierra Radio System Installer.\nPlease hit enter to continue. "
read
echo -n "Is this the first install on this Pi?"
read -p "(Y/n)" first_install
echo "Are you wanting to update Node-Red?"
echo -n "Only choose no if you have installed Node-red all ready on this machine. Most people will choose Yes."
read -p "(Y/n) " flag_update
echo "Are you wanting to update the Dashboard? Note this will not delete your data."
read -p "(Y/n) " dashboard_update

if  [[ $first_install != 'n' ]] && [[ $first_install != 'N' ]];then

## Control Serial Interface
sudo raspi-config nonint do_serial_hw 0
sudo raspi-config nonint do_serial_cons 1

# Install minicom not needed?
sudo apt-get install git python3-rpi.gpio minicom -y -qq > /dev/null
echo "Install Git and python Y"
wait
fi

if  [[ $flag_update != 'n' ]] && [[ $flag_update != 'N' ]]; then
clear
echo "Updating and Upgrading your Pi to newest standards"
sudo apt-get update -qq > /dev/null && sudo apt-get full-upgrade -qq -y > /dev/null && sudo apt-get clean > /dev/null
wait

# -- Install Node-Red -- #
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered) <<!
y
y
!
wait
clear
echo "**NodeRed Dashboard Status**"
echo "Updating and Upgrading your Pi to newest standards  Y"
echo "Install and Update NodeRed  Y"
fi

# -- Install NR Flow and Nodes -- #
echo "**The next step will take around 5 minutes. Please be patient.**"
echo  -n "Install modules for SRS Dashboard."
cd $HOME/.node-red
if [[ $dashboard_update != 'n' ]] && [[ $dashboard_update != 'N' ]]; then
curl -o flows.json -fsSL https://www.packtenna.com/uploads/1/2/2/7/122774721/flows__1_.json
curl -o package,json -fsSL https://raw.githubusercontent.com/kd9lsv/SRS_Install_Script/refs/heads/main/package.json
npm --prefix ~/.node-red/ install --silent
fi
echo "  Y"
wait

sudo systemctl enable --now nodered.service
HOSTIP=`hostname -I | cut -d ' ' -f 1`
    if [ "$HOSTIP" = "" ]; then
        HOSTIP="127.0.0.1"
    fi
echo "Node Red has Completed. Head to http://$HOSTIP:1880/ui to access the SRS Dashboard."
echo "System is rebooting"
sudo reboot

