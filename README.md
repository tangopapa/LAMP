# LAMP
Unattended install of LAMP stack on Debian 9 (Stretch)

To use: ./build-lamp.sh

To cleanup MariaDB, Apache2, & PHP 7 after install, run: cleanup.sh

The build-lamp.sh script does not configure WordPress. It creates an instance of Apache2, 
& the necessary PHP components that WordPress requires.  Then, it creates an instance of MariaDB, 
populates it with the user, password, & database - wp_user, wp_password, & wp_database.

Browse to http://localhost & you'll be presented with the Wordpress 5 min install screen.

NOTE: This script is only for testing since the Wordpress user, password, & database are all
sitting in plain text in the script.  

These scripts are useful as part of a process for testing Jenkins pipeline builds



