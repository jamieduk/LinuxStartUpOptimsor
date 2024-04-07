#!/bin/bash

# Function to analyze boot logs
analyze_boot_logs() {
    echo "Analyzing boot logs..."
    sudo cat /var/log/boot.log
    sudo cat /var/log/syslog
}

# Function to disable unnecessary services
disable_unnecessary_services() {
    echo "Disabling unnecessary services..."
    sudo update-rc.d -f pi-power-tools remove

    # Disable cups and cups-browsed
    sudo systemctl stop cups cups-browsed
    sudo systemctl disable cups cups-browsed

    # Disable tor
    sudo systemctl stop tor
    sudo systemctl disable tor

    # Disable saned
    sudo systemctl stop saned
    sudo systemctl disable saned

    # Disable speech-dispatcher
    sudo systemctl stop speech-dispatcher
    sudo systemctl disable speech-dispatcher

    # Disable additional non-essential services
    sudo systemctl stop apache-htcacheclean apache-htcacheclean@ cryptdisks-early cryptdisks
    sudo systemctl disable apache-htcacheclean apache-htcacheclean@ cryptdisks-early cryptdisks

    echo "Non-essential services disabled."
}


optimize_startup_programs() {
    echo "Optimizing startup programs..."

    # List startup programs
    echo "Current startup programs:"
    systemctl list-unit-files --type=service | grep enabled

    # Ask user for program to disable
    read -p "Enter the name of the program to disable: " program_name

    # Check if the program exists
    if systemctl is-active --quiet $program_name.service; then
        # Disable the program
        sudo systemctl stop $program_name.service
        sudo systemctl disable $program_name.service
        echo "Program '$program_name' disabled."
    else
        echo "Program '$program_name' does not exist or is already disabled."
    fi
}

# Function to update and upgrade system
update_upgrade_system() {
    echo "Updating and upgrading system..."
    sudo apt update -y && sudo apt upgrade -y
}

# Function to check disk usage
check_disk_usage() {
    echo "Checking disk usage..."
    df -h
}

# Function to clear boot logs
clear_boot_logs() {
    echo "Clearing boot logs..."
    sudo truncate -s 0 /var/log/boot.log
    sudo truncate -s 0 /var/log/syslog
    echo "Boot logs cleared."
}

# Main menu
while true; do
    clear
    echo "===== Raspberry Pi Startup Optimizer ====="
    echo "1. Analyze boot logs"
    echo "2. Disable unnecessary services"
    echo "3. Optimize startup programs"
    echo "4. Update and upgrade system"
    echo "5. Check disk usage"
    echo "6. Clear boot logs"
    echo "7. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) analyze_boot_logs ;;
        2) disable_unnecessary_services ;;
        3) optimize_startup_programs ;;
        4) update_upgrade_system ;;
        5) check_disk_usage ;;
        6) clear_boot_logs ;;
        7) echo "Exiting..."; exit ;;
        *) echo "Invalid choice. Please enter a number between 1 and 7." ;;
    esac

    read -p "Press Enter to continue..."
done

