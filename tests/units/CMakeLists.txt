#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.16)
project(tst_units LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml QuickTest Quick)

qt_add_executable(tst_units
    tst_units.cpp
    ../../src/enums.h
    ../../src/enums.cpp
    ../../src/quantityinfo.h
    ../../src/quantityinfo.cpp
    ../../src/units.h
    ../../src/units.cpp
    ../../src/veutil/inc/veutil/qt/unit_conversion.hpp
    ../../src/veutil/src/qt/unit_conversion.cpp
)

include_directories(../../src ../../src/veutil/inc/veutil/qt ../../src/veutil/inc)

qt_add_qml_module( ${PROJECT_NAME}
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES tst_units.qml
    OUTPUT_DIRECTORY Victron/VenusOS
)

    set_target_properties(tst_units PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(tst_units PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::QuickTest
    Qt6::Quick
)

