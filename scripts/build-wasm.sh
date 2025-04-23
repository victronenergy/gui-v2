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

# Update the submodules
git submodule update --init

# Cleanup old build directory
if [ -d "build-wasm" ]; then
    rm -rf "build-wasm"
fi

# Create build directory
mkdir "build-wasm"

cd "build-wasm"


# Configure the project with CMake, setting the build type to MinSizeRel (minimum size release)
${QTDIR}/bin/qt-cmake -DCMAKE_BUILD_TYPE=MinSizeRel ..

# Build the project using CMake with the MinSizeRel configuration
cmake --build .

if [ $? -ne 0 ]; then
    echo
    echo "ERROR: Build failed."
    exit 1
else
    echo
    echo "*** Build successful. ***"
    echo
fi


# Cleanup old artifacts directory
if [ -d "artifacts" ]; then
    rm -rf "artifacts"
fi

# Prepare files that are needed for the GUIv2 to run
mkdir -p artifacts/wasm
mv venus-gui-v2.{html,js,wasm} qtloader.js artifacts/wasm/
cp ../images/victronenergy.svg ../LICENSE.txt ../.github/patches/Makefile artifacts/wasm/
cp -r ../wasm/icons artifacts/wasm/
mv artifacts/wasm/venus-gui-v2.html artifacts/wasm/index.html
grep -q -E '^var createQtAppInstance' artifacts/wasm/venus-gui-v2.js
sed -i "s%^var \(createQtAppInstance\)%window.\1%" artifacts/wasm/venus-gui-v2.js
cd artifacts/wasm
gzip -k -9 venus-gui-v2.wasm
sha256sum venus-gui-v2.wasm > venus-gui-v2.wasm.sha256
rm venus-gui-v2.wasm
cd ../..


# Delete all files and folders except for artifacts
# Make sure, current path ends with build-wasm
if [ "${PWD##*/}" = "build-wasm" ]; then
    find . -mindepth 1 -maxdepth 1 ! -name 'artifacts' -exec rm -rf {} +
    mv artifacts/wasm . && rmdir artifacts
else
    echo "Current directory is not build-wasm. Aborting to avoid unwanted deleting of files."
fi
