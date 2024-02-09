#!/bin/bash

BUILD_FILE=".github/workflows/build-wasm.yml"
if [ ! -f ${BUILD_FILE} ]; then
  echo "## Unable to locate ${BUILD_FILE} (pwd: ${PWD})"
  exit 1
fi

# Read the QT version info from the build file
QT_VERSION=$(yq '.jobs.build-wasm-file.env.QT_VERSION' ${BUILD_FILE})

# The directory is taken from the fifth step:
DIR=$(yq ".jobs.build-wasm-file.steps[4].with.dir" ${BUILD_FILE})/Qt

echo "### Using QT_VERSION: ${QT_VERSION}, dir: ${DIR}"

chmod -v 755 ${DIR}/${QT_VERSION}/wasm_singlethread/bin/{qmake,qmake6,qt-cmake,qt-configure-module,qtpaths,qtpaths6}
chmod -v 755 ${DIR}/${QT_VERSION}/wasm_singlethread/libexec/{qt-cmake-private,qt-cmake-standalone-test}

dos2unix ${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6/Qt6Dependencies.cmake
patch ${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6/Qt6Dependencies.cmake <<< "
--- Qt6Dependencies.cmake.orig  2023-08-28 07:28:07.630920804 +0000
+++ Qt6Dependencies.cmake       2023-08-28 07:29:08.806970500 +0000
@@ -1,8 +1,8 @@
 set(Qt6_FOUND FALSE)
 
 set(__qt_platform_requires_host_info_package \"TRUE\")
-set(__qt_platform_initial_qt_host_path \"/Users/qt/work/install\")
-set(__qt_platform_initial_qt_host_path_cmake_dir \"/Users/qt/work/install/lib/cmake\")
+set(__qt_platform_initial_qt_host_path \"${DIR}/${QT_VERSION}/gcc_64\")
+set(__qt_platform_initial_qt_host_path_cmake_dir \"${DIR}/${QT_VERSION}/gcc_64/lib/cmake\")
 
 _qt_internal_setup_qt_host_path(
     \"\${__qt_platform_requires_host_info_package}\"
"

dos2unix ${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake
patch ${DIR}/${QT_VERSION}/wasm_singlethread/lib/cmake/Qt6BuildInternals/QtBuildInternalsExtra.cmake <<<"
--- QtBuildInternalsExtra.cmake.orig	2023-08-28 07:31:02.027063145 +0000
+++ QtBuildInternalsExtra.cmake	2023-08-28 07:31:57.043108429 +0000
@@ -42,8 +42,8 @@
 if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND
         NOT QT_BUILD_INTERNALS_NO_FORCE_SET_INSTALL_PREFIX
         AND NOT QT_SUPERBUILD)
-    set(qtbi_orig_prefix \"C:/Qt/Qt-${QT_VERSION}\")
-    set(qtbi_orig_staging_prefix \"/Users/qt/work/install/target\")
+    set(qtbi_orig_prefix \"${DIR}\")
+    set(qtbi_orig_staging_prefix \"${DIR}/${QT_VERSION}/wasm_singlethread\")
     qt_internal_new_prefix(qtbi_new_prefix
         \"\${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}\"
         \"\${qtbi_orig_prefix}\")
"


dos2unix ${DIR}/${QT_VERSION}/wasm_singlethread/bin/qt-configure-module
patch ${DIR}/${QT_VERSION}/wasm_singlethread/bin/qt-configure-module <<<"
--- qt-configure-module.orig    2024-01-03 12:34:38.268021696 +0100
+++ qt-configure-module 2024-01-03 12:54:50.541363644 +0100
@@ -33,6 +33,6 @@
 echo \"\$arg\" >> \"\$optfile\"
 done

-cmake_script_path=\"\$script_dir_path/..\lib\cmake\Qt6/QtProcessConfigureArgs.cmake\"
+cmake_script_path=\"\$script_dir_path/../lib/cmake/Qt6/QtProcessConfigureArgs.cmake\"
 qt_cmake_private_path=\"\$script_dir_path/../libexec\"
 \"\$qt_cmake_private_path/qt-cmake-private\" -DOPTFILE=\$optfile -DMODULE_ROOT=\"\$module_root\" -DCMAKE_COMMAND=\"\$qt_cmake_private_path/qt-cmake-private\" -P \"\$cmake_script_path\"
"
