#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_screenblanker LANGUAGES CXX)

if(VENUS_DESKTOP_BUILD)
    add_compile_definitions(VENUS_DESKTOP_BUILD)
endif()

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_screenblanker
    tst_screenblanker.cpp
    ../../src/screenblanker.h
    ../../src/screenblanker.cpp
)

include_directories(../../src)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES tst_screenblanker.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(tst_screenblanker PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_screenblanker.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/screenblanker)
    install(TARGETS tst_screenblanker DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/screenblanker)
endif()

target_link_libraries(tst_screenblanker PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickTest
    Qt6::Quick
)

