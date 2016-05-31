#!/bin/bash

# PREREQUISITES:
# Set the corresponding symbolic link for blender: (blender must exist in $HOME directory)
#cd $HOME
#ln -s relative/path/to/blender-2.73-rc1-linux-glibc211-x86_64_blendercam/2.73 blendercam

#~/blendercam/../blender # to test or run


echo "================="
echo "====== AUTODETECT"
PATH_TO_PYTHON=python3
#PATH_TO_PYTHON='$HOME/blendercam/../lib/python'
PYTHON_VERSION_2DIGITS=3.4

if [ ! -z $PATH_TO_BLENDER_RELEASE ]; then
	echo 'Using user provided blender release: '$PATH_TO_BLENDER_RELEASE
elif [ ! -z $BLENDER_RELEASE_PATH ]; then
	echo 'Using user provided blender release: '$BLENDER_RELEASE_PATH
	PATH_TO_BLENDER_RELEASE=$BLENDER_RELEASE_PATH
else
	PATH_TO_BLENDER_RELEASE=~/blendercam
	echo 'Using default blender release location: '$PATH_TO_BLENDER_RELEASE
fi


# Derive Python version from blender source:
PATH_TO_BLENDER_PYTHON_LIB=$PATH_TO_BLENDER_RELEASE/python/lib
PYTHON_VERSION_2DIGITS=$(ls $PATH_TO_BLENDER_PYTHON_LIB | egrep -o '[0-9]+[.][[:digit:]]+' | head -n1)
echo "Python version: "$PYTHON_VERSION_2DIGITS
PATH_TO_BLENDER_PYTHON_LIB=$PATH_TO_BLENDER_PYTHON_LIB"/python"$PYTHON_VERSION_2DIGITS
echo "Python library path (blender bundled python):" $PATH_TO_BLENDER_PYTHON_LIB


echo ""
echo "================="
echo "====== INPUT"
# Number of runtime arguments given to script:
#echo $#
SHALL_REDOWNLOAD=1
SHALL_REBUILD=0

SHALL_INSTALL_PACKAGES=false
PACKAGE_MANAGER_INSTALL_COMMAND=' apt-get install ' #because it's available most often?


# Parse the arguments given to this script:
#for i # <- for each  argument, terminate if no more arguments, see below
while :
do
	echo $1 #use $i
	# Note: Empty space is the delimiter! => $1 is first, after space is $2.
	case $1 in
		-h | --help | -\?)
			#TODO create help function to call?
			echo "Use like /path/to/buildblendercam_on_linux.sh --no-redownload --install_missing[_packages] --yaourt --yum --pacman --apt-get --aptitude --package_manager_install_command=' pacman -Sa '"
			exit 0	# This is not an error, User asked for help. Don't "exit 1"
			;;

		--no-redownload)
			SHALL_REDOWNLOAD=0
			shift
			;;
		--rebuild*)
			SHALL_REBUILD=1
			shift
			;;

		--package_manager_install_command=*)
			PACKAGE_MANAGER_INSTALL_COMMAND=${1#*=}
			shift 1
			;;

		--apt-get)
			PACKAGE_MANAGER_INSTALL_COMMAND=' apt-get install '
			shift
			;;
		--aptitude)
			PACKAGE_MANAGER_INSTALL_COMMAND=' aptitude install '
			shift
			;;
		--pacman)
			PACKAGE_MANAGER_INSTALL_COMMAND=' pacman -S '
			shift
			;;
		--yaourt)
			PACKAGE_MANAGER_INSTALL_COMMAND=' yaourt -Sa '
			shift
			;;
		--yum)
			PACKAGE_MANAGER_INSTALL_COMMAND=' yum install '
			shift
			;;
		--install_missing* | --install-missing*)
			SHALL_INSTALL_PACKAGES=true
			shift
			;;

		--prefix=*)
			AD=${1#*=}	# Deletes everything before first occurrence of = (inclusively).
			shift
			;;

		-v | --verbose)
			# Each instance of -v adds 1 to verbosity
			verbose=$((verbose+1))
			shift
			;;
		--) # End of all options
			shift
			break
			;;
		-*)
			printf >&2 'WARN: Unknown option (ignored): %s\n' "$1"
			shift
			;;


		*)  # no more options. Stop while loop. #<-- Note: This must be the last check condition as it matches always.
			break
			;;
	esac
done


