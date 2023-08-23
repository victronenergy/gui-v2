#!/bin/bash

chmod -v 755 /opt/hostedtoolcache/Qt/6.5.2/wasm_singlethread/bin/{qmake,qmake6,qt-cmake,qt-configure-module,qtpaths,qtpaths6}
chmod -v 755 /opt/hostedtoolcache/Qt/6.5.2/wasm_singlethread/libexec/{qt-cmake-private,qt-cmake-standalone-test}

patch /opt/hostedtoolcache/Qt/6.5.2/wasm_singlethread/lib/cmake/Qt6/Qt6Dependencies.cmake < .github/patches/Qt6Dependencies.cmake.patch
patch /opt/hostedtoolcache/Qt/6.5.2/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake < .github/patches/QtBuildInternalsExtra.cmake.patch

