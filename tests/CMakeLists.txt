#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
    set(VENUS_DESKTOP_BUILD ON)
endif()
if (${VENUS_DESKTOP_BUILD})
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    enable_testing()
endif()

include(../cmake/UnitTests.cmake)

add_subdirectory(aggregatedevicemodel)
add_subdirectory(aggregatetankmodel)
add_subdirectory(alldevicesmodel)
add_subdirectory(allservicesmodel)
add_subdirectory(backendconnection)
add_subdirectory(basetankdevice)
add_subdirectory(basetankdevicemodel)
add_subdirectory(classandvrminstancemodel)
add_subdirectory(device)
add_subdirectory(filtereddevicemodel)
add_subdirectory(filteredservicemodel)
add_subdirectory(firmwareversion)
add_subdirectory(genericinput)
add_subdirectory(iochannelgroupmodel)
add_subdirectory(quantityobjectmodel)
add_subdirectory(runtimedevicemodel)
add_subdirectory(screenblanker)
add_subdirectory(solarinputmodel)
add_subdirectory(solaryieldmodel)
add_subdirectory(switchableoutput)
add_subdirectory(units)
add_subdirectory(visibleitemmodel)