# FETCH
echo ""
echo "================="
echo "====== FETCH"
echo 'Fetching or updating BlenderCAM addon by hero Vilem:'
#sudo $PACKAGE_MANAGER_INSTALL_COMMAND svn
cd
PATH_TO_BLENDERCAM_ADDON=$HOME/BlenderCAM
if ! [[ -d $PATH_TO_BLENDERCAM_ADDON ]]; then
	echo 'Downloading BlenderCAM addon ...'
	svn checkout http://blendercam.googlecode.com/svn/trunk/ BlenderCAM
	echo '*done*'
else
	echo 'Updating BlenderCAM addon ...'
	cd $PATH_TO_BLENDERCAM_ADDON
	echo '*done*'
	svn up
fi


# Fetch or update polygon sources:
cd
VERSION="3-3.0.7"
echo 'Fetching Polygon python library version '$VERSION':'
FILE="Polygon"$VERSION".zip"
if [ -f $FILE ]; then
	rm $FILE # to make sure no broken/incomplete zip persists
fi

DIR="Polygon"$VERSION
# exists and is directory?
if ! [[ -d $DIR ]]; then
	echo 'Found no '$DIR'. Fetching it: '
	wget "https://pypi.python.org/packages/source/P/Polygon3/$FILE" -O Polygon3.zip
	#wget "https://bitbucket.org/jraedler/polygon3/downloads/$FILE" -O Polygon3.zip
	echo 'Unzipping: '
	unzip Polygon3.zip
	echo '*done*'
	rm Polygon3.zip
fi
rm python-polygon
ln -s "$DIR/" python-polygon
echo "Linked $DIR to python-polygon."
echo '-----------------'

# fetch or update shapely source repository
SEEK="python-shapely"
echo "Looking for $SEEK:"
#PYTHON_SHAPELY=$(find $HOME -type d -name "*$SEEK*")
#echo "Result: $PYTHON_SHAPELY"
if ! [[ -d $SEEK ]]; then
	echo 'Not found. Will fetch into '$SEEK':'
	#http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
	if [ command -v git >/dev/null 2>&1 ]; then
		echo "Program 'git' is required but is not installed."#" Aborting ..."
		if [ command -v apt-get >/dev/null 2>&1 ]; then
			sudo apt-get install git
		else:
			cd /tmp
			if [ -f /tmp/kx ]; then
				rm /tmp/kx
			fi
			wget https://raw.githubusercontent.com/faerietree/kx/master/kx
			chmod +x /tmp/kx
			CMD=$(/tmp/kx install)' git'
			CMD_maincommand=""
			count=0
			for CMD_part in "${CMD[@]}"; do
				# the first one may be sudo:
				if [[ ! $CMD_part='sudo' ]]; then
					CMD_maincommand=$CMD_part
					echo $CMD_maincommand
					break
				fi
				count=count+1
			done
			if [ command -v ${CMD_maincommand} >/dev/null 2>&1 ]; then
				echo >&2 "Couldn't automatically install it. CMD not exists: "$CMD_maincommand". Aborting ..."
				exit 1
			fi
			echo 'Installing git ...'
			$($CMD)
			echo '*done*'
		fi
	fi
	#type foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
	#hash foo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }i
	git clone git@github.com:Toblerity/Shapely.git "./$SEEK"
else
	echo 'Found it in folder: '$SEEK
	cd $SEEK
	git pull
	cd
fi
echo '-----------------'

# fetch or update numpy source repository
SEEK="python-numpy"
echo "Looking for $SEEK:"
#PYTHON_NUMPY=$(find $HOME -type d -name "*$SEEK*")
#echo "Result: $PYTHON_NUMPY"
if ! [[ -d $SEEK ]]; then
	echo 'Not found.'
	git clone git://github.com/numpy/numpy.git "./"$SEEK
else
	echo 'Found it in folder: '$SEEK
	cd $SEEK
	git pull
	cd
fi

if [ -f numpy.tar.gz ] && [ $SHALL_REDOWNLOAD -ne 0 ]; then
	echo 'Removing previously downloaded numpy.tar.gz :'
	rm numpy.tar.gz # <-- because it may be a broken/incomplete download.
fi
VERSION="1.9.1"
# -ne and -eq for integer
if ! [[ -f numpy.tar.gz ]]; then
	echo "Downloading numpy sources: "
	wget "http://sourceforge.net/projects/numpy/files/NumPy/$VERSION/numpy-$VERSION"".tar.gz/download?use_mirror=skylink&r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnumpy%2Ffiles%2FNumPy%2F1.9.1%2F&use_mirror=skylink" -O numpy.tar.gz
fi
tar xzf numpy.tar.gz --directory .
sudo rm python-numpy-snapshot -r
mv "numpy-"$VERSION python-numpy-snapshot #overwrites!
echo '-----------------'



# BUILD
echo ""
echo "================="
echo "====== BUILD"

