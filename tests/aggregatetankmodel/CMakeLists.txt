#
# Copyright (C) 2025 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_aggregatetankmodel LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_aggregatetankmodel
    tst_aggregatetankmodel.cpp
    ../../src/enums.h
    ../../src/enums.cpp
    ../../src/basetankdevice.h
    ../../src/basetankdevice.cpp
    ../../src/basetankdevicemodel.h
    ../../src/basetankdevicemodel.cpp
    ../../src/basedevice.h
    ../../src/basedevice.cpp
    ../../src/basedevicemodel.h
    ../../src/basedevicemodel.cpp
    ../../src/aggregatedevicemodel.h
    ../../src/aggregatedevicemodel.cpp
    ../../src/aggregatetankmodel.h
    ../../src/aggregatetankmodel.cpp
)

include_directories(../../src)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        tst_aggregatetankmodel.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(tst_aggregatetankmodel PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_aggregatetankmodel.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/aggregatetankmodel)
    install(TARGETS tst_aggregatetankmodel DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/aggregatetankmodel)
endif()

target_link_libraries(tst_aggregatetankmodel PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickPrivate
    Qt6::QuickTest
    Qt6::Quick
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
