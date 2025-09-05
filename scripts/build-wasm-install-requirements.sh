#!/bin/bash

# This script installs or updates the dependencies needed to build the GUIv2 as WebAssembly
# STRICT VERSION: Only uses the version specified in .env, no fallbacks


# Check if the script is run on Ubuntu 22.x or later
UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
if [[ "$(lsb_release -is)" == "Ubuntu" && "$UBUNTU_VERSION" -ge 22 ]]; then
    echo "Running on Ubuntu $(lsb_release -rs | cut -f1)"
else
    echo -e "\033[1;33mThis script requires Ubuntu 22.x or later\033[0m"
    exit 1
fi

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    echo -e "\033[1;33mPlease do NOT run this script as root or with sudo.\nThis will cause file permission problems and the build will fail.\033[0m"
    exit 1
fi

# Check architecture
arch=$(dpkg --print-architecture)
if [ "${arch}" == "arm64" ]; then
    install_os="linux_arm64"
    install_gcc="linux_gcc_arm64"
    echo "ERROR: ARM64 is currently not supported by this script. You have to manually install the required dependencies."
    echo "       See https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2"
    exit 1
else
    install_os="linux"
    # Qt 6.8.3 requires linux_gcc_64 for aqtinstall but installs to gcc_64
    install_gcc="linux_gcc_64"
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

echo "Using Qt version ${QT_VERSION} from .env file (no fallbacks)"
echo "Using architecture: ${install_gcc} for Qt ${QT_VERSION}"


# Install/Update dependencies
echo -e "\n\n*** Installing dependencies ***"
sudo apt-get update -yq
sudo apt-get install -y  g++ build-essential mesa-common-dev libssl-dev \
                        wget libgl1-mesa-dev libxkbcommon-x11-0 libpulse-dev p7zip-full \
                        ninja-build dos2unix libegl1 cmake \
                        libxkbcommon-dev libx11-dev libxcb1-dev libxcb-util-dev \
                        libxcb-keysyms1-dev libxcb-image0-dev libxcb-render-util0-dev \
                        libxcb-randr0-dev libxcb-xinerama0-dev libxcb-shape0-dev \
                        libxcb-sync-dev libxcb-xfixes0-dev libfontconfig1-dev \
                        libfreetype6-dev libwayland-dev
# Check if the installation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
else
    echo "✓ Dependencies installed successfully"
fi

# Install yq
echo -e "\n\n*** Installing yq ***"
# Check if snap is installed
if ! command -v snap &> /dev/null; then
    echo "Snap is not installed, installing snapd..."
    sudo apt-get install -y snapd
fi

# Install yq using snap
sudo snap install yq
# Check if yq was installed successfully
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install yq"
    exit 1
else
    echo "✓ yq installed successfully"
fi

# Set up Python 3.x
echo -e "\n\n*** Setting up Python 3.x ***"
sudo apt-get install python3-venv -y
sudo python3 -m venv /opt/venus/python
# Check if Python virtual environment was created successfully
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create Python virtual environment"
    exit 1
else
    echo "✓ Python virtual environment created successfully"
fi

# Change ownership of the Python directory
sudo chown -R ${USER}:${USER} /opt/venus/python

# Activate the Python environment
source /opt/venus/python/bin/activate

# Install aqtinstall
echo -e "\n\n*** Installing aqtinstall ***"
pip install aqtinstall
# Check if aqtinstall was installed successfully
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install aqtinstall"
    exit 1
else
    echo "✓ aqtinstall installed successfully"
fi

# Apply the critical patch for Qt 6.8.3 nested directory structure
echo -e "\n\n*** Patching aqtinstall for Qt 6.8.3 nested directory support ***"
AQTINSTALL_PATH=$(python -c "import aqt; import os; print(os.path.dirname(aqt.__file__))")
METADATA_FILE="${AQTINSTALL_PATH}/metadata.py"

echo "aqtinstall path: ${AQTINSTALL_PATH}"
echo "metadata.py: ${METADATA_FILE}"

if [ ! -f "${METADATA_FILE}" ]; then
    echo "ERROR: metadata.py not found at ${METADATA_FILE}"
    exit 1
fi

if [ ! -f "${METADATA_FILE}.backup" ]; then
    # Create backup
    cp "${METADATA_FILE}" "${METADATA_FILE}.backup"

    # Apply the specific patch for Qt 6.8.3 nested directory structure
    python3 << 'PATCH_EOF'
import re

metadata_file = "/opt/venus/python/lib/python3.12/site-packages/aqt/metadata.py"