if [[ $SHALL_INSTALL_PACKAGES ]]; then
	echo 'Package install command: '$PACKAGE_MANAGER_INSTALL_COMMAND
	echo "Installing additional packages if not exist: python3-dev, cython, libgeos-dev:"
	sudo $PACKAGE_MANAGER_INSTALL_COMMAND cython
	sudo $PACKAGE_MANAGER_INSTALL_COMMAND libgeos-dev
	#sudo aptitude install python-dev
	#which python
	#python --version
	echo 'As it is not guarantueed that the python3 version in the package repositories match the blender version: '$PYTHON_VERSION_2DIGITS'. We will custom download and (alt)install the correct version.'
#	sudo $PACKAGE_MANAGER_INSTALL_COMMAND python3-dev python3-devel
#	sudo $PACKAGE_MANAGER_INSTALL_COMMAND python3-numpy
	which python3
	python3 --version
fi


echo ""
echo "================="
echo "======= CREATE MATCHING PYTHON"
cd
if [ -f python.tgz ] && [ $SHALL_REDOWNLOAD -ne 0 ]; then
	echo 'Deleting previously downloaded python (it may be broken so redownload to be safe):'
	rm python.tgz
fi
echo '*done*'


GET_ALTERNATE_PYTHON='~/shell__coexisting_alternate_python_version/download_setup_and_get_path_to.sh'
chmod +x $GET_ALTERNATE_PYTHON
PATH_TO_PYTHON=`$GET_ALTERNATE_PYTHON`


cd
echo 'Building numpy:'
cd python-numpy-snapshot
sudo $PATH_TO_PYTHON setup.py build
#cd
#sudo python3 python-numpy-snapshot/setup.py install  #<-- numpy is required for polygon -- NOTE: Not working from within the source directory?
echo '*done*'

cd
echo 'Building shapely:'
cd python-shapely
sudo $PATH_TO_PYTHON setup.py build
#sudo python3 setup.py install
echo '*done*'

cd
echo 'Building polygon:'
cd python-polygon
sudo $PATH_TO_PYTHON setup.py build
echo '*done*'


# INTEGRATE BLENDERCAM INTO BLENDER
echo ""
echo "================="
echo "======= INTEGRATE INTO BLENDER"
# setup up symbolic links:
cd
rm $PATH_TO_BLENDER_PYTHON_LIB/numpy
#ln -s $HOME/python-numpy-snapshot/numpy $PATH_TO_BLENDER_PYTHON_LIB/
ln -s $HOME/python-numpy-snapshot/build/lib.linux-$(uname -m)-$PYTHON_VERSION_2DIGITS/numpy $PATH_TO_BLENDER_PYTHON_LIB/
echo 'Created symbolic link for numpy. (In newer version numpy already exists in site-packages thanks to Thomas (DingTo).)'

rm $PATH_TO_BLENDER_PYTHON_LIB/shapely
#ln -s $HOME/python-shapely/shapely $PATH_TO_BLENDER_PYTHON_LIB/
ln -s $HOME/python-shapely/build/lib.linux-$(uname -m)-$PYTHON_VERSION_2DIGITS/shapely $PATH_TO_BLENDER_PYTHON_LIB/
echo 'Created symbolic link for shapely.'

rm $PATH_TO_BLENDER_PYTHON_LIB/Polygon
#ln -s $HOME/python-polygon/Polygon ./blendercad/python/lib/python3.4/
# Using build/.../Polygon as there cPolygon exists. Do not copy over or symlink ./Polygon instead. It will not contain compiled cPolygon. The instructions on Blendercam.blogspot.cz did not work for me.
ln -s $HOME/python-polygon/build/lib.linux-$(uname -m)-$PYTHON_VERSION_2DIGITS/Polygon $PATH_TO_BLENDER_PYTHON_LIB/
echo 'Created symbolic link for Polygon.'
#'''
#see here for why this is not necessarily possible:
#http://blender.stackexchange.com/questions/8509/including-3rd-party-modules-in-a-blender-addon
# either
#	provide a complete, customized blender build
#		or
#	ask your users to manually place the required lib into python/lib/pythonV.V/site-packages folder.
#		or
#	add the lib to your addon folder and import it from there (sys.path.append should do the trick)
#'''
# Assuming blendercam uses sys.path.append:
#ln -s $HOME/python-polygon/build/lib.linux-$(uname -m)-$PYTHON_VERSION_2DIGITS/Polygon $PATH_TO_BLENDER_PYTHON_LIB/site-packages/
#echo 'Linked polygon into site-packages.'
#ln -s $HOME/python-polygon/build/lib.linux-$(uname -m)-3.2/Polygon/*.so ./blendercad/../lib/
#ln -s $HOME/python-polygon/build/lib.linux-$(uname -m)-$PYTHON_VERSION_2DIGITS/Polygon $PATH_TO_BLENDER_PYTHON_LIB/site-packages/
#echo 'Linked shared objects to blenderxyz/lib/ (e.g. cPolygon.so).'

