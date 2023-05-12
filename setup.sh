#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

display_network_info {
  # Get IP address, netmask and gateway for eth0
  IP=$(ip -o -4 addr show eth0 | awk '{print $4}')
  GATEWAY=$(ip route | awk '/default/ { print $3 }')

  # Display the information
  echo "IP address: $IP"
  echo "Gateway: $GATEWAY"

  # Ask the user to press enter to continue
  read -p "Press enter to continue"
}

# Perform package update
update_server() {
    echo "Updating package list..."
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "An error occurred while updating the package list. Please check your network connection and try again."
        return 1
    fi
upgrade_server() {}
    echo "Upgrading packages..."
    sudo apt upgrade -y
    if [ $? -ne 0 ]; then
        echo "An error occured"
        return 1
    fi
}

# Function to change the current username
change_username() {
  echo "Current username is $SUDO_USER"
  read -p "Enter the new username: " new_username
  usermod -l $new_username $SUDO_USER
  echo "Username has been changed to $new_username"
}

# Change the Hostname of the server
change_hostname() {
    # Display the current hostname
    echo "Current hostname: $(hostname)"

    # Ask the user for a new hostname
    read -p "Enter a new hostname: " new_hostname

    # Change the hostname
    sudo hostnamectl set-hostname $new_hostname

    # Verify the change
    echo "Hostname changed to: $(hostname)"
    main_menu
}

# Function to set a static IP address
set_ip() {
  echo "Setting IP..."
  python3 set-static.py
      if [ $? -ne 0 ]; then
        echo "An error occurred while updating the package list. Please check your network connection and try again."
        return 1
    fi
  display_network_info
  main_menu
}

# Function to set up SSH/Samba/LAMP/Node.JS
setup_services() {
  echo "1) SSH" 
  echo "2) LAMP" 
  echo "3) Samba" 
  echo "4) Node.js" 
  echo "5) Back to main menu"
  read -p "Which service do you want to install?" service

  case $service in
    1)
    echo "Installing SSH..."
    . ./ssh.sh
    if [ $? -ne 0 ]; then
        echo "An error occurred while installing SSH."
        return 1
    fi    
    ;;
    2)
    echo "Installing LAMP stack..."
    . ./lamp.sh
    if [ $? -ne 0 ]; then
        echo "An error occurred while installing the LAMP stack."
        return 1
    fi
    ;;
    3)
    echo "Installing Samba..."
    . ./samba.sh
    if [ $? -ne 0 ]; then
        echo "An error occurred while installing Samba."
        return 1
    fi
    ;;
    4)
    echo "Installing Node.js..."
    apt install nodejs npm
    if [ $? -ne 0 ]; then
        echo "An error occurred while installing Node.js."
        return 1
    fi
    ;;
    5)
    main_menu
    ;;
  esac
}

# Function to Create Issue.net and MOTD
modify_issue_motd() {
    echo "**************************** SSH Banner *****************************"
    echo "1) View current SSH Banner"
    echo "2) Change SSH Banner with a custom text"
    echo "3) Use a pre-existing issue.net from banner_files directory"
    echo "4) View current MOTD"
    echo "5) Change MOTD with a custom text"
    echo "6) Use a pre-existing motd from banner_files directory"
    echo "7) Back to main menu"
    read -p "Choose an option: " motd

    case $motd in
        1) 
        cat /etc/issue.net
        ;;
        2) 
        nano /etc/issue.net
        ;;
        3)
        read -p "Enter the name of issue.net file in banner_files directory: " issue_file
        cp ./banner_files/$issue_file /etc/issue.net
        ;;
        4) 
        cat /etc/motd
        ;;
        5) 
        nano /etc/motd
        ;;
        6)
        read -p "Enter the name of motd file in banner_files directory: " motd_file
        cp ./banner_files/$motd_file /etc/motd
        ;;
        7)
        main_menu
        ;;
        *)
        echo "Invalid option"
        modify_issue_motd
        ;;
    esac
}



