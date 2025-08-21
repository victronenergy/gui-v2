#!/bin/bash

# Qt fixes for Qt 6.8.3 WebAssembly - Minimal version
# No backward compatibility - Qt 6.8.3 only

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." &> /dev/null && pwd )"

# Load environment variables from .env file
if [ -f "${BASE_DIR}/scripts/.env" ]; then
    export $(grep -v '^#' "${BASE_DIR}/scripts/.env" | xargs)
else
    echo "## ${BASE_DIR}/scripts/.env file not found!"
    exit 1
fi

arch=$(dpkg --print-architecture)
if [ "${arch}" == "arm64" ]; then
    ACTUAL_DESKTOP_DIR="gcc_arm64"
else
    ACTUAL_DESKTOP_DIR="gcc_64"
fi

DIR=${OUTPUTDIR}/Qt

echo "### Applying Qt 6.8.3 fixes for ${QT_VERSION} in ${DIR}"

# Fix file permissions - always needed for WebAssembly Qt
echo "### Fixing file permissions"
chmod -v 755 ${DIR}/${QT_VERSION}/wasm_singlethread/bin/{qmake,qmake6,qt-cmake,qt-configure-module,qtpaths,qtpaths6}
chmod -v 755 ${DIR}/${QT_VERSION}/wasm_singlethread/libexec/{qt-cmake-private,qt-cmake-standalone-test}

# Fix hardcoded paths in Qt6Dependencies.cmake
DEPS_FILE="${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6/Qt6Dependencies.cmake"
if [ -f "${DEPS_FILE}" ]; then
    echo "### Patching Qt6Dependencies.cmake"
    dos2unix "${DEPS_FILE}"
    sed -i "s|/Users/qt/work/install|${DIR}/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}|g" "${DEPS_FILE}"
    echo "### Qt6Dependencies.cmake updated"
else
    echo "### Qt6Dependencies.cmake not found - skipping"
fi

# Fix hardcoded paths in QtBuildInternalsExtra.cmake
INTERNALS_FILE="${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake"
if [ -f "${INTERNALS_FILE}" ]; then
    echo "### Patching QtBuildInternalsExtra.cmake"
    dos2unix "${INTERNALS_FILE}"
    sed -i "s|C:/Qt/Qt-[^\"]*|${DIR}|g" "${INTERNALS_FILE}"
    sed -i "s|/Users/qt/work/install/target|${DIR}/${QT_VERSION}/${ACTUAL_DESKTOP_DIR}|g" "${INTERNALS_FILE}"
    echo "### QtBuildInternalsExtra.cmake updated"
else
    echo "### QtBuildInternalsExtra.cmake not found - skipping"
fi

echo "### Qt 6.8.3 fixes completed successfully"