# Read the file
with open(metadata_file, 'r') as f:
    content = f.read()

# Check if patch marker is already present
patch_marker = "# Handle Qt 6.8+ nested directory structure - Victron Energy patch"
if patch_marker in content:
    print("✓ Patch already applied, skipping.")
    exit(0)

# Find the exact line pattern and show it
lines = content.split('\n')
target_line_num = None
target_line = None

for i, line in enumerate(lines):
    if 'rest_of_url' in line and 'posixpath.join' in line and 'Updates.xml' in line:
        target_line_num = i
        target_line = line
        print(f"Found target line {i+1}: {line.strip()}")
        break

if target_line_num is None:
    print("ERROR: Could not find the target line to patch")
    print("Lines containing relevant keywords:")
    for i, line in enumerate(lines):
        if any(keyword in line for keyword in ['rest_of_url', 'Updates.xml', 'posixpath']):
            print(f"Line {i+1}: {line.strip()}")
    exit(1)

# Create the replacement code
replacement_lines = [
    patch_marker,
    "        if folder.startswith(\"qt6_\") and len(folder) == 6 and folder[4:].isdigit():",
    "            version_code = folder[4:]  # Extract version number like \"683\" from \"qt6_683\"",
    "            if int(version_code) >= 680:",
    "                # Qt 6.8+ uses nested structure: qt6_683/qt6_683/Updates.xml",
    "                rest_of_url = posixpath.join(self.archive_id.to_url(), folder, folder, \"Updates.xml\")",
    "            else:",
    "                # Qt 6.7 and below use flat structure: qt6_67x/Updates.xml",
    "                rest_of_url = posixpath.join(self.archive_id.to_url(), folder, \"Updates.xml\")",
    "        else:",
    "            # Default behavior for non-Qt6 or differently named folders",
    "            rest_of_url = posixpath.join(self.archive_id.to_url(), folder, \"Updates.xml\")"
]

# Replace the target line
lines[target_line_num] = '\n'.join(replacement_lines)

# Write back the file
with open(metadata_file, 'w') as f:
    f.write('\n'.join(lines))

print("✓ Successfully patched aqtinstall for Qt 6.8.3 nested directory structure")
PATCH_EOF

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to patch aqtinstall"
        exit 1
    fi
fi # [ ! -f "${METADATA_FILE}.backup" ]

# Create the output directory and change ownership
sudo mkdir -p ${OUTPUTDIR}
sudo chown -R ${USER}:${USER} ${OUTPUTDIR}

# Verify Qt 6.8.3 is available
echo -e "\n\n*** Verifying Qt ${QT_VERSION} availability ***"
echo "Checking if Qt ${QT_VERSION} is available..."

# Check desktop availability
aqt list-qt ${install_os} desktop --arch ${QT_VERSION}
if [ $? -ne 0 ]; then
    echo "ERROR: Qt ${QT_VERSION} is not available for ${install_os} desktop"
    echo "Available Qt versions:"
    aqt list-qt ${install_os} desktop | grep "^6\." | head -10
    exit 1
fi

# Check WebAssembly availability
aqt list-qt all_os wasm --arch ${QT_VERSION}
if [ $? -ne 0 ]; then
    echo "ERROR: Qt ${QT_VERSION} WebAssembly is not available"
    echo "Available WebAssembly versions:"
    aqt list-qt all_os wasm | head -10
    exit 1
fi

echo "✓ Qt ${QT_VERSION} is available for both desktop and WebAssembly"

# Check what archives are available for debugging
echo -e "\n\n*** Checking available archives for Qt ${QT_VERSION} ***"
echo "Available archives:"
aqt list-qt ${install_os} desktop --archives ${QT_VERSION} ${install_gcc}
if [ $? -ne 0 ]; then
    echo "ERROR: Could not list archives"
    echo "This is a hard requirement. No fallbacks allowed."
    exit 1
else
    echo "✓ Archives listed successfully"
fi

# Install Qt for desktop
echo -e "\n\n*** Installing Qt ${QT_VERSION} for desktop ***"
aqt install-qt ${install_os} desktop ${QT_VERSION} ${install_gcc} --outputdir ${OUTPUTDIR}/Qt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install Qt ${QT_VERSION} for desktop"
    echo "This is a hard requirement. No fallbacks allowed."
    exit 1
fi

# Determine the actual installed desktop directory name immediately after installation
if [ -d "${OUTPUTDIR}/Qt/${QT_VERSION}/linux_gcc_64" ]; then
    ACTUAL_DESKTOP_DIR="linux_gcc_64"
