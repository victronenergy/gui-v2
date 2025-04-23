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
