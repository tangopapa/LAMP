DROP USER IF EXISTS wp_user;
CREATE USER 'wp_user' IDENTIFIED BY 'wp_password'; 
DROP DATABASE IF EXISTS wp_database; 
CREATE DATABASE wp_database; 
GRANT ALL ON wp_database.* TO 'wp_user'; 
FLUSH PRIVILEGES;
exit;