cd
echo 'Creating symbolic link for config: '
PATH_TO_BLENDER_CONFIG=$PATH_TO_BLENDER_RELEASE/config
# Only backup directory if it's not a symbolic link to a directory:
if [ -d $PATH_TO_BLENDER_CONFIG && ! -L $PATH_TO_BLENDER_CONFIG ]; then
	PATH_TO_BLENDER_CONFIG_BACKUP=$PATH_TO_BLENDER_CONFIG'.bak'
	echo 'Warning: config directory already exists. Backing up to '
	mv -i $PATH_TO_BLENDER_CONFIG $PATH_TO_BLENDER_CONFIG_BACKUP
elif [ -f $PATH_TO_BLENDER_CONFIG ]; then
	rm $PATH_TO_BLENDER_CONFIG # <-- not deletes if it's a directory, thus this is safe.
fi

ln -s $PATH_TO_BLENDERCAM_ADDON/config $PATH_TO_BLENDER_RELEASE/
echo '*done*'

# TODO iterate, i.e. treat one by one and remove existing old version first.
#echo "-------------------------------------------"
echo '-----------------'
echo 'Cleaning previously linked(older script version) or copied over addons (files only!):'
rm $PATH_TO_BLENDER_RELEASE/scripts/addons/cam
rm $PATH_TO_BLENDER_RELEASE/scripts/addons/print_3d
rm $PATH_TO_BLENDER_RELEASE/scripts/addons/scan_tools.py
rm $PATH_TO_BLENDER_RELEASE/scripts/addons/select_similar.py
echo '*done*'

echo 'Cleaning previously linked(older script version) or copied over presets (files only!):'
rm $PATH_TO_BLENDER_RELEASE/scripts/presets/cam_cutters
rm $PATH_TO_BLENDER_RELEASE/scripts/presets/cam_machines
rm $PATH_TO_BLENDER_RELEASE/scripts/presets/cam_operations
echo '*done*'

#echo 'Copying over blenderCAM addons to scripts/addons/ :'
echo 'Linking blenderCAM addons to scripts/addons/ :'
#rsync -vaz --exclude=".*" $PATH_TO_BLENDERCAM_ADDON/scripts/addons/* $PATH_TO_BLENDER_RELEASE/scripts/addons/
#cp -r $PATH_TO_BLENDERCAM_ADDON/scripts/addons/* $PATH_TO_BLENDER_RELEASE/scripts/addons/
ln -s $PATH_TO_BLENDERCAM_ADDON/scripts/addons/* $PATH_TO_BLENDER_RELEASE/scripts/addons
#if [ -d $HOME/addons__only_put_here_links ]; then
#	echo 'For optional completeness also linking them into the folder for gathering all addons.'
#	ln -s $PATH_TO_BLENDERCAM_ADDON/scripts/addons/* $HOME/addons__only_put_here_links/
#fi
echo '*done*'
#echo 'Copying blenderCAM presets over to blender scripts/presets/.'
echo 'Linking blenderCAM presets to blender scripts/presets/.'
#rsync -vaz --exclude=".*" $PATH_TO_BLENDERCAM_ADDON/scripts/presets/* $PATH_TO_BLENDER_RELEASE/scripts/presets/
#cp -r $PATH_TO_BLENDERCAM_ADDON/scripts/presets/* $PATH_TO_BLENDER_RELEASE/scripts/presets/
ln -s $PATH_TO_BLENDERCAM_ADDON/scripts/presets/* $PATH_TO_BLENDER_RELEASE/scripts/presets
echo '*done*'

echo 'Removing __pycache__:'
rm $PATH_TO_BLENDER_RELEASE/scripts/addons/__pycache__ -r
echo '*done*'


# LAUNCH BLENDER
echo ""
echo "================="
echo "======= LAUNCH "
cd
#echo 'Creating shortcut in home directory for blendercam ...'
#rm blendercam-exec <-- because 'blendercam' is for the release files, thus can't be used.
#ln -s $PATH_TO_BLENDER_RELEASE/../blender blendercam-exec
echo "Launching blendercam ($PATH_TO_BLENDER_RELEASE/../blender)..."
chmod +x $PATH_TO_BLENDER_RELEASE/../blender
$PATH_TO_BLENDER_RELEASE/../blender

