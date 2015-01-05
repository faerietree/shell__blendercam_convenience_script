# PREREQUISITES:
# Set the corresponding symbolic link for blender: (blender must exist in $HOME directory)
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/blender blender
#ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/2.73 blender-source


# FETCH
# Fetch or update polygon sources:
cd
rm Polygon3-3.0.7.zip # to make sure no broken/incomplete zip persists
wget "https://pypi.python.org/packages/source/P/Polygon3/Polygon3-3.0.7.zip" -O Polygon3.zip
unzip Polygon3.zip
rm python-polygon
ln -s Polygon3-3.0.7/ python-polygon

# fetch or update shapely source repository
SEEK="python-shapely"
echo "Looking for $SEEK:"
PYTHON_SHAPELY=$(find $HOME -type d -name "*$SEEK*")
if [ !$PYTHON_SHAPELY ]; then 
	git clone git@github.com:Toblerity/Shapely.git python-shapely
else 
	cd python-shapely
	git pull
	cd
fi

# fetch or update numpy source repository
SEEK="python-numpy"
echo "Looking for $SEEK:"
PYTHON_NUMPY=$(find $HOME -type d -name "*$SEEK*")
if [ !$PYTHON_NUMPY ]; then
	git clone git://github.com/numpy/numpy.git python-numpy
else 
	cd python-numpy
	git pull
	cd
fi
wget "http://sourceforge.net/projects/numpy/files/NumPy/1.9.1/numpy-1.9.1.tar.gz/download?use_mirror=skylink&r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnumpy%2Ffiles%2FNumPy%2F1.9.1%2F&use_mirror=skylink" -O numpy.tar.gz
tar xf numpy.tar.gz --directory python-numpy-snapshot


# BUILD
#sudo aptitude install python-dev
#which python
#python --version

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
# setup up symbolic links:
cd 
rm ./blender-source/python/lib/python3.4/numpy
ln -s ./python-numpy-snapshot/numpy ./blender-source/python/lib/python3.4/

rm ./blender-source/python/lib/python3.4/shapely
ln -s ./python-shapely/shapely ./blender-source/python/lib/python3.4/

l
rm ./blender-source/python/lib/python3.4/Polygon
ln -s ./python-polygon/Polygon ./blender-source/python/lib/python3.4/

cd 
rm ./blender-source/config # <-- not deletes if it's a directory, thus this is safe.
ln -s $HOME/blendercam/config blender-source/
# TODO iterate, i.e. treat one by one and remove existing old version first.
ln -s $HOME/blendercam/scripts/addons/* blender-source/scripts/addons/
ln -s $HOME/blendercam/scripts/presets/* blender-source/scripts/presets/

# LAUNCH BLENDER
cd
chmod +x ./blender-source/../blender
ln -s ./blender-source/../blender blender
blender

