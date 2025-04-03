#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.24)
project(tst_visibleitemmodel LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_visibleitemmodel
    tst_visibleitemmodel.cpp
    ../../src/visibleitemmodel.h
    ../../src/visibleitemmodel.cpp
)

include_directories(../../src)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        tst_visibleitemmodel.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

set_target_properties(tst_visibleitemmodel PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES tst_visibleitemmodel.qml DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/visibleitemmodel)
    install(TARGETS tst_visibleitemmodel DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../../install/tests/visibleitemmodel)
endif()

target_link_libraries(tst_visibleitemmodel PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickPrivate
    Qt6::QuickTest
    Qt6::Quick
)

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})
