#!/bin/bash

# This script installs or updates the dependencies needed to build the GUIv2 as WebAssembly


# Check if the script is run on Ubuntu 24.x or later
if [[ "$(lsb_release -is)" == "Ubuntu" && "$(lsb_release -rs)" =~ ^24 ]]; then
    echo "Running on Ubuntu 24.x or later"
else
    echo "This script requires Ubuntu 24.x or later"
    exit 1
fi

# Check architecture
arch=$(dpkg --print-architecture)
if [ "${arch}" == "arm64" ]; then
    install_os="linux_arm64"
    install_gcc="gcc_arm64"
    echo "ERRUR: ARM64 is currently not supported by this script. You have to manually install the required dependencies."
    echo "       See https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2"
    exit 1
else
    install_os="linux"
    install_gcc="gcc_64"
fi


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


# Install/Update dependencies
echo -e "\n\n*** Installing dependencies ***"
sudo apt-get update -yq
sudo apt-get install -y  g++ build-essential mesa-common-dev libssl-dev \
                        wget libgl1-mesa-dev libxkbcommon-x11-0 libpulse-dev p7zip-full \
                        ninja-build dos2unix libegl1 cmake

# Install yq
echo -e "\n\n*** Installing yq ***"
sudo snap install yq

# Set up Python 3.x
echo -e "\n\n*** Setting up Python 3.x ***"
sudo apt-get install python3-venv -y
sudo python3 -m venv /opt/venus/python

# Change ownership of the Python directory
sudo chown -R ${USER}:${USER} /opt/venus/python

# Activate the Python environment
source /opt/venus/python/bin/activate

# Install aqtinstall
echo -e "\n\n*** Installing aqtinstall ***"
pip install aqtinstall

# Create the output directory and change ownership
sudo mkdir -p ${OUTPUTDIR}
sudo chown -R ${USER}:${USER} ${OUTPUTDIR}

# Install Qt
echo -e "\n\n*** Installing Qt for desktop ***"
aqt install-qt ${install_os} desktop ${QT_VERSION} ${install_gcc} -m qtwebsockets qt5compat qtshadertools --outputdir ${OUTPUTDIR}/Qt

echo -e "\n\n*** Installing Qt for WebAssembly ***"
aqt install-qt ${install_os} desktop ${QT_VERSION} wasm_singlethread -m qtwebsockets qt5compat qtshadertools --outputdir ${OUTPUTDIR}/Qt

echo -e "\n\n*** Installing Qt tools ***"
aqt install-tool ${install_os} desktop tools_cmake --outputdir ${OUTPUTDIR}/Qt
rm aqtinstall.log

sudo chown -R ${USER}:${USER} ${OUTPUTDIR}

echo -e "\n\n*** Applying Qt fixes ***"
# Check if qt-fixes.sh has LR line endings and convert them
dos2unix ${BASE_DIR}/.github/patches/qt-fixes.sh
# Apply the Qt fixes (e.g. file permissions)
sudo bash ${BASE_DIR}/.github/patches/qt-fixes.sh

# Install emscripten
echo -e "\n\n*** Installing Emscripten ***"
cd ${OUTPUTDIR}
if [ -d "emsdk" ]; then
    rm -rf "emsdk"
fi
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install ${EMSCRIPTEN}
./emsdk activate ${EMSCRIPTEN}
source "${OUTPUTDIR}/emsdk/emsdk_env.sh"


# Build and install QtMQTT
echo -e "\n\n*** Building and installing QtMQTT ***"
cd ${OUTPUTDIR}
if [ -d "qtmqtt" ]; then
    rm -rf "qtmqtt"
fi
git clone https://github.com/qt/qtmqtt.git
cd qtmqtt
git checkout ${QT_VERSION}
if [ -d "build-qtmqtt" ]; then
    rm -rf "build-qtmqtt"
fi
mkdir build-qtmqtt
cd build-qtmqtt
export PATH=${OUTPUTDIR}/Qt/Tools/CMake/bin:${PATH}
export QTDIR=${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread
${QTDIR}/bin/qt-configure-module ../
cmake --build .
cmake --install . --prefix ${QTDIR} --verbose

# Change ownership of the output directory
sudo chown -R ${USER}:${USER} ${OUTPUTDIR}
