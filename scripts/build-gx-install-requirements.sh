#!/bin/bash

# This script installs or updates the dependencies needed to build the GUIv2 for a GX device


# Check if the script is run on Ubuntu 24.x or later
if [[ "$(lsb_release -is)" == "Ubuntu" && "$(lsb_release -rs)" =~ ^24 ]]; then
    echo "Running on Ubuntu 24.x or later"
else
    echo "This script requires Ubuntu 24.x or later"
    exit 1
fi


# Check if curl is installed, if not, install it
if ! command -v curl > /dev/null 2>&1
then
    echo "Curl is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y curl
    echo
fi

# Check if cmake is installed, if not, install it
if ! command -v cmake > /dev/null 2>&1
then
    echo "CMake is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y cmake
    echo
fi

# Check if python3 is installed, if not, install it
if ! command -v python3 > /dev/null 2>&1
then
    echo "Python3 is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y python3
    echo
fi

# Check if xz-utils is installed, if not, install it
if ! command -v xz > /dev/null 2>&1
then
    echo "xz-utils is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y xz-utils
    echo
fi

# Fetch latest SDK version
URL="https://updates.victronenergy.com/feeds/venus/candidate/sdk/"

# Get the HTML content
html_content=$(curl -s ${URL})

# Extract the filename ending with .sh from the HTML content
filename=$(echo "${html_content}" | grep -oP '(?<=href=")[^"]+\.sh' | head -n 1)

# Construct the download URL
download_url="https://updates.victronenergy.com/feeds/venus/candidate/sdk/${filename}"

# Change to the temporary directory
cd "/tmp"

echo "Downloading ${download_url}"

# Fetch the SDK file
curl -O "${download_url}"

# Make the file executable
chmod u+x "${filename}"

# Run the SDK installer
sudo ./${filename} -y

# Check if the SDK was installed successfully
if [ $? -ne 0 ]; then
    echo "ERROR: SDK installation failed."
    exit 1
fi

# Get folder in folder with newest date
folder=$(ls -td /opt/venus/* | head -n 1)

# Fix ownership of the folder
sudo chown -R ${USER}:${USER} "/opt/venus"

# Delete the old symlink, if it exists and create a new one
if [ -L "/opt/venus/current" ]; then
    echo "Removing old symlink /opt/venus/current"
    rm "/opt/venus/current"
fi

ln -s "${folder}" "/opt/venus/current"
