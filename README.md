BlenderCAM
=====
http://blendercam.blogspot.cz/
Thanks to our hero Vilem Novak for making blender engineers happy! 

Download, update, library build, setup convenience script.
-----

Note: It may be that the current blenderCAM addon is not yet compatible with the newest blender!

Blender Addon Prerequisites:
------
Note: BlenderCAM tries to enable these automatically but it may fail.
* Simplify Curves (curve_simplify).

''"After first start everything should be set up. If you don't see CAM tabs on the right side, go to preferences-addons and enable the Simplify curves addon and CAM addon. Also, if Blender CAM tabs don't show, change Blender Render to  Blender CAM [or print_3d] in the upper header." (Vilem Novak, BlenderCAM creator)''


Setup:
---
WARNING: DON'T USE YOUR ART BLENDER SETUP FOR THIS! DOWNLOAD ANOTHER ONE OR COPY THE EXISTING BLENDER FOLDER. (Because a new config is copied automatically to the blender in the folder blender-srouce. Better to be safe!)


### Download Script:

    cd
    git clone https://github.com/faerietree/blendercam.git

OR (quicker)

    cd
    git clone git@github.com:faerietree/blendercam.git



### Download Blender of your choice:

http://download.blender.org/release/Blender2.73/ (for example)


### Unpack into blender-source or create a symbolic link:
Note: Adapt blender version to the one you donwloaded and remove rc1 if you're not using a release candidate.

    cd
    ln -s $HOME/blender-2.73-rc1-linux-glibc211-x86_64/2.73 blender-source

Usage:
---

* Make script executable (required only once):

        chmod +x ~/blendercam/buildblendercam_on_linux.sh

* Launch this convenience script:

        /path/to/buildblendercam_on_linux.sh

    For example:

        ~/blendercam/buildblendercam_on_linux.sh

    For testing use, if you know the downloads are intact/not broken:

        ~/blendercam/buildblendercam_on_linux.sh --no-redownload

    Force rebuild of the matching python using:

        ~/blendercam/buildblendercam_on_linux.sh --rebuild


    Expert mode:

        ~/path/to/buildblendercam_on_linux.sh --no-redownload --rebuild-python --install-missing-packages --aptitude --yaourt --package-manager-install-command='yum install'


* Follow the progress of the script, it may need input (for package manager or library build or to remove downloaded files, use CTRL+C when asked for an administrator password if you don't trust, then you'll see that the removed files are just the downloaded ones.).


