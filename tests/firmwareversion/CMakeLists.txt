#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_firmwareversion LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_firmwareversion
    tst_firmwareversion.cpp
    ../../src/enums.h
    ../../src/enums.cpp
)

include_directories(../../src)

set_source_files_properties(../../components/FirmwareVersion.qml PROPERTIES
    QT_RESOURCE_ALIAS FirmwareVersion.qml
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES 
        tst_firmwareversion.qml
        ../../components/FirmwareVersion.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(tst_firmwareversion PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_firmwareversion.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/firmwareversion)
    install(TARGETS tst_firmwareversion DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/firmwareversion)
endif()

target_link_libraries(tst_firmwareversion PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickTest
    Qt6::Quick
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
