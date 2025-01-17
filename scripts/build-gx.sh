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

# Replace git SSH URLs with HTTPS URLs
# TODO
# .git/config

# Update the submodules
git submodule update --init

# Clean the repository of untracked files and directories
# git clean -fd

# Cleanup old build directory
if [ -d "build-gx" ]; then
    rm -rf "build-gx"
fi

# Create build directory
mkdir "build-gx"

cd "build-gx"


# Configure the project with CMake, setting the build type to MinSizeRel (minimum size release)
cmake -DCMAKE_BUILD_TYPE=MinSizeRel ..

# Build the project using CMake with the MinSizeRel configuration
cmake --build . --config MinSizeRel

if [ $? -ne 0 ]; then
    echo
    echo "ERROR: Build failed."
    exit 1
else
    echo
    echo "*** Build successful. ***"
    echo
fi


# Delete all files and folders except for bin and Victron
# Make sure, current path ends with build-gx
if [ "${PWD##*/}" = "build-gx" ]; then
    find . -mindepth 1 -maxdepth 1 ! -name 'bin' ! -name 'venus-gui-v2' ! -name 'Victron' -exec rm -rf {} +
    mv venus-gui-v2/Main.qml . && mv venus-gui-v2/qmldir . && rm -rf venus-gui-v2
    mv bin/venus-gui-v2 . && rm -rf bin
else
    echo "Current directory is not build-gx. Aborting to avoid unwanted deleting of files."
fi
