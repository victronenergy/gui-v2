#!/bin/bash

# This script builds GUIv2 for a GX device
# To install requirements for building the GUIv2, execute build-gx-install-requirements.sh once
# For more informations and requirements see
# https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2


# Check if the script is run on Ubuntu 24.x or later
if [[ "$(lsb_release -is)" == "Ubuntu" && "$(lsb_release -rs)" =~ ^24 ]]; then
    echo "Running on Ubuntu 24.x or later"
else
    echo "This script requires Ubuntu 24.x or later"
    exit 1
fi


# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "${1}" in
        # do not delete build files
        -P|--preserve)
            PRESERVE=1
            shift
            ;;
        # IP or hostname of the GX device for direct upload
        -H|--host)
            HOST="${2}"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ${0} [options]"
            echo "Options:"
            echo "  -P, --preserve   Do not delete build files"
            echo "  -H, --host       IP or hostname of the GX device for direct upload"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        # If the option is not recognized, print an error message
        *)
            echo "Unknown option: ${1}"
            ;;
    esac
done


if [ ! -f "/opt/venus/current/environment-setup-cortexa8hf-neon-ve-linux-gnueabi" ]; then
    echo "ERROR: Venus OS SDK was not found."
    echo "Execute \"./build-gx-install-requirements.sh\" once or visit this link for how to install and use the SDK: https://github.com/victronenergy/venus/wiki/howto-install-and-use-the-sdk"
    exit 1
fi


# Go to the parent directory of the script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "${BASE_DIR}"
echo "Changed to parent directory: $(pwd)"

# Source the SDK environment
. /opt/venus/current/environment-setup-cortexa8hf-neon-ve-linux-gnueabi

# Checkout the branch you want to build, if not already on it
# git checkout -b main origin/main

# Update the submodules
git submodule update --init

# Clean build directory
if [[ -d "build-gx" && -z ${PRESERVE} ]]; then
    echo "Cleaning build directory..."
    rm -rf "build-gx"
fi

# Create build directory
if [[ ! -d "build-gx" ]]; then
    echo "Creating build directory..."
    mkdir "build-gx"
fi

cd "build-gx"


# Configure the project with CMake, setting the build type to MinSizeRel (minimum size release)
cmake -DCMAKE_BUILD_TYPE=MinSizeRel ..

# Build the project using CMake with the MinSizeRel configuration
cmake --build . --config MinSizeRel --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo
    echo -e "\e[31m*** ERROR: Build failed ***\e[0m"
    exit 1
else
    echo
    echo -e "\e[32m*** Build successful ***\e[0m"
fi


# Make sure, current path ends with build-gx
if [ "${PWD##*/}" = "build-gx" ]; then
    if [ -d "../build-gx_files_to_copy" ]; then
        rm -rf ../build-gx_files_to_copy
    fi

    # Create output directory
    mkdir ../build-gx_files_to_copy

    # Copy the files to the output directory
    cp venus-gui-v2/Main.qml ../build-gx_files_to_copy
    cp venus-gui-v2/qmldir ../build-gx_files_to_copy
    cp bin/venus-gui-v2 ../build-gx_files_to_copy
    cp -r Victron ../build-gx_files_to_copy
else
    echo "Current directory is not build-gx. Aborting to avoid unwanted deleting of files."
fi

echo "Elapsed time: ${SECONDS} seconds"
echo


# Check if HOST is set
if [[ -n "${HOST}" ]]; then
    echo
    echo -e "\e[33mThe automated file upload to the GX device after build was selected\e[0m"

    # Check if an SSH key exists
    if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
        echo "No SSH key found. Generating a new SSH key..."
        ssh-keygen -t rsa -b 2048 -f "${HOME}/.ssh/id_rsa" -N ""
        echo
    fi

    # Test SSH connection
    echo "Testing SSH connection to ${HOST}..."
    ssh -o BatchMode=yes -o ConnectTimeout=5 root@${HOST} "exit" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo
        echo -e "\e[33mSSH authentication failed. Uploading SSH key to ${HOST}...\e[0m"
        echo -e "\e[33mYou will be prompted for the password to upload the SSH key.\e[0m"
        echo "Make sure you set a password on the GX device else it won't work. See https://www.victronenergy.com/live/ccgx:root_access#root_access"
        echo
        ssh-copy-id root@${HOST}
        if [ $? -ne 0 ]; then
            echo -e "\e[31mFailed to upload SSH key. Please check your password and try again.\e[0m"
            exit 1
        fi
        echo
        echo -e "\e[32mSSH key uploaded successfully.\e[0m"
    else
        echo -e "\e[32mSSH authentication successful.\e[0m"
    fi
    echo

    # Make filesystem writable
    echo -n "Making GX device filesystem writable..."
    ssh root@${HOST} "/opt/victronenergy/swupdate-scripts/remount-rw.sh"
    echo " done."

    # Stop service on the GX device
    echo -n "Stopping service on the GX device..."
    ssh root@${HOST} "svc -d /service/start-gui"
    echo " done."

    # Upload the files to the GX device
    echo "Uploading files to the GX device at ${HOST}..."

    # Copy the files to the GX device, only output errors
    scp -r ../build-gx_files_to_copy/* root@${HOST}:/opt/victronenergy/gui-v2/ 1>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "\e[31mFailed to upload files. Please check your connection and disk space on the GX device then try again.\e[0m"
        echo
        echo "GX device disk space:"
        ssh root@${HOST} "df -h | head -n 2"
        echo
        exit 1
    fi
    echo -e "\e[32mFiles uploaded successfully.\e[0m"
    echo

    # Start service on the GX device
    echo -n "Starting service on the GX device..."
    ssh root@${HOST} "svc -u /service/start-gui"
    echo " done."
    echo
fi
