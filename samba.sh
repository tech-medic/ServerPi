#!/bin/bash

# Function to install Samba
samba_install() {
    # Update the package list
    apt update

    # Install Samba
    apt install -y samba smbclient cifs-utils
    if [ $? -ne 0 ]; then
        echo "Failed to install Samba."
        exit 1
    fi
    echo "Samba installed successfully."
}

# Function to configure Samba
samba_config() {
    # Create a directory to share
    mkdir /srv/samba/Shared
    chmod 2775 /srv/samba/Shared
    chown nobody:nogroup /srv/samba/Shared

    # Backup the original Samba configuration file
    cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

    # Add the new Samba share to the configuration file
    echo "
[Shared]
    path = /srv/samba/Shared
    browsable = yes
    guest ok = yes
    read only = no
    create mask = 0755
    " | tee -a /etc/samba/smb.conf

    # Add firewall rule
    ufw allow samba

    # Restart Samba service
    systemctl restart smbd

    echo "Samba configured successfully."
}

# Function to add Samba user
# Function to add Samba user
samba_add_user() {
    # Prompt for username
    echo "Please enter a new username for the Samba share:"
    read username

    # Add the new Samba user
    smbpasswd -a $username
    
    # Prompt the user to enter the password interactively
    echo "Please enter a password for the new user:"
    smbpasswd $username

    # Enable the Samba user
    smbpasswd -e $username

    echo "Samba user $username added successfully."
}


# Call functions
samba_install
samba_config
samba_add_user
echo "Samba successfully installed!"