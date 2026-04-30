#!/bin/bash

# This script builds GUIv2 as WebAssembly
# To install requirements for building the GUIv2, execute build-wasm-install-requirements.sh once
# For more informations and requirements see
# https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2


# Check if the script is run on Ubuntu 22.x or later
UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
if [[ "$(lsb_release -is)" == "Ubuntu" && "$UBUNTU_VERSION" -ge 22 ]]; then
    echo "Running on Ubuntu $(lsb_release -rs | cut -f1)"
else
    echo -e "\033[1;33mThis script requires Ubuntu 22.x or later\033[0m"
    exit 1
fi

# Detect WSL (Windows Subsystem for Linux) - clock skew on DrvFs mounts causes build failures
if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME}" ]; then
    IS_WSL=1
    echo -e "\033[1;33mWSL detected: using /tmp for build files to avoid clock skew issues on DrvFs mounts\033[0m"
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
            HOST_LIST="${2}"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ${0} [options]"
            echo "Options:"
            echo "  -P, --preserve   Do not delete build files"
            echo "  -H, --host       IP(s) or hostname(s) of the GX device for direct upload, comma separated"
            echo "                   Example:"
            echo "                       -H venus.local"
            echo "                       -H 192.168.1.10"
            echo "                       -H 192.168.1.10,192.168.1.11"
            echo "                       -H einstein,ekrano"
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

# Use /tmp for build/staging directories on WSL to avoid clock skew on DrvFs mounts
if [[ -n "${IS_WSL}" ]]; then
    BUILD_DIR="/tmp/victronenergy/$(basename "${BASE_DIR}")/build-wasm"
    FILES_DIR="${BASE_DIR}/build-wasm_files_to_copy"
    echo "WSL detected: using ${BUILD_DIR} to avoid clock skew"
else
    BUILD_DIR="${BASE_DIR}/build-wasm"
    FILES_DIR="${BASE_DIR}/build-wasm_files_to_copy"
fi


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
if [[ -d "${BUILD_DIR}" && -z ${PRESERVE} ]]; then
    echo "Cleaning build directory..."
    rm -rf "${BUILD_DIR}"
fi

# Create build directory
if [[ ! -d "${BUILD_DIR}" ]]; then
    echo "Creating build directory..."
    mkdir -p "${BUILD_DIR}"
fi

cd "${BUILD_DIR}"


# Configure the project with CMake, setting the build type to MinSizeRel (minimum size release)
echo -e "\n\n\e[33mConfiguring project with CMake...\e[0m\n\n"
${QTDIR}/bin/qt-cmake -DCMAKE_BUILD_TYPE=MinSizeRel "${BASE_DIR}"

echo -e "\n\n\e[33mBuilding project with CMake...\e[0m\n\n"
cmake --build . --parallel $(nproc)

if [ $? -ne 0 ]; then
    echo
    echo -e "\e[31m*** ERROR: Build failed ***\e[0m"
    exit 1
else
    echo
    echo -e "\e[32m*** Build successful ***\e[0m"
fi


