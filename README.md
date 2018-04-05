# Enable a LAMP stack to be built & configured non-interactively

The first method, LAMP-SH, is an unattended install & config from the command line.

The second method, DOCKER-LAMP, instantiates & configures a docker container with a functional LAMP stack

# LAMP-SH
Unattended install of LAMP stack tested on Debian 9 (Stretch)

To use: ./build-lamp.sh

To remove MariaDB, Apache2, & PHP 7 after install, run: cleanup.sh

The build-lamp.sh script does not configure WordPress. It creates an instance of Apache2, 
& the necessary PHP components that WordPress requires.  Then, it creates an instance of MariaDB, 
populates it with the user, password, & database params - wp_user, wp_password, & wp_database.

Browse to http://localhost & you'll be presented with the Wordpress 5 min install screen.

NOTE: This script is only for testing since the Wordpress user, password, & database are all
sitting in plain text in the script.  

These files are useful as part of a process for testing Jenkins pipeline builds

# DOCKER-LAMP:
Make sure that you have docker-ce installed. For detailed instructions on how to install docker-ce on debian Stretch go here: https://github.com/tangopapa/dockter-tom/blob/master/docs/Running%20dockter-tom%20%26%20LAMP.docx 

Run: ./lamp-build.sh

After the image builds, launch the container as follows:

docker run -dit -p 22:22 -p 80:80 -p 443:443 -p 3306:3306 lamp

This creates a target container that contains common applications,
configured & listening on open ports 22, 80, 443, & 3306.

Useful for testing DAST security scanning in sidecar pattern.