# Function to install python and pip
install_python_pip() {
  echo "Installing Python and Pip..."
  update_server

  apt install -y python3
      if [ $? -ne 0 ]; then
        echo "An error occurred while updating the package list. Please check your network connection and try again."
        return 1
    fi

  apt install -y python3-pip
      if [ $? -ne 0 ]; then
        echo "An error occurred while updating the package list. Please check your network connection and try again."
        return 1
    fi

  echo "Python3 and pip installation complete!"
    # Back to the main menu
    main_menu
}

check_app() {
    local app="$1"

    # Check if the command is available
    if ! command -v "$app" &> /dev/null; then
        echo "The '$app' command is not available. Attempting to install..."
        sudo apt update
        sudo apt install -y "$app"
    else
        echo "The '$app' command is already installed."
    fi
}

enable_auto_updates() {
    # Install the unattended-upgrades package
    apt install -y unattended-upgrades

    # Enable automatic updates
    dpkg-reconfigure --priority=low unattended-upgrades

    # Check if automatic updates are enabled
    AUTO_UPDATES=$(dpkg-query -W -f='${db:Status-Status}\n' 'unattended-upgrades')
    if [ "$AUTO_UPDATES" = "installed" ]; then
        echo "Automatic security updates have been enabled."
    else
        echo "Failed to enable automatic security updates."
        exit 1
    fi
}

install_package() {
    echo "**************************** Apt Packages *****************************"
    echo "1) Upgrade all packages"
    echo "2) Figlet"
    echo "3) Cowsay"
    echo "4) Fortune"
    echo "5) nmap"
    echo "6) Googler"
    echo "7) Boxes"
    echo "8) Shred"
    echo "9) Package 4"
    echo "10) Package 4"
    echo " "
    echo "Back to main menu"
    echo "Choose an option:"
printf "%s\t%s\t%s\t%s\n" "1) Option 1" "2) Option 2" "3) Option 3" "4) Option 4"
printf "%s\t%s\t%s\t%s\n" "5) Option 5" "6) Option 6" "7) Option 7" "8) Option 8"
read -p "Your choice: " choice

  echo "Q) Go back to main menu"
  read -p "Enter the package number you want to install: " package_selection

  case $package_selection in
    1) 
    update_server
    upgrade_server
    echo "All packages have been upgraded"
    return
    ;;

    2) 
    update_server
    check_app 
    ;;

    3) echo "Installing Package 3"
    update_server
    check_app 
    ;;

    4) echo "Installing Package 4"
    update_server
    check_app 
    ;;

    [Qq]*) return;;
    *) echo "Invalid option";;
  esac
}


Autonomy() {


}

# Main function to display a menu to the user
# Filename to store task status
STATUS_FILE="task_status.txt"

# Initialize the completion status of each task
if [ ! -f $STATUS_FILE ]; then
  echo "0 0 0 0 0 0 0 0 0" > $STATUS_FILE
fi

main_menu() {
  # Load task status from file
  task_status=($(cat $STATUS_FILE))

  echo "Please select an option:"
  echo "${task_status[0]} 1) Automatic install - Not configured"
  echo "${task_status[1]} 2) Change Hostname"
  echo "${task_status[2]} 3) Change username"
  echo "${task_status[3]} 4) Set static IP"
  echo "${task_status[4]} 5) Enable security updates"
  echo "${task_status[5]} 6) Install Python and Pip"
  echo "${task_status[6]} 7) Set up services"
  echo "${task_status[7]} 8) Modify Issue.net and MOTD"
  echo "${task_status[8]} 9) Install individual packages - Not configured"
  echo "Q) Quit"
  read -p "Enter your selection: " selection

  case $selection in
    1) automatic_install
       update_status 1;;
    2) change_hostname
       update_status 2;;
    3) change_username
       update_status 3;;
    4) set_ip
       update_status 4;;
    5) enable_security_updates
       update_status 5;;
    6) install_python_pip
       update_status 6;;
    7) setup_services
       update_status 7;;
    8) modify_issue_motd
       update_status 8;;
    9) install_individual_packages
       update_status 9;;
    [Qq]*) exit;;
    *) echo "Invalid option";;
  esac

  # Save updated task status to the file
  echo "${task_status[@]}" > $
}


# Loop the main menu until the user quits
while true; do
  main_menu
done
