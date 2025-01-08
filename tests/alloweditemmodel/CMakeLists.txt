#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_alloweditemmodel LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_alloweditemmodel
    tst_alloweditemmodel.cpp
    ../../src/alloweditemmodel.h
    ../../src/alloweditemmodel.cpp
)

include_directories(../../src)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        tst_alloweditemmodel.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(tst_alloweditemmodel PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_alloweditemmodel.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/alloweditemmodel)
    install(TARGETS tst_alloweditemmodel DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/alloweditemmodel)
endif()

target_link_libraries(tst_alloweditemmodel PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickPrivate
    Qt6::QuickTest
    Qt6::Quick
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
