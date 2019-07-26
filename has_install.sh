#!/bin/sh

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


# ?? 
function _update() {
	_purple "Performing System Updates"
	sudo apt-get -y update
	_purple "Performing System Upgrade"
	sudo apt-get -y upgrade
	_success "System Updates & Upgrade Complete"
}





function installPythonHeaders()
{
	echo "Python Header Files."
	sudo apt-get -y install python2.7-dev python3-dev
	
}

function installPIP()
{
	echo "Install pip Python package manager"
	wget https://bootstrap.pypa.io/get-pip.py
	sudo python get-pip.py
}





# MariaDB
function install_mariaDB()
{
	_bolded "Installing MariaDB"
	sudo apt-get update -y
	sudo apt-get install mariadb-server -y
	_success "MariaDB Installation Successful!"

}



# pymysql

# TODO: More Automation surrounding this
function install_pymysql()
{
	_bolded "Installing pymysql"
	pip install pymysql
	_success "pymysql Installation Successful!"
}


function installPyenv()
{
	_bolded "Installing pyenv"
	curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
	_bolded "Adding To Path"
	echo 'export PATH="/home/pi/.pyenv/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(pyenv init -)"' >> ~/.bashrc
	echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
	_success "Pyenv Installed!"
}





function autorunMotion()
{
	# ps -ef | grep motion (to check if running)
	_bolded "Change start_motion_daemon=no to start_motion_daemon=yes"
	_bolded "Type: "
	echo "sudo nano etc/default/motion"
	_bolded "then, type:"
	echo "sudo systemctl enable motion"
	_bolded "reboot and service should be running"
	_bolded "Type to check if running:"
	echo "ps -ef | grep motion"
	_success "Motion on-boot setup Success!"
}






function install_Powerline() 
{
	_bolded "Installing Powerline"
	sudo apt-get -y install powerline
	_success "Powerline Installed!"
}


function install_GIT()
{
	_bolded "Installing git"
	sudo apt-get -y install git
	_success "git Installed!"
}


function install_tmux()
{
	echo "Installing tmux"
	sudo apt-get -y update
	sudo apt-get -y install tmux
	_success "tmux Installed!"
}




function install_alaisShortcuts()
{
	_bolded "Installing alias shortcut"

	echo '' >> ~/.bashrc
	echo '' >> ~/.bashrc
	echo '# HAS Installed alias' >> ~/.bashrc
	echo 'alias reload=". ~/.bashrc"' >> ~/.bashrc
	echo 'alias ls="ls -la --color=auto"' >> ~/.bashrc
	echo 'alias del="sudo rm -rf"' >> ~/.bashrc
	echo 'alias hasstart="bash has_start.sh"' >> ~/.bashrc
	echo 'alias sthome="sudo homebridge -U /home/pi/.homebridge'
	echo '' >> ~/.bashrc

	_success "bash alias Installed!"
}



# installing ffmpeg
function install_ffmpeg_acel_rpiZero()
{
	_bolded "Installing Dependancies"
	sudo apt-get install libomxil-bellagio-dev -y
	sudo apt-get install pkg-config -y
	sudo apt-get install autoconf -y
	sudo apt-get install automake -y
	sudo apt-get install libtool -y
	sudo apt install checkinstall
	_success "Dependancies!"


	git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
	cd ffmpeg
	sudo mkdir dependencies
	cd dependencies/
	sudo mkdir output

	_bolded "Installing x264"

	sudo git clone http://git.videolan.org/git/x264.git
	cd x264
	./configure --enable-static --prefix=/home/pi/ffmpeg/dependencies/output/
	_bolded "Compiling x264"
	sudo make
	sudo make install
	cd ..
	_success "x264"

	_bolded "Installing alsa"
	sudo wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.7.tar.bz2
	tar xjf alsa-lib-1.1.7.tar.bz2
	cd alsa-lib-1.1.7/
	./configure --prefix=/home/pi/ffmpeg/dependencies/output
	_bolded "Compiling alsa"
	sudo make
	sudo make install
	cd ..
	_success "alsa"

	_bolded "Installing aac"
	git clone https://github.com/mstorsjo/fdk-aac.git
	cd fdk-aac
	./autogen.sh
	./configure --enable-shared --enable-static
	_bolded "Compiling aac"
	sudo make
	sudo make install
	sudo ldconfig
	cd ..
	_success "aac"

	cd $HOME/ffmpeg
	_bolded "Compiling ffmpeg"
	./configure --prefix=/home/pi/ffmpeg/dependencies/output --enable-gpl --enable-mmal --enable-libx264 --enable-nonfree --enable-libfdk_aac --enable-omx --enable-omx-rpi --extra-cflags="-I/home/pi/ffmpeg/dependencies/output/include" --extra-ldflags="-L/home/pi/ffmpeg/dependencies/output/lib" --extra-libs="-lx264 -lpthread -lm -ldl"
	sudo make
	sudo make install

	echo 'export PATH=$PATH:$HOME/ffmpeg' >> ~/.bashrc

	_success "ffmpeg Installed!"
}




