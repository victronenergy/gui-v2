#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 3.24)
cmake_policy(SET CMP0048 NEW)
project(tests LANGUAGES CXX)

if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
    set(VENUS_DESKTOP_BUILD ON)
endif()
if (${VENUS_DESKTOP_BUILD})
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    enable_testing()
endif()

add_subdirectory(firmwareversion)
add_subdirectory(units)
add_subdirectory(screenblanker)
add_subdirectory(backendconnection)
add_subdirectory(visibleitemmodel)
add_subdirectory(quantityobjectmodel)
add_subdirectory(aggregatedevicemodel)
add_subdirectory(basetankdevice)
add_subdirectory(aggregatetankmodel)
add_subdirectory(basetankdevicemodel)
