#!/bin/bash
# yavide installation script

#####################################################################################################
# Settings
#####################################################################################################
YAVIDE_IDE_ROOT="/opt/yavide"
if [ ! -z $1 ]; then
	if [[ ( $1 == "ubuntu" ) || ( $1 == "debian" ) ]]; then
		PACKAGE_MANAGER="apt-get"
		PACKAGE_MANAGER_INSTALL="apt-get install"
		PACKAGE_MANAGER_UPDATE="apt-get update"
	elif [ $1 == "opensuse" ]; then
		PACKAGE_MANAGER="zypper"
		PACKAGE_MANAGER_INSTALL="zypper install"
		PACKAGE_MANAGER_UPDATE="zypper update"
	fi
else
	echo "Please provide the system name you're running."
	echo "Currently supported ones are:"
	echo -e "\t'ubuntu'"
	echo -e "\t'debian'"
	echo -e "\t'opensuse'"
	exit
fi

#####################################################################################################
# Plugins
#####################################################################################################

# Nerdtree
PLUGINS="$PLUGINS https://github.com/scrooloose/nerdtree"

# Session
PLUGINS="$PLUGINS https://github.com/xolox/vim-session"
PLUGINS="$PLUGINS https://github.com/xolox/vim-misc.git"

# Clang_complete
PLUGINS="$PLUGINS https://github.com/Rip-Rip/clang_complete"

# SuperTab
PLUGINS="$PLUGINS https://github.com/ervandew/supertab"

# Tagbar
PLUGINS="$PLUGINS https://github.com/majutsushi/tagbar"

# Airline
PLUGINS="$PLUGINS https://github.com/bling/vim-airline"

# A
PLUGINS="$PLUGINS https://github.com/vim-scripts/a.vim"

# Auto-close
PLUGINS="$PLUGINS https://github.com/Townk/vim-autoclose"

# NERDCommenter
PLUGINS="$PLUGINS https://github.com/scrooloose/nerdcommenter"

# UltiSnips
PLUGINS="$PLUGINS https://github.com/SirVer/ultisnips"

# Git
PLUGINS="$PLUGINS https://github.com/tpope/vim-fugitive.git"

# Pathogen
PLUGINS="$PLUGINS https://github.com/tpope/vim-pathogen"

# Nice color scheme (wombat)
SCHEMES="https://github.com/jeffreyiacono/vim-colors-wombat"

#####################################################################################################
# Root password needed for some operations
#####################################################################################################
echo -n "Enter the root password: "
stty_orig=`stty -g` # save original terminal setting.
stty -echo          # turn-off echoing.
read passwd         # read the password
stty $stty_orig     # restore terminal setting.


#####################################################################################################
# Check and install the prerequisites
#####################################################################################################

# Install required packages
echo "$passwd" | sudo -S $PACKAGE_MANAGER_UPDATE
echo "$passwd" | sudo -S $PACKAGE_MANAGER_INSTALL ctags cscope git
[ -d $/home/$USER/.fonts ] | echo "$passwd" | sudo -S mkdir /home/$USER/.fonts
echo "$passwd" | sudo -S git clone https://github.com/Lokaltog/powerline-fonts.git /home/$USER/.fonts
fc-cache -vf /home/$USER/.fonts

#####################################################################################################
# Start the installation
#####################################################################################################

# Build the directory structure
[ -d $YAVIDE_IDE_ROOT ] || echo "$passwd" | sudo -S mkdir $YAVIDE_IDE_ROOT
[ -d $YAVIDE_IDE_ROOT/bundle ] || echo "$passwd" | sudo -S mkdir $YAVIDE_IDE_ROOT/bundle
[ -d $YAVIDE_IDE_ROOT/colors ] || echo "$passwd" | sudo -S mkdir $YAVIDE_IDE_ROOT/colors

# Copy the pre-configured stuff
echo "$passwd" | sudo -S cp yavide.desktop $YAVIDE_IDE_ROOT
echo "$passwd" | sudo -S cp yavide.desktop /home/$USER/Desktop
echo "$passwd" | sudo -S cp .vimrc $YAVIDE_IDE_ROOT
echo "$passwd" | sudo -S cp -R sessions $YAVIDE_IDE_ROOT/sessions

echo "\n"
echo "----------------------------------------------------------------------------"
echo "Installing plugins ..."
echo "----------------------------------------------------------------------------"
cd $YAVIDE_IDE_ROOT/bundle

# Fetch/update the plugins
for URL in $PLUGINS; do
    # remove path from url
    DIR=${URL##*/}
    # remove extension from dir
    DIR=${DIR%.*}
    if [ -d $DIR  ]; then
        echo "Updating plugin $DIR..."
        cd $DIR
        echo "$passwd" | sudo -S git pull
        cd ..
    else
        echo "$passwd" | sudo -S git clone $URL $DIR
    fi
done

echo "\n"
echo "----------------------------------------------------------------------------"
echo "Installing clang_complete ..."
echo "----------------------------------------------------------------------------"
cd $YAVIDE_IDE_ROOT/bundle/clang_complete
make install

echo "----------------------------------------------------------------------------"
echo "Installing color schemes ..."
echo "----------------------------------------------------------------------------"
cd $YAVIDE_IDE_ROOT/colors

# Fetch/update the color schemes
for URL in $SCHEMES; do
    # remove path from url
    DIR=${URL##*/}
    # remove extension from dir
    DIR=${DIR%.*}
    if [ -d $DIR  ]; then
        echo "Updating scheme $DIR..."
        cd $DIR
        echo "$passwd" | sudo -S git pull
        cd ..
    else
        echo "$passwd" | sudo -S git clone $URL $DIR
	fi
done

# Make symlinks to scheme files
echo "$passwd" | sudo -S ln -s `find . -name '*.vim'` .

echo "----------------------------------------------------------------------------"
echo "Setting permissions ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S chown $USER /home/$USER/Desktop/yavide.desktop
echo "$passwd" | sudo -S chown -R $USER $YAVIDE_IDE_ROOT

