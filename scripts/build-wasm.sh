#!/bin/bash

# This script builds GUIv2 as WebAssembly
# To install requirements for building the GUIv2, execute build-wasm-install-requirements.sh once
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


# Go to the parent directory of the script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
cd "${BASE_DIR}"
echo "Changed to parent directory: $(pwd)"


# Load environment variables from .env file
if [ -f "${BASE_DIR}/scripts/.env" ]; then
    export $(grep -v '^#' "${BASE_DIR}/scripts/.env" | xargs)
else
    echo "## ${BASE_DIR}/scripts/.env file not found!"
    exit 1
fi


export PATH=${OUTPUTDIR}/Qt/Tools/CMake/bin:${PATH}
export QTDIR=${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread

source "${OUTPUTDIR}/emsdk/emsdk_env.sh"
source /opt/venus/python/bin/activate

# Checkout the branch you want to build, if not already on it
# git checkout -b main origin/main

# Update the submodules
git submodule update --init

# Clean build directory
if [[ -d "build-wasm" && -z ${PRESERVE} ]]; then
    echo "Cleaning build directory..."
    rm -rf "build-wasm"
fi

# Create build directory
if [[ ! -d "build-wasm" ]]; then
    echo "Creating build directory..."
    mkdir "build-wasm"
fi

cd "build-wasm"


# Configure the project with CMake, setting the build type to MinSizeRel (minimum size release)
${QTDIR}/bin/qt-cmake -DCMAKE_BUILD_TYPE=MinSizeRel ..

# Build the project using CMake with the MinSizeRel configuration
cmake --build . --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo
    echo -e "\e[31m*** ERROR: Build failed ***\e[0m"
    exit 1
else
    echo
    echo -e "\e[32m*** Build successful ***\e[0m"
fi


# Make sure, current path ends with build-wasm
if [ "${PWD##*/}" = "build-wasm" ]; then
    if [ -d "../build-wasm_files_to_copy" ]; then
        rm -rf ../build-wasm_files_to_copy
    fi

    # Create output directory
    mkdir -p ../build-wasm_files_to_copy/wasm

    # Copy the files to the output directory
    cp venus-gui-v2.{html,js,wasm} qtloader.js \
        ../build-wasm_files_to_copy/wasm/
    cp ../images/victronenergy.svg ../LICENSE.txt ../.github/patches/Makefile \
        ../build-wasm_files_to_copy/wasm/
    cp -r ../wasm/icons ../build-wasm_files_to_copy/wasm/
    mv ../build-wasm_files_to_copy/wasm/venus-gui-v2.html ../build-wasm_files_to_copy/wasm/index.html

    # Apply patches
    grep -q -E '^var createQtAppInstance' ../build-wasm_files_to_copy/wasm/venus-gui-v2.js
    sed -i "s%^var \(createQtAppInstance\)%window.\1%" ../build-wasm_files_to_copy/wasm/venus-gui-v2.js

    # Compress the wasm file
    gzip -k -9 ../build-wasm_files_to_copy/wasm/venus-gui-v2.wasm
    sha256sum ../build-wasm_files_to_copy/wasm/venus-gui-v2.wasm > ../build-wasm_files_to_copy/wasm/venus-gui-v2.wasm.sha256
    rm ../build-wasm_files_to_copy/wasm/venus-gui-v2.wasm
else
    echo "Current directory is not build-wasm. Aborting to avoid unwanted deleting of files."
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
    echo

    # Upload the files to the GX device
    echo "Uploading files to the GX device at ${HOST}..."

    # Copy the files to the GX device, only output errors
    scp -r ../build-wasm_files_to_copy/wasm/* root@${HOST}:/var/www/venus/gui-v2/ 1>/dev/null
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

    # Restart vmrlogger to make GUIv2 changes visible in VRM portal
    echo -n "Restarting vmrlogger on GX device..."
    ssh root@${HOST} "svc -t /service/vrmlogger"
    echo " done."
    echo
fi
