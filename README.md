BlenderCAM
=====
http://blendercam.blogspot.cz/
Thanks to our hero Vilem Novak for making blender engineers happy!

Download, update, library build, setup convenience script.
-----

Note: It may be that the current blenderCAM addon is not yet compatible with the newest blender! It was compatible with the rc1 of 2.73.
Important: Make sure that the link in the `BLENDER_RELEASE_PATH` points to `blenderfiles/2.xy/` and not just to `blenderfiles/`.

Blender Addon Prerequisites:
------
Note: BlenderCAM tries to enable these automatically but it may fail.
* Simplify Curves (`curve_simplify`).

*"After first start everything should be set up. If you don't see CAM tabs on the right side, go to preferences-addons and enable the Simplify curves addon and CAM addon. Also, if Blender CAM tabs don't show, change Blender Render to  Blender CAM [or `print_3d`] in the upper header." (Vilem Novak, BlenderCAM creator)*

Dependencies:
---
* http://github.com/faerietree/shell_coexist_python_version


Setup:
---
WARNING: DON'T USE YOUR ART BLENDER SETUP FOR THIS! DOWNLOAD ANOTHER ONE OR COPY THE EXISTING BLENDER FOLDER. (Because a new config is copied automatically to the blender in the folder blender-srouce. Better to be safe!)


### Download script + dependency:

    cd
    git clone https://github.com/faerietree/shell__coexist_python_version.git
    git clone https://github.com/faerietree/shell__blendercam_convenience_script.git

OR (quicker)

    cd
    git clone git@github.com:faerietree/shell__coexist_python_version.git
    git clone git@github.com:faerietree/shell__blendercam_convenience_script.git



### Download Blender of your choice:

http://download.blender.org/release/Blender2.73/ (for example)


### Unpack into blender-source or create a symbolic link:
Note: Adapt blender version to the one you downloaded / copied.

    cd
    ln -s ~/blender-2.73-linux-glibc211-x86_64/2.73 ~/blendercam

Usage:
---

* Make script executable (required only once):

        chmod +x /path/to/buildblendercam_on_linux.sh

* Launch this convenience script:

        /path/to/buildblendercam_on_linux.sh

    For example:

        BLENDER_RELEASE_PATH=~/blendercam ~/shell__blendercam_convenience_script/buildblendercam_on_linux.sh

    For testing use, if you know the downloads are intact/not broken:

        ~/shell__blendercam_convenience_script/buildblendercam_on_linux.sh --no-redownload

    Force rebuild of the matching python using:

        ~/shell__blendercam_convenience_script/buildblendercam_on_linux.sh --rebuild


    Expert mode:

        ~/path/to/buildblendercam_on_linux.sh --no-redownload --rebuild-python --install-missing-packages --aptitude --yaourt --package-manager-install-command='yum install'


* Follow the progress of the script, it may need input (for package manager or library build or to remove downloaded files, use CTRL+C when asked for an administrator password if you don't trust, then you'll see that the removed files are just the downloaded ones.).