elif [ -d "${OUTPUTDIR}/Qt/${QT_VERSION}/gcc_64" ]; then
    ACTUAL_DESKTOP_DIR="gcc_64"
elif [ -d "${OUTPUTDIR}/Qt/${QT_VERSION}/linux_gcc_arm64" ]; then
    ACTUAL_DESKTOP_DIR="linux_gcc_arm64"
elif [ -d "${OUTPUTDIR}/Qt/${QT_VERSION}/gcc_arm64" ]; then
    ACTUAL_DESKTOP_DIR="gcc_arm64"
else
    echo "ERROR: Could not find desktop Qt installation directory"
    echo "Available directories:"
    ls -la ${OUTPUTDIR}/Qt/${QT_VERSION}/
    exit 1
fi

echo "✓ Desktop Qt installed in directory: ${ACTUAL_DESKTOP_DIR}"

# Install Qt for WebAssembly using Qt 6.8+ method
echo -e "\n\n*** Installing Qt ${QT_VERSION} for WebAssembly ***"
aqt install-qt all_os wasm ${QT_VERSION} wasm_singlethread --outputdir ${OUTPUTDIR}/Qt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install Qt ${QT_VERSION} for WebAssembly"
    echo "This is a hard requirement. No fallbacks allowed."
    exit 1
else
    echo "✓ Qt ${QT_VERSION} for WebAssembly installed successfully"
fi

# Install QtShaderTools for WebAssembly
echo -e "\n\n*** Installing QtShaderTools for WebAssembly ***"
aqt install-qt all_os wasm ${QT_VERSION} wasm_singlethread --modules qtshadertools --outputdir ${OUTPUTDIR}/Qt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install QtShaderTools module for WebAssembly"
    echo "This is required for the build to succeed"
    exit 1
else
    echo "✓ QtShaderTools module installed successfully"
fi


# Install QtWebSockets for WebAssembly
echo -e "\n\n*** Installing QtWebSockets for WebAssembly ***"
echo "Installing QtWebSockets module for WebAssembly target..."
aqt install-qt all_os wasm ${QT_VERSION} wasm_singlethread --modules qtwebsockets --outputdir ${OUTPUTDIR}/Qt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install QtWebSockets module for WebAssembly"
    echo "This is required for the build to succeed"
    exit 1
else
    echo "✓ QtWebSockets module installed successfully"
fi

echo -e "\n\n*** Installing Qt tools ***"
aqt install-tool ${install_os} desktop tools_cmake --outputdir ${OUTPUTDIR}/Qt
rm -f aqtinstall.log

sudo chown -R ${USER}:${USER} ${OUTPUTDIR}

echo -e "\n\n*** Applying Qt fixes ***"
# Apply Qt 6.8.3 specific fixes
echo "-- Applying Qt 6.8.3 specific fixes"

