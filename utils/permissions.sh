#!/bin/bash

# Function to add command to PATH in .bashrc and refresh it
add_to_path() {
    local cmd_path=$1
    local cmd_name=$2

    echo "$cmd_name command not found. Attempting to add $cmd_path to PATH in .bashrc."

    read -rp "Do you want to proceed? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            # Appending export command to .bashrc
            echo "export PATH=\$PATH:$cmd_path" >> ~/.bashrc

            # Sourcing .bashrc to refresh current shell environment
            source ~/.bashrc

            # Verifying if command is now accessible
            if command -v "$cmd_name" >/dev/null 2>&1; then
                echo "$cmd_name is now available."
            else
                echo "Failed to add $cmd_name to PATH. Please add it manually."
            fi
            ;;
        *)
            echo "Skipping $cmd_name. The script might not work as expected."
            ;;
    esac
}

# Check if zfs command is available
check_zfs(){
    command -v zfs >/dev/null 2>&1 || add_to_path "/usr/sbin" "zfs"
}

# Check if k3s command is available
check_k3s(){
    command -v k3s >/dev/null 2>&1 || add_to_path "/usr/local/bin" "k3s"
}

# Check if cli command is available
check_cli(){
    command -v cli >/dev/null 2>&1 || add_to_path "/usr/bin" "cli"
}

check_root(){
    if [[ $EUID -ne 0 ]]; then
        echo "This command must be run as root or with sudo."
        exit 1
    fi
}