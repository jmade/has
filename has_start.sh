#!/bin/bash

# COLORS
_reset=$(tput sgr0)
_green=$(tput setaf 76)
_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)
_bold=$(tput bold)
_underline=$(tput sgr 0 1)


function _success()
{
    printf "${_green}✔ %s${_reset}\n" "$@"
}

function _bolded()
{
	printf "${_bold}%s${_reset}\n" "$@"
}

function _error()
{
	printf "${_red}%s${_reset}\n" "$@"
}


clear
_bolded 'System Script Starting.'
clear

_bolded 'Turning on bcm2835-v4l2'
sudo modprobe bcm2835-v4l2
_success '*Enabled*'
sleep 1
clear

_bolded 'Turning on loopback device'
sudo modprobe v4l2loopback devices=1
_bolded 'Listing Devices...'
v4l2-ctl --list-devices
_success '*Enabled Loopback Device!*'
sleep 1
clear

_bolded 'Starting Motion'
sudo motion -c /home/pi/.motion/motion.conf
_success '*Motion Started!*'
sleep 1
clear

_bolded 'Starting HomeBridge...'
sudo homebridge -U /home/pi/.homebridge
#sudo homebridge -U /home/pi/.homebridge &>/dev/null &
#disown
_success '*HomeBridge Started!*'
sleep 1
clear

_success 'Finished!' 
_bolded 'Goodbye'
clear