# Fix file permissions
chmod -v 755 ${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/bin/{qmake,qmake6,qt-cmake,qt-configure-module,qtpaths,qtpaths6}
chmod -v 755 ${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/libexec/{qt-cmake-private,qt-cmake-standalone-test}

# Fix hardcoded paths in Qt 6.8.3 WebAssembly - these are still needed
DEPS_FILE="${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6/Qt6Dependencies.cmake"
INTERNALS_FILE="${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake"

if [ -f "${DEPS_FILE}" ]; then
    echo "-- Patching Qt6Dependencies.cmake for correct host paths"
    dos2unix "${DEPS_FILE}"
    sed -i "s|/Users/qt/work/install|${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}|g" "${DEPS_FILE}"
    echo "-- Qt6Dependencies.cmake patched"
fi

if [ -f "${INTERNALS_FILE}" ]; then
    echo "-- Patching QtBuildInternalsExtra.cmake for correct install paths"
    dos2unix "${INTERNALS_FILE}"
    sed -i "s|C:/Qt/Qt-[^\"]*|${OUTPUTDIR}/Qt|g" "${INTERNALS_FILE}"
    sed -i "s|/Users/qt/work/install/target|${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}|g" "${INTERNALS_FILE}"
    echo "-- QtBuildInternalsExtra.cmake patched"
fi

echo "✓  Qt 6.8.3 fixes completed"

# Install emscripten
echo -e "\n\n*** Installing Emscripten ${EMSCRIPTEN} ***"
cd ${OUTPUTDIR}
if [ -d "emsdk" ]; then
    rm -rf "emsdk"
fi
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install ${EMSCRIPTEN}

# Install can easily fail for arm64, since a binary is not available for all versions
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install Emscripten ${EMSCRIPTEN}, try to build it manually"

    echo "ERROR: Failed to install sdk-main-64bit"
    echo "This is required for the build to succeed"
    exit 1
else
    echo "✓ Emscripten installed successfully"
    echo
fi

./emsdk activate ${EMSCRIPTEN}
# Check if activation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to activate Emscripten ${EMSCRIPTEN}"
    echo "This is required for the build to succeed"
    exit 1
else
    echo "✓ Emscripten activated successfully"
fi

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
if [ $? -ne 0 ]; then
    echo "ERROR: QtMQTT version ${QT_VERSION} not available"
    echo "Available QtMQTT branches/tags:"
    git branch -r | head -10
    git tag | grep "^${QT_VERSION%.*}" | head -5
    exit 1
fi

if [ -d "build-qtmqtt" ]; then
    rm -rf "build-qtmqtt"
fi
mkdir build-qtmqtt
cd build-qtmqtt

# Set up environment for cross-compilation
export PATH=${OUTPUTDIR}/Qt/Tools/CMake/bin:${PATH}
export QTDIR=${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread
export QT_HOST_PATH=${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}

# Verify paths exist
if [ ! -d "${QTDIR}" ]; then
    echo "ERROR: WebAssembly Qt directory not found: ${QTDIR}"
    echo "Available directories:"
    ls -la ${OUTPUTDIR}/Qt/${QT_VERSION}/
    exit 1
fi

if [ ! -d "${QT_HOST_PATH}" ]; then
    echo "ERROR: Desktop Qt directory not found: ${QT_HOST_PATH}"
    echo "Available directories:"
    ls -la ${OUTPUTDIR}/Qt/${QT_VERSION}/
    exit 1
fi

echo "Using QTDIR: ${QTDIR}"
echo "Using QT_HOST_PATH: ${QT_HOST_PATH}"

# Source emscripten environment
source "${OUTPUTDIR}/emsdk/emsdk_env.sh"

# Configure QtMQTT with qt-cmake (Qt 6.8.3 method)
${QTDIR}/bin/qt-cmake .. -DQT_HOST_PATH="${QT_HOST_PATH}"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to configure QtMQTT with qt-cmake"
    exit 1
fi

VERBOSE=1 cmake --build .
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build QtMQTT"
    exit 1
fi

cmake --install . --prefix ${QTDIR} --verbose
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install QtMQTT"
    exit 1
else
    echo "✓ QtMQTT installed successfully"
fi

# Change ownership of the output directory
sudo chown -R ${USER}:${USER} ${OUTPUTDIR}

echo -e "\n\n*** Installation completed successfully ***"
echo "Qt ${QT_VERSION} installed to: ${OUTPUTDIR}/Qt/${QT_VERSION}"
echo "Desktop version: ${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}"
echo "WebAssembly version: ${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread"
echo "Emscripten ${EMSCRIPTEN}: ${OUTPUTDIR}/emsdk"

# Verify installation
echo -e "\n*** Installation verification ***"

echo "Note: WebSockets warnings during QtMQTT build are expected for Qt 6.8.3 WebAssembly"
echo "Note: 'Unix Makefiles' vs 'Ninja' warnings are non-critical"
echo

if [ -f "${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}/bin/qmake" ]; then
    echo "✓ Desktop Qt qmake found"
    ${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}/bin/qmake -version
else
    echo "✗ Desktop Qt qmake NOT found"
fi

if [ -f "${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/bin/qmake" ]; then
    echo "✓ WebAssembly Qt qmake found"
    ${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/bin/qmake -version
else
    echo "✗ WebAssembly Qt qmake NOT found"
fi

source "${OUTPUTDIR}/emsdk/emsdk_env.sh"
if command -v emcc &> /dev/null; then
    echo "✓ Emscripten found"
    emcc --version | head -1
else
    echo "✗ Emscripten NOT found"
fi

# Check QtMQTT installation
if [ -f "${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/libQt6Mqtt.a" ] || [ -f "${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6Mqtt/Qt6MqttConfig.cmake" ]; then
    echo "✓ QtMQTT for WebAssembly found"
else
    echo "? QtMQTT for WebAssembly status unclear"
fi

# Check QtWebSockets installation
if [ -f "${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6WebSockets/Qt6WebSocketsConfig.cmake" ]; then
    echo "✓ QtWebSockets for WebAssembly found"
else
    echo "✗ QtWebSockets for WebAssembly NOT found"
    echo "Available Qt6 modules in WebAssembly installation:"
    ls -la ${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread/lib/cmake/ | grep Qt6
    exit 1
fi

# Build and install QtShaderTools for desktop (host tools needed for WebAssembly cross-compilation)
echo -e "\n\n*** Building and installing QtShaderTools for desktop ***"
cd ${OUTPUTDIR}
if [ -d "qtshadertools" ]; then
    rm -rf "qtshadertools"
fi
git clone https://github.com/qt/qtshadertools.git
cd qtshadertools
git checkout ${QT_VERSION}
if [ $? -ne 0 ]; then
    echo "ERROR: QtShaderTools version ${QT_VERSION} not available"
    echo "Available QtShaderTools branches/tags:"
    git branch -r | head -10
    git tag | grep "^${QT_VERSION%.*}" | head -5
    exit 1
fi

if [ -d "build-qtshadertools-desktop" ]; then
    rm -rf "build-qtshadertools-desktop"
fi
mkdir build-qtshadertools-desktop
cd build-qtshadertools-desktop

# Set up environment for desktop build
export PATH=${OUTPUTDIR}/Qt/Tools/CMake/bin:${PATH}
export QTDIR=${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}

echo "Using desktop QTDIR: ${QTDIR}"

# Configure QtShaderTools for desktop
${QTDIR}/bin/qt-cmake ..

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to configure QtShaderTools for desktop with qt-cmake"
    exit 1
fi

cmake --build .
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build QtShaderTools for desktop"
    exit 1
fi

cmake --install . --prefix ${QTDIR} --verbose
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install QtShaderTools for desktop"
    exit 1
fi

echo "✓ QtShaderTools for desktop installed successfully"

# Create Qt6ShaderToolsTools package manually
echo -e "\n\n*** Creating Qt6ShaderToolsTools package ***"
DESKTOP_CMAKE_DIR="${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}/lib/cmake"
QSB_TOOL_DIR="${OUTPUTDIR}/Qt/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}/bin"

# Create the Qt6ShaderToolsTools directory
mkdir -p "${DESKTOP_CMAKE_DIR}/Qt6ShaderToolsTools"

# Create Qt6ShaderToolsToolsConfig.cmake
cat > "${DESKTOP_CMAKE_DIR}/Qt6ShaderToolsTools/Qt6ShaderToolsToolsConfig.cmake" << 'EOF'
# Qt6ShaderToolsTools Config

get_filename_component(_qt_cmake_dir "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(QT_CMAKE_DIR "${_qt_cmake_dir}")

# Import the qsb tool
if(NOT TARGET Qt6::qsb)
    add_executable(Qt6::qsb IMPORTED)
    get_filename_component(_qt_bin_dir "${CMAKE_CURRENT_LIST_DIR}/../../../bin" ABSOLUTE)
    set_target_properties(Qt6::qsb PROPERTIES
        IMPORTED_LOCATION "${_qt_bin_dir}/qsb"
    )
endif()

# Mark as found
set(Qt6ShaderToolsTools_FOUND TRUE)
EOF

# Create Qt6ShaderToolsToolsConfigVersion.cmake
cat > "${DESKTOP_CMAKE_DIR}/Qt6ShaderToolsTools/Qt6ShaderToolsToolsConfigVersion.cmake" << 'EOF'
set(PACKAGE_VERSION "6.8.3")
set(PACKAGE_VERSION_EXACT False)
set(PACKAGE_VERSION_COMPATIBLE True)

if("${PACKAGE_VERSION}" VERSION_LESS "${PACKAGE_FIND_VERSION}")
    set(PACKAGE_VERSION_COMPATIBLE False)
endif()

if("${PACKAGE_FIND_VERSION}" STREQUAL "${PACKAGE_VERSION}")
    set(PACKAGE_VERSION_EXACT True)
endif()
EOF

# Create Qt6ShaderToolsToolsTargets.cmake
cat > "${DESKTOP_CMAKE_DIR}/Qt6ShaderToolsTools/Qt6ShaderToolsToolsTargets.cmake" << 'EOF'
# Qt6ShaderToolsTools Targets

if(NOT TARGET Qt6::qsb)
    add_executable(Qt6::qsb IMPORTED)
    get_filename_component(_qt_bin_dir "${CMAKE_CURRENT_LIST_DIR}/../../../bin" ABSOLUTE)
    set_target_properties(Qt6::qsb PROPERTIES
        IMPORTED_LOCATION "${_qt_bin_dir}/qsb"
    )
endif()
EOF

echo "✓ Qt6ShaderToolsTools package created successfully"
