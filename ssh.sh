#!/bin/bash

# Function to install SSH
install_ssh() {
if ! command -v ssh &> /dev/null; then
    echo "The 'ssh' command is not available. Attempting to install..."
    sudo apt update
    sudo apt install -y openssh-server
    if [ $? -eq 0 ]; then
        echo "SSH installed successfully."
    else
        echo "Error occurred during SSH installation."
        exit 1
    fi
else
    echo "SSH is already installed."
fi

}

# Make firewall rule for SSH
ssh_rule() {
  ufw allow OpenSSH
  ufw reload
}
# Check if SSH service is active
start_ssh() {
if systemctl is-active --quiet ssh; then
    echo "SSH service is already running."
else
    echo "Starting SSH service..."
    sudo systemctl start ssh
    if [ $? -eq 0 ]; then
        echo "SSH service started successfully."
    else
        echo "Error occurred while starting SSH service."
        exit 1
    fi
fi

}

# Function to configure SSH
configure_ssh() {
# Description:
# What should it do?
# * Check whether a /etc/ssh/sshd_config file exists
# * Create a backup of this file
# * Edit the file to set certain parameters
# * Reload the sshd configuration
# To enable debugging mode remove '#' from the following line
#set -x
# Variables

file="$1"
param[1]="PermitRootLogin "
param[2]="PubkeyAuthentication"
param[3]="AuthorizedKeysFile"
param[4]="PasswordAuthentication"
param[5]="Port"

# Functions
usage(){
  cat << EOF
    usage: $0 ARG1
    ARG1 Name of the sshd_config file to edit.
    In case ARG1 is empty, /etc/ssh/sshd_config will be used as default.

    Description:
    This script sets certain parameters in /etc/ssh/sshd_config.
    It's not production ready and only used for training purposes.

    What should it do?
    * Check whether a /etc/ssh/sshd_config file exists
    * Create a backup of this file
    * Edit the file to set certain parameters
EOF
}

backup_sshd_config(){
  if [ -f ${file} ]
  then
    /usr/bin/cp ${file} ${file}.1
  else
    /usr/bin/echo "File ${file} not found."
    exit 1
  fi
}

edit_sshd_config(){
  # Uncomment the Port line
  /usr/bin/sed -i 's/^#'"${param[5]}"' /'"${param[5]}"' /' ${file}

  # Loop through each parameter and replace its value
  for PARAM in ${param[@]}
  do
    # Define the new value for each parameter
    case ${PARAM} in
        "PermitRootLogin ") VALUE="no" ;;
        "PubkeyAuthentication") VALUE="yes" ;;
        "AuthorizedKeysFile") VALUE=".ssh/authorized_keys" ;;
        "PasswordAuthentication") VALUE="no" ;;
        "Port") VALUE="22" ;;  # Edit this line as per your requirement
        *) VALUE="" ;;  # Default case if parameter is not matched
    esac

    # If the parameter is found in the file, replace its value
    if grep -q "^${PARAM}" ${file}; then
        /usr/bin/sed -i "s|^${PARAM}.*|${PARAM}${VALUE}|" ${file}
        /usr/bin/echo "Parameter '${PARAM}' has been set to '${VALUE}' in ${file}."
    else
        # If the parameter is not found in the file, append it
        /usr/bin/echo "${PARAM}${VALUE}" >> ${file}
        /usr/bin/echo "Parameter '${PARAM}' was not found in ${file}. It has been added with value '${VALUE}'."
    fi
  done
}

reload_sshd(){
  /usr/bin/systemctl reload sshd.service
  /usr/bin/echo "Run '/usr/bin/systemctl reload sshd.service'...OK"
}

# main
while getopts .h. OPTION
do
  case $OPTION in
    h)
    usage
    exit;;
    ?)
    usage
    exit;;
  esac
done

if [ -z "${file}" ]
then

file="/etc/ssh/sshd_config"
fi
backup_sshd_config
edit_sshd_config
reload_sshd
}

# Call functions
install_ssh
ssh_rule
configure_ssh /etc/ssh/sshd_config
start_ssh
echo "SSH server setup completed."