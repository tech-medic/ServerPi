#!/usr/bin/env python3

import yaml
import subprocess
import re
import glob

# Function to execute a shell command and return the output
def execute_command(command):
    return subprocess.check_output(command, shell=True).decode()

# Function to find the netplan configuration file
def find_netplan_file():
    netplan_files = glob.glob("/etc/netplan/*.yaml")
    if netplan_files:
        return netplan_files[0]
    else:
        raise FileNotFoundError("No Netplan configuration file found.")

# Get the current network configuration
netplan_file = find_netplan_file()
netplan_config = yaml.safe_load(execute_command(f'sudo cat {netplan_file}'))

# Get the current network interface
interface = list(netplan_config['network']['ethernets'].keys())[0]

# Print the current configuration
print("Current configuration:")
print("Interface:", interface)
print("IP address:", netplan_config['network']['ethernets'][interface].get('addresses'))
print("Gateway:", netplan_config['network']['ethernets'][interface].get('gateway4'))
print("Nameservers:", netplan_config['network']['ethernets'][interface].get('nameservers'))

# Ask the user what IP should be set as static
new_ip = input("Enter the new static IP address: ")

# Update the configuration with the new IP address
netplan_config['network']['ethernets'][interface]['addresses'] = [new_ip + "/24"]

# Ask the user if the other settings are correct
gateway_correct = input("Is the gateway correct? (yes/no): ")
if gateway_correct.lower() != 'yes':
    new_gateway = input("Enter the new gateway: ")
    netplan_config['network']['ethernets'][interface]['gateway4'] = new_gateway

nameservers_correct = input("Are the nameservers correct? (yes/no): ")
if nameservers_correct.lower() != 'yes':
    new_nameservers = input("Enter the new nameservers (comma separated): ")
    netplan_config['network']['ethernets'][interface]['nameservers']['addresses'] = new_nameservers.split(',')

# Write the new configuration back to the file
with open(netplan_file, 'w') as file:
    documents = yaml.dump(netplan_config, file)

# Apply the new configuration
execute_command('sudo netplan apply')
