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
# Download script python files.
mkdir ~/bin
cd ~/bin
curl -o shutdown_button.py -fsSL https://www.packtenna.com/uploads/1/2/2/7/122774721/shutdown_button.py.txt 
curl -o getip.py -fsSL https://www.packtenna.com/uploads/1/2/2/7/122774721/getip.py.txt
# Control Serial Interface
sudo raspi-config nonint do_serial_hw 0
sudo raspi-config nonint do_serial_cons 1

# Create shutdown service.
echo "[Unit]
Description=SRS_Shutdown
After=multi-user.target

[Service]
User=$USER
ExecStart=/usr/bin/python3 ~/bin/shutdown_button.py

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/srs_shutdown.service
sudo chmod +x /etc/systemd/system/srs_shutdown.service
sudo systemctl daemon-reload
sudo systemctl enable srs_shutdown.service

# Install minicom not needed?
sudo apt-get install minicom -y -qq > /dev/null
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
# -- Install git & Python -- #
sudo apt-get install git python3-rpi.gpio  -y -qq > /dev/null
echo "Install Git and python Y"
wait

echo "**The next step will take around 5 minutes. Please be patient.**"
echo  -n "Install modules for SRS Dashboard."
cd $HOME/.node-red
if [[ $dashboard_update != 'n' ]] && [[ $dashboard_update != 'N' ]]; then
curl -o flows.json -fsSL https://www.packtenna.com/uploads/1/2/2/7/122774721/flows__1_.json
npm --prefix ~/.node-red/ install node-red node-red-contrib-email node-red-contrib-string node-red-contrib-ui-led node-red-dashboard node-red-node-serialport node-red-contrib-python3-function @js-on/node-red-contrib-py3run node-red-contrib-simple-gate node-red-node-pi-gpio node-red-contrib-buffer-parser --silent
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