# installing ffmpeg
function install_ffmpeg_acel()
{
	echo 'yay'
	git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg

	cd ffmpeg
	mkdir dependencies
	cd dependencies/
	mkdir output

	_bolded "Installing Dependancies"
	sudo apt-get install libomxil-bellagio-dev -y
	sudo apt-get install pkg-config -y
	sudo apt-get install autoconf -y
	sudo apt-get install automake -y
	sudo apt-get install libtool -y
	sudo apt install checkinstall
	_success "Dependancies!"

	_bolded "Installing x264"

	git clone http://git.videolan.org/git/x264.git
	cd x264
	./configure --enable-static --prefix=/home/pi/ffmpeg/dependencies/output/
	_bolded "Compiling x264"
	sudo make -j4
	sudo make install
	cd ..
	_success "x264"

	_bolded "Installing alsa"
	wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.7.tar.bz2
	tar xjf alsa-lib-1.1.7.tar.bz2
	cd alsa-lib-1.1.7/
	./configure --prefix=/home/pi/ffmpeg/dependencies/output
	_bolded "Compiling alsa"
	sudo make -j4
	sudo make install
	cd ..
	_success "alsa"

	_bolded "Installing aac"
	git clone https://github.com/mstorsjo/fdk-aac.git
	cd fdk-aac
	./autogen.sh
	./configure --enable-shared --enable-static
	_bolded "Compiling aac"
	sudo make -j4
	sudo make install
	sudo ldconfig
	cd ..
	_success "aac"

	cd $HOME/ffmpeg
	_bolded "Compiling ffmpeg"	
	./configure --prefix=/home/pi/ffmpeg/dependencies/output --enable-gpl --enable-mmal --enable-libx264 --enable-nonfree --enable-libfdk_aac --enable-omx --enable-omx-rpi --extra-cflags="-I/home/pi/ffmpeg/dependencies/output/include" --extra-ldflags="-L/home/pi/ffmpeg/dependencies/output/lib" --extra-libs="-lx264 -lpthread -lm -ldl"
	sudo make -j4
	sudo make install

	# 
	echo 'Adding ffmpeg to Path '
	echo 'export PATH=$PATH:$HOME/ffmpeg' >> ~/.bashrc

	#
	echo "Copying ffmpeg files to '/usr/local/bin' "
	# 
	sudo cp /home/pi/ffmpeg/ffprobe_g  /usr/local/bin
	sudo cp /home/pi/ffmpeg/ffprobe  /usr/local/bin
	sudo cp /home/pi/ffmpeg/ffmpeg_g  /usr/local/bin
	sudo cp /home/pi/ffmpeg/ffmpeg  /usr/local/bin
	# 
	echo "Copy Finished"

	_success "ffmpeg Installed!"
}



# Installing Motion
function installMotion() 
{
	_bolded "Installing Motion"
	sudo apt-get install -y gdebi
	wget https://github.com/Motion-Project/motion/releases/download/release-4.2.1/pi_stretch_motion_4.2.1-1_armhf.deb
	printf 'y\n' | sudo gdebi pi_stretch_motion_4.2.1-1_armhf.deb
	sudo modprobe bcm2835-v4l2
	_success "Motion Installed!"
}



# Homebridge
function installHomebridge()
{
	installNodeJS

	_bolded "Installing Linux Dependancies..."
	sudo apt-get install -y libavahi-compat-libdnssd-dev

	_bolded "Installing Homebridge..."
	sudo npm install -g --unsafe-perm homebridge
	_success "Homebridge Installed!"

	installhomebridgePlugins

	_success "Homebridge Service Installed and Started!"

}


function installhomebridgePlugins()
{
	_bolded " - Installing Node.js Plugins - "
	cd
	sudo npm install -g api-quick
	_bolded " ~ Installing HomeBridge Plugins ~ "
	sudo npm install -g homebridge-camera-rpi
	sudo npm install -g homebridge-camera-ffmpeg
	sudo npm install -g homebridge-sonoff-tasmota-http
	sudo npm install -g homebridge-advanced-http-temperature-humidity
}



# NodeJS
# This is for Newer Raspbery Pi's with armv7
function installNodeJS()
{
	_bolded "Installing NodeJS"
	curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
	sudo apt-get install -y nodejs
	_success "NodeJS Installed!"
	echo ''
}



function installRPISource()
{
	_bolded "Installing rpi-source"
	# Install Dependacies
	sudo apt-get install libncurses5-dev -y
	sudo apt-get install bc -y
	sudo wget https://raw.githubusercontent.com/notro/rpi-source/master/rpi-source -O /usr/bin/rpi-source 
	sudo chmod +x /usr/bin/rpi-source 
	/usr/bin/rpi-source -q --tag-update

	# then 
	rpi-source
	echo "type 'rpi-source' "
	_success "rpi-source Installed "
}


function install_v4l2loopback()
{
	_bolded "Installing v4l2loopback"
	cd 
	git clone https://github.com/umlaeute/v4l2loopback
	cd v4l2loopback
	#
	make && sudo make install
	sudo depmod -a
	#
	cd
	sudo modprobe bcm2835-v4l2
	sudo modprobe v4l2loopback devices=1
	echo 'Devices:'
	v4l2-ctl --list-devices
	_success "'v4l2loopback' Installed!"
}

function setupForSystem()
{
	_bolded "Preparing Directories"
	cd
	mkdir .homebridge
	cd .homebridge/
	wget https://raw.githubusercontent.com/jmade/has/master/config.json

	_bolded "HomeBridge Prepared"

	cd
	mkdir .motion
	cd .motion/
	wget https://raw.githubusercontent.com/jmade/has/master/motion.conf

	_bolded "Motion Prepared"

	install_alaisShortcuts

	_success "Project Preparation Complete"
}



function _main()
{
	_bolded "-~- Starting Setup Script -~-"
	
	install_GIT
	install_tmux
	install_Powerline

	# install_ffmpeg_acel

	# installMotion

	# installHomebridge

	# installRPISource
	# install_v4l2loopback

	# setupForSystem

	_success "-~- Finished Install Script -~-"
}


_main