BlenderCAM
=====
http://blendercam.blogspot.cz/
Thanks to our hero Vilem Novak for making blender engineers happy! 

Download, update, library build, setup convenience script.
-----

Note: It may be that the current blenderCAM addon is not yet compatible with the newest blender!

Blender Addon Prerequisites:
------
* Simplify Curves (curve_simplify)
"After first start everything should be set up. If you don't see CAM tabs on the right side, go to preferences-addons and enable the Simplify curves addon and CAM addon. Also, if Blender CAM tabs don't show, change Blender Render to  Blender CAM [or print_3d] in the upper header." (Vilem Novak, BlenderCAM creator)

Usage:
---

* Create link blender-source in your Home directory (adapt version and remove rc1):

        cd $HOME
        ln -s ./blender-2.73-rc1-linux-glibc211-x86_64/2.73 blender-source

* Make script executable (required only once):

        chmod +x ~/path/to/buildblendercam_on_linux.sh

* Launch this convenience script:

        ~/path/to/buildblendercam_on_linux.sh
Expert mode:

        ~/path/to/buildblendercam_on_linux.sh --no-redownload --install-missing-packages --aptitude --yaourt --package-manager-install-command='yum install'


* Follow the progress of the script, it may need input.


