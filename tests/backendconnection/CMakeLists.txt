#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_backendconnection LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick DBus Mqtt)

qt_add_executable(${PROJECT_NAME}
    tst_backendconnection.cpp

    ../../src/backendconnection.h
    ../../src/backendconnection.cpp

    ../../src/veutil/inc/veutil/qt/ve_qitems_mqtt.hpp
    ../../src/veutil/src/qt/ve_qitems_mqtt.cpp
    ../../src/veutil/inc/veutil/qt/ve_qitem.hpp
    ../../src/veutil/src/qt/ve_qitem.cpp
    ../../src/veutil/inc/veutil/qt/ve_dbus_connection.hpp
    ../../src/veutil/inc/veutil/qt/ve_qitems_dbus.hpp
    ../../src/veutil/inc/veutil/qt/vebus_error.hpp
    ../../src/veutil/src/qt/ve_dbus_connection.cpp
    ../../src/veutil/src/qt/ve_qitems_dbus.cpp
    ../../src/veutil/src/qt/vebus_error.cpp

    ../../src/veqitemmockproducer.h
    ../../src/veqitemmockproducer.cpp
)

include_directories(../../src ../../src/veutil/inc/veutil/qt ../../src/veutil/inc)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES tst_backendconnection.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_backendconnection.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/backendconnection)
    install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/backendconnection)
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::QuickTest
    Qt6::Quick
    Qt6::DBus
    Qt6::Mqtt
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
