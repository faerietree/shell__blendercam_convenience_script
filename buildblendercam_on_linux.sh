#!/bin/sh

# PREREQUISITES:
# Set the corresponding symbolic link for blender: (blender must exist in $HOME directory)
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/blender blender
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/2.73 blender-source


# FETCH
echo "================="
echo "====== FETCH"
# Fetch or update polygon sources:
cd
VERSION="3-3.0.7"
FILE="Polygon"$VERSION".zip"
if [ -f $FILE ]; then
	rm $FILE # to make sure no broken/incomplete zip persists
fi

DIR="Polygon"$VERSION
# exists and is directory?
if ! [[ -d $DIR ]]; then
	wget "https://pypi.python.org/packages/source/P/Polygon3/$FILE" -O Polygon3.zip
	unzip Polygon3.zip
	rm Polygon3.zip
fi
rm python-polygon
ln -s "$DIR/" python-polygon

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

# fetch or update numpy source repository
SEEK="python-numpy"
echo "Looking for $SEEK:"
PYTHON_NUMPY=$(find $HOME -type d -name "*$SEEK*")
echo "Result: $PYTHON_NUMPY"
if ! [[ $PYTHON_NUMPY ]]; then
	echo 'Not found.'
	git clone git://github.com/numpy/numpy.git "./"$SEEK
else 
	echo 'Found it in folder: '$PYTHON_NUMPY
	cd $PYTHON_NUMPY
	git pull
	cd
fi
rm numpy.tar.gz # <-- because it may be a broken/incomplete download.
if ! [[ -f numpy.tar.gz ]]; then
	wget "http://sourceforge.net/projects/numpy/files/NumPy/1.9.1/numpy-1.9.1.tar.gz/download?use_mirror=skylink&r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnumpy%2Ffiles%2FNumPy%2F1.9.1%2F&use_mirror=skylink" -O numpy.tar.gz
fi
tar xf numpy.tar.gz --directory python-numpy-snapshot
	


# BUILD
echo "================="
echo "====== BUILD"
#sudo aptitude install python-dev
#which python
#python --version
echo "Installing additional packages if not exist: python3-dev, cython, libgeos-dev:"
sudo aptitude install python3-dev
which python3
python3 --version

sudo aptitude install cython
sudo aptitude install libgeos-dev

cd
cd python-polygon
sudo python3 setup.py build
cd
cd python-numpy-snapshot
sudo python3 setup.py build
cd 
cd python-shapely
sudo python3 setup.py build


# INTEGRATE BLENDERCAM INTO BLENDER
echo "================="
echo "======= INTEGRATE INTO BLENDER"
# setup up symbolic links:
cd 
rm ./blender-source/python/lib/python3.4/numpy
ln -s ./python-numpy-snapshot/numpy ./blender-source/python/lib/python3.4/

rm ./blender-source/python/lib/python3.4/shapely
ln -s ./python-shapely/shapely ./blender-source/python/lib/python3.4/

rm ./blender-source/python/lib/python3.4/Polygon
ln -s ./python-polygon/Polygon ./blender-source/python/lib/python3.4/

cd 
rm ./blender-source/config # <-- not deletes if it's a directory, thus this is safe.
ln -s $HOME/blendercam/config blender-source/
# TODO iterate, i.e. treat one by one and remove existing old version first.
echo "-------------------------------------------"
echo "Note: Failures are normal if the addons already exist. Coding TODO check individually and either skip if exists or replace with newer version."
echo "-------------------------------------------"
cp -i $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
#ln -s $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
cp -i $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/
#ln -s $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/

# LAUNCH BLENDER
echo "================="
echo "======= LAUNCH "
cd
chmod +x ./blender-source/../blender
rm blender
ln -s ./blender-source/../blender blender
./blender

