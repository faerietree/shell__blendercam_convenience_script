#!/bin/bash

# PREREQUISITES:
# Set the corresponding symbolic link for blender: (blender must exist in $HOME directory)
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/blender blender
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/2.73 blender-source


echo "================="
echo "====== INPUT"
#echo $#
SHALL_REDOWNLOAD=1
SHALL_INSTALL_PACKAGES=false
PACKAGE_MANAGER_INSTALL_COMMAND=' apt-get install ' #because it's available most often?
PATH_TO_PYTHON=python3
#PATH_TO_PYTHON='$HOME/blender-source/../lib/python'

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
            exit 0    # This is not an error, User asked for help. Don't "exit 1"
            ;;
			
        --no-redownload)
            SHALL_REDOWNLOAD=0
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
			PACKAGE_MANAGER_INSTALL_COMMAND=' pacman -S install '
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
            AD=${1#*=}    # Deletes everything before first occurrence of = (inclusively).
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
echo "================="
echo "====== FETCH"
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
echo "================="
echo "====== BUILD"

if [[ $SHALL_INSTALL_PACKAGES ]]; then
	echo "Installing additional packages if not exist: python3-dev, cython, libgeos-dev:"
    sudo $PACKAGE_MANAGER_INSTALL_COMMAND cython
    sudo $PACKAGE_MANAGER_INSTALL_COMMAND libgeos-dev
    #sudo aptitude install python-dev
    #which python
    #python --version
	echo $PACKAGE_MANAGER_INSTALL_COMMAND
    sudo $PACKAGE_MANAGER_INSTALL_COMMAND python3-dev
    sudo $PACKAGE_MANAGER_INSTALL_COMMAND python3-numpy
    which python3
    python3 --version
fi

cd
echo 'Building numpy:'
cd python-numpy-snapshot
$PATH_TO_PYTHON setup.py build
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
$PATH_TO_PYTHON 3setup.py build
echo '*done*'


# INTEGRATE BLENDERCAM INTO BLENDER
echo "================="
echo "======= INTEGRATE INTO BLENDER"
# setup up symbolic links:
cd 
rm ./blender-source/python/lib/python3.4/numpy
ln -s $HOME/python-numpy-snapshot/numpy ./blender-source/python/lib/python3.4/
echo 'Linked numpy.'

rm ./blender-source/python/lib/python3.4/shapely
ln -s $HOME/python-shapely/shapely ./blender-source/python/lib/python3.4/
echo 'Linked shapely.'

rm ./blender-source/python/lib/python3.4/Polygon
#ln -s $HOME/python-polygon/Polygon ./blender-source/python/lib/python3.4/
echo 'Using build/.../Polygon as there cPolygon exists. Do not copy over or symlink ./Polygon instead. It will not contain compiled cPolygon. The instructions on Blendercam.blogspot.cz did not work for me.'
ln -s "$HOME/python-polygon/build/lib.linux-$(uname -m)-3.2/Polygon" ./blender-source/python/lib/python3.4/
python-polygon/build/lib.linux-x86_64-3.2/Polygon/
echo 'Linked polygon.'
ln -s $HOME/python-polygon/build/lib.linux-$(uname -m)-3.2/Polygon/*.so ./blender-source/../lib/
echo 'Linked static objects to blenderxyz/lib/ (e.g. cPolygon.so).'
echo 'Static object in lib/ should now provide: cPolygon.o  gpc.o  PolyUtil.o'

cd 
rm ./blender-source/config # <-- not deletes if it's a directory, thus this is safe.
ln -s $HOME/blendercam/config blender-source/
# TODO iterate, i.e. treat one by one and remove existing old version first.
echo "-------------------------------------------"
echo "Note: Failures are normal if the addons already exist. Coding TODO check individually and either skip if exists or replace with newer version."
echo "-------------------------------------------"
echo 'Cleaning previously linked(older script version) or copied over addons (files only!):'
rm blender-source/scripts/addons/cam
rm blender-source/scripts/addons/print_3d
rm blender-source/scripts/addons/scan_tools.py
rm blender-source/scripts/addons/select_similar.py
echo '*done*'

echo 'Cleaning previously linked(older script version) or copied over presets (files only!):'
rm blender-source/scripts/presets/cam_cutters
rm blender-source/scripts/presets/cam_machines
rm blender-source/scripts/presets/cam_operations
echo '*done*'

echo 'Copying over addons to scripts/addons/ :'
rsync -vaz --exclude=".*" $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
#cp -r $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
#ln -s $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
echo '*done*'
echo 'Copying blenderCAM presets over to blender scripts/presets/.'
rsync -vaz --exclude=".*" $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/
#cp -r $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/
echo '*done*'
#ln -s $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/

# LAUNCH BLENDER
echo "================="
echo "======= LAUNCH "
cd
chmod +x ./blender-source/../blender
rm blender
ln -s ./blender-source/../blender blender
./blender

