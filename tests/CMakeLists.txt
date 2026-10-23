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
add_subdirectory(branding)
add_subdirectory(classandvrminstancemodel)
add_subdirectory(device)
add_subdirectory(filtereddevicemodel)
add_subdirectory(filteredservicemodel)
add_subdirectory(firmwareversion)
add_subdirectory(frameratemodel)
add_subdirectory(genericinput)
add_subdirectory(iochannelgroupmodel)
add_subdirectory(iochannelproxymodel)
add_subdirectory(networkservices)
add_subdirectory(notificationtoast)
add_subdirectory(pagepreloader)
add_subdirectory(pagestack)
add_subdirectory(quantityobjectmodel)
add_subdirectory(runtimedevicemodel)
add_subdirectory(screenblanker)
add_subdirectory(shellydevicemodel)
add_subdirectory(solarinputmodel)
add_subdirectory(solaryieldmodel)
add_subdirectory(sortedruntimedevicemodel)
add_subdirectory(splashsequence)
add_subdirectory(switchableoutput)
add_subdirectory(uitestutils)
add_subdirectory(units)
add_subdirectory(visibleitemmodel)
add_subdirectory(wifimodel)

# Tests for the Python tools: the plugin compiler's Branding checks, and the generated Branding
# property list (which is also the Victron.Branding API record).
find_package(Python3 COMPONENTS Interpreter)
if (Python3_Interpreter_FOUND)
    # -B: do not write __pycache__ directories into the source tree.
    add_test(NAME tst_plugincompiler
        COMMAND ${Python3_EXECUTABLE} -B -m unittest discover -s ${CMAKE_CURRENT_SOURCE_DIR}/plugincompiler -p "test_*.py")
    add_test(NAME tst_brandingproperties
        COMMAND ${Python3_EXECUTABLE} -B -m unittest discover -s ${CMAKE_CURRENT_SOURCE_DIR}/brandingproperties -p "test_*.py")
    # Lets tst_plugincompiler run qmllint on the example branding plugins, against the
    # Victron.Branding module in the build directory.
    if (TARGET Qt6::qmllint)
        set_tests_properties(tst_plugincompiler PROPERTIES ENVIRONMENT
            "GUI_V2_QMLLINT=$<TARGET_FILE:Qt6::qmllint>;GUI_V2_QML_IMPORT_PATH=${CMAKE_BINARY_DIR}")
    endif()
endif()
