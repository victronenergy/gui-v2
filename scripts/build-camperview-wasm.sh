#!/bin/bash

# This script builds the standalone RV illustration (tools/camperview) as WebAssembly.
# To install the requirements, execute build-wasm-install-requirements.sh once.

set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
BUILD_DIR="${BASE_DIR}/build-camperview-wasm"
FILES_DIR="${BASE_DIR}/build-camperview-wasm_files_to_copy"

export $(grep -v '^#' "${BASE_DIR}/scripts/.env" | xargs)
export PATH=${OUTPUTDIR}/Qt/Tools/CMake/bin:${PATH}
export QTDIR=${OUTPUTDIR}/Qt/${QT_VERSION}/wasm_singlethread

source "${OUTPUTDIR}/emsdk/emsdk_env.sh"

rm -rf "${BUILD_DIR}" "${FILES_DIR}"
${QTDIR}/bin/qt-cmake -S "${BASE_DIR}/tools/camperview" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=MinSizeRel
cmake --build "${BUILD_DIR}" --parallel "$(nproc)"

mkdir -p "${FILES_DIR}"
cp "${BUILD_DIR}"/camperview.{js,wasm} "${BUILD_DIR}/qtloader.js" "${FILES_DIR}/"
cp "${BUILD_DIR}/camperview.html" "${FILES_DIR}/index.html"

cd "${FILES_DIR}"
"${EMSDK}/upstream/bin/wasm-opt" -Oz --all-features -o camperview-opt.wasm camperview.wasm
mv camperview-opt.wasm camperview.wasm
gzip -9 -k camperview.wasm
brotli -q 11 -k camperview.wasm

ls -l camperview.wasm*
