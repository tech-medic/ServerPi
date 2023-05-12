#!/bin/bash

# Script to install the LAMP stack

lamp_install() {
    # Update the package list
    apt update

    # Install Apache
    apt install -y apache2
    if [ $? -ne 0 ]; then
        echo "Failed to install Apache."
        exit 1
    fi

    # Install MySQL Server
    apt install -y mysql-server
    if [ $? -ne 0 ]; then
        echo "Failed to install MySQL Server."
        exit 1
    fi

    # Install PHP
    apt install -y php libapache2-mod-php php-mysql
    if [ $? -ne 0 ]; then
        echo "Failed to install PHP and related modules."
        exit 1
    fi
}

lamp_config() {
    # Start Apache to load the PHP module
    systemctl start apache2
    systemctl enable apache2

    # Start MySQL 
    systemctl start mysql
    systemctl enable mysql

    # Secure MySQL
    mysql_secure_installation

    # Make sample PHP page
    bash -c 'echo "<?php
   phpinfo();
    ?>" > /var/www/html/info.php'

    # Check if UFW is active
    if ufw status | grep -q 'inactive'; then
        echo "UFW is inactive. Starting UFW..."
        ufw enable
    fi

    # Configure the firewall
    ufw allow in "Apache Full"
    if [ $? -ne 0 ]; then
        echo "Failed to update firewall rules."
        exit 1
    fi
    ufw reload

    echo "LAMP stack installed and configured successfully."
}


# Function to clone the repository and move files to /var/www/html
install_website() {
    # Ask the user if they want to install the website
    read -p "Do you want to install the website? (y/n) " answer

    case ${answer:0:1} in
        y|Y|yes|Yes )
            # Navigate to a temporary directory
            cd /tmp

            # Clone the repository
            git clone https://github.com/The-WebOps-Club/personal-website-template.git
            if [ $? -ne 0 ]; then
                echo "Failed to clone the repository."
                exit 1
            fi

            # Remove the current index.html file
            sudo rm /var/www/html/index.html

            # Move the files from the cloned repository to /var/www/html
            sudo cp -r personal-website-template/* /var/www/html/

            echo "Website files successfully installed to /var/www/html."
        ;;
        * )
            echo "Installation cancelled."
            exit 1
        ;;
    esac
}

# Call functions
lamp_install
lamp_config
install_website