#
# Copyright (C) 2023 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# CMAKE HINTS
# see: https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2
#
# Different build types:
#   cmake -DCMAKE_BUILD_TYPE=[Debug|Release|RelWithDebInfo|MinSizeRelease] /path/to/CMakeLists.txt
#
# Translations
#   You can download the latest translations from poeditor if you have a token.
#       cmake /path/to/CMakeLists.txt
#       POEDITOR_TOKEN='....' make download_translations  # this downloads all translations
#       POEDITOR_TOKEN='....' make venus-gui-v2_uk        # this downloads a single translation file
#
#   You can upload new terms to poeditor if you have a token.
#       cmake /path/to/CMakeLists.txt
#       POEDITOR_TOKEN='....' make upload_translations  # this uploads /path/to/build/i18n/venus-gui-v2.ts to poeditor

cmake_policy(SET CMP0048 NEW)
cmake_policy(SET CMP0071 NEW) # process GENERATED source files in AUTOMOC and AUTOUIC. Added to silence a cmake warning.
cmake_policy(SET CMP0079 NEW)

cmake_minimum_required(VERSION 3.24)
if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds are not allowed. Build artifacts such as CMakeCache.txt created in ${CMAKE_SOURCE_DIR} will cause problems for future builds. Run 'git clean -fd' in ${CMAKE_SOURCE_DIR} to continue.")
endif()

project(venus-gui-v2 LANGUAGES CXX VERSION 1.2.23)
add_definitions(-DPROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR} -DPROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR} -DPROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH} )

option(NO_CACHEGEN "Enable bytecode compilation and lint processing for all qml files via cmake -NO_CACHEGEN=OFF" ON) # Enabled by default
option(RUN_UNIT_TESTS "only affects desktop builds. Enable via cmake -DRUN_UNIT_TESTS=ON" OFF) # Disabled by default

include(cmake/BuildDefines.cmake)
include(cmake/BuildRequirements.cmake)
include(cmake/BuildQt6AddShaders.cmake)

message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")
message("Host system architecture: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
message("CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
message("CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

if (${NO_CACHEGEN})
    message("Disabling cache generation for faster builds")
    set (QML_MODULE_OPTARGS ${QML_MODULE_OPTARGS} "NO_CACHEGEN")
endif()

include(cmake/ModuleVenus_Sources.cmake)
include(cmake/ModuleShaders_Sources.cmake)
include(cmake/ModuleGauges_Sources.cmake)
include(cmake/ModuleBoat_Sources.cmake)
include(cmake/ModuleMock_Sources.cmake)
include(cmake/ModuleUiTest_Sources.cmake)
include(cmake/VeUtil_Sources.cmake)
include(cmake/GuiV2_Sources.cmake)

include(cmake/GenerateTheme.cmake)
include(cmake/Translations.cmake)

include(cmake/ModuleVenus.cmake)
include(cmake/ModuleShaders.cmake)
include(cmake/ModuleGauges.cmake)
include(cmake/ModuleBoat.cmake)
include(cmake/ModuleMock.cmake)
include(cmake/ModuleUiTest.cmake)

include(cmake/QZXing.cmake)
include(cmake/GuiV2.cmake)

target_link_libraries(${PROJECT_NAME} PRIVATE
    VictronVenusOSplugin
    VictronVenusOSShadersplugin
    VictronGaugesplugin
    VictronBoatplugin
    VictronMockplugin
    qzxing
)

include(cmake/RunTests.cmake)

add_dependencies(generate_translation_sources_file theme_parser)
add_dependencies(${PROJECT_NAME} theme_parser)
# Note: ${PROJECT_NAME} depends on ${BUILD_DIR_QM_FILES} via the qt_add_resources() in GuiV2.cmake

# to visualise the dependency graph, do the following:
# $ cmake --graphviz=dependencies.dot ../gui-v2/
# or uncomment the following and build normally.
#include(cmake/DependencyGraph.cmake)
#add_dependencies(${PROJECT_NAME} dependency_graph)
# then convert the dot file to a png:
# $ dot -Tpng dependencies.dot -o dependencies.png