# Make sure, current path is the build directory
if [ "${PWD}" = "${BUILD_DIR}" ]; then
    if [ -d "${FILES_DIR}" ]; then
        rm -rf "${FILES_DIR}"
    fi

    # Create output directory
    mkdir -p "${FILES_DIR}/wasm"

    # Copy the files to the output directory
    cp venus-gui-v2.{html,js,wasm} qtloader.js \
        "${FILES_DIR}/wasm/"
    cp  "${BASE_DIR}/images/victronenergy.svg" "${BASE_DIR}/images/victronenergy-light.svg" "${BASE_DIR}/images/mockup.svg" "${BASE_DIR}/LICENSE.txt" "${BASE_DIR}/.github/patches/Makefile" \
        "${FILES_DIR}/wasm/"
    cp -r "${BASE_DIR}/wasm/icons" "${FILES_DIR}/wasm/"
    mv "${FILES_DIR}/wasm/venus-gui-v2.html" "${FILES_DIR}/wasm/index.html"

    # Apply patches
    venus_gui_v2_js_file="${FILES_DIR}/wasm/venus-gui-v2.js"

    if grep -q -E '^var createQtAppInstance' "$venus_gui_v2_js_file"; then
        sed -i "s%^var \(createQtAppInstance\)%window.\1%" "${FILES_DIR}/wasm/venus-gui-v2.js"
    fi

    # Fix for qt6.8.3 - append $line to the .js file if it's not already there
    line="window.createQtAppInstance = venus_gui_v2_entry;"
    grep -qxF "$line" "$venus_gui_v2_js_file" || echo "$line" >> "$venus_gui_v2_js_file"

    # Save wasm file size to a file
    # this is needed, since the reported size is the compressed size
    # but the downloaded size is shown as uncompressed size, since the browser decompresses it
    stat -c%s "${FILES_DIR}/wasm/venus-gui-v2.wasm" > "${FILES_DIR}/wasm/venus-gui-v2.wasm.size"

    # Compress the wasm file
    gzip -k -9 "${FILES_DIR}/wasm/venus-gui-v2.wasm"
    # Create checksum in the output directory
    cd "${FILES_DIR}/wasm/"
    sha256sum venus-gui-v2.wasm > venus-gui-v2.wasm.sha256
    cd "${BUILD_DIR}"
    # Remove the uncompressed wasm file
    rm "${FILES_DIR}/wasm/venus-gui-v2.wasm"
else
    echo "Current directory is not the build directory. Aborting to avoid unwanted deleting of files."
fi

echo "Elapsed time: ${SECONDS} seconds"
echo


# Check if HOST_LIST is set
if [[ -n "${HOST_LIST}" ]]; then
    echo
    echo -e "\e[33mThe automated file upload to the GX device after build was selected\e[0m"

    # Check if an SSH key exists
    if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
        echo "No SSH key found. Generating a new SSH key..."
        ssh-keygen -t rsa -b 2048 -f "${HOME}/.ssh/id_rsa" -N ""
        echo
    fi

    # Split the HOST_LIST variable by comma
    IFS=',' read -r -a HOSTS <<< "${HOST_LIST}"
    # Loop through each host
    for HOST in "${HOSTS[@]}"; do

        # Test if port 22 is open
        echo -n "Testing if port 22 is reachable on ${HOST}... "
        if nc -z -w 5 "${HOST}" 22; then
            echo -e "\e[32mOK.\e[0m"
        else
            echo -e "\e[31mPort 22 is not reachable on ${HOST}. Please check the IP address and network connection.\e[0m"
            # Skip to the next host
            continue
        fi

        # Test SSH connection
        echo "Testing SSH connection to ${HOST}..."
        ssh -o BatchMode=yes -o ConnectTimeout=5 root@${HOST} "exit"

        if [ $? -ne 0 ]; then
            echo
            echo -e "\e[33mSSH authentication failed. Uploading SSH key to ${HOST}...\e[0m"
            echo -e "\e[33mYou will be prompted for the password to upload the SSH key.\e[0m"
            echo "Make sure you set a password on the GX device else it won't work. See https://www.victronenergy.com/live/ccgx:root_access#root_access"
            echo
            ssh-copy-id root@${HOST}
            if [ $? -ne 0 ]; then
                echo -e "\e[31mFailed to upload SSH key. Please check your password and try again.\e[0m"
                # Skip to the next host
                continue
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
        scp -r "${FILES_DIR}/wasm/"* root@${HOST}:/var/www/venus/gui-v2/ 1>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "\e[31mFailed to upload files. Please check your connection and disk space on the GX device then try again.\e[0m"
            echo
            echo "GX device disk space:"
            ssh root@${HOST} "df -h | head -n 2"
            echo
            # Skip to the next host
            continue
        fi
        echo -e "\e[32mFiles uploaded successfully.\e[0m"
        echo

        # Restart vmrlogger to make GUIv2 changes visible in VRM portal
        echo -n "Restarting vmrlogger on GX device..."
        ssh root@${HOST} "svc -t /service/vrmlogger"
        echo " done."
        echo
    done
fi
