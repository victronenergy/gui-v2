cmake_minimum_required(VERSION 3.5)

cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX)
set(TRANSLATIONS_TS_TARGET venus-gui-v2-translations-ts)
set(TRANSLATIONS_QM_TARGET venus-gui-v2-translations-qm)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")

option(VENUS_DESKTOP_BUILD "enable desktop build via cmake -DVENUS_DESKTOP_BUILD=ON" OFF) # Disabled by default
option(VENUS_WEBASSEMBLY_BUILD "enable webassembly build via cmake -DVENUS_WEBASSEMBLY_BUILD=ON" OFF) # Disabled by default
option(MQTT_WEBSOCKETS_ENABLED "enable websockets build via cmake -DMQTT_WEBSOCKETS_ENABLED=ON" OFF) # Disabled by default

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    add_compile_definitions(VENUS_WEBASSEMBLY_BUILD)
    add_compile_definitions(MQTT_WEBSOCKETS_ENABLED)
    find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml LinguistTools Mqtt WebSockets REQUIRED)
else()
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml DBus LinguistTools Mqtt)
    if (NOT ${Qt6_FOUND})
        # cmake can't automatically find Qt 6.2 on Ubuntu Linux, give it a hint:
        if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
            list(APPEND CMAKE_PREFIX_PATH "/opt/Qt/6.2.0/gcc_64/lib/cmake/")
        endif()
        find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml DBus LinguistTools REQUIRED)
    endif()
endif()

qt_add_resources(QML_RESOURCES
    qml.qrc)


include_directories(src/velib/inc src .)

set(CONNMAN_SOURCES
    src/connman/cmmanager.h 
    src/connman/cmmananger_interface.h 
    src/connman/cmtechnology.h 
    src/connman/cmtechnology_interface.h 
    src/connman/cmservice_interface.h 
    src/connman/cmservice.h 
    src/connman/cmagent.h 
    src/connman/cmagent_adaptor.h 
    src/connman/clockmodel.h 
    src/connman/clockproxy.h
    src/connman/connmandbustypes.cpp 
    src/connman/cmmanager.cpp 
    src/connman/cmmananger_interface.cpp 
    src/connman/cmtechnology.cpp 
    src/connman/cmtechnology_interface.cpp 
    src/connman/cmservice_interface.cpp 
    src/connman/cmservice.cpp 
    src/connman/cmagent.cpp 
    src/connman/cmagent_adaptor.cpp 
    src/connman/clockmodel.cpp 
    src/connman/clockproxy.cpp
    src/connman/connmandbustypes.h 
)

set(VELIB_CORE_SOURCES
    src/velib/inc/velib/qt/unit_conversion.hpp
    src/velib/inc/velib/qt/ve_qitem.hpp
    src/velib/inc/velib/qt/ve_quick_item.hpp
    src/velib/inc/velib/qt/ve_qitem_child_model.hpp
    src/velib/inc/velib/qt/ve_qitem_loader.hpp
    src/velib/inc/velib/qt/ve_qitem_sort_table_model.hpp
    src/velib/inc/velib/qt/ve_qitem_table_model.hpp
    src/velib/inc/velib/qt/ve_qitem_tree_model.hpp
    src/velib/inc/velib/velib_config.h

    src/velib/src/qt/unit_conversion.cpp
    src/velib/src/qt/ve_qitem.cpp
    src/velib/src/qt/ve_quick_item.cpp
    src/velib/src/qt/ve_qitem_child_model.cpp
    src/velib/src/qt/ve_qitem_loader.cpp
    src/velib/src/qt/ve_qitem_sort_table_model.cpp
    src/velib/src/qt/ve_qitem_table_model.cpp
    src/velib/src/qt/ve_qitem_tree_model.cpp
)

set(VELIB_DBUS_SOURCES
    src/velib/inc/velib/qt/bms_error.hpp
    src/velib/inc/velib/qt/charger_error.hpp
    src/velib/inc/velib/qt/ve_qitem_dbus_publisher.hpp
    src/velib/inc/velib/qt/ve_qitems_dbus.hpp
    src/velib/inc/velib/qt/v_busitems.h
    src/velib/inc/velib/qt/vebus_error.hpp
    src/velib/src/qt/bms_error.cpp
    src/velib/src/qt/charger_error.cpp
    src/velib/src/qt/v_busitem_proxy.cpp
    src/velib/src/qt/v_busitem_proxy.cpp
    src/velib/src/qt/ve_qitem_dbus_virtual_object.hpp
    src/velib/src/qt/ve_qitem_dbus_virtual_object.cpp
    src/velib/src/qt/ve_qitems_dbus.cpp
    src/velib/src/qt/ve_qitem_dbus_publisher.cpp

    src/velib/src/qt/v_busitems.cpp
    src/velib/src/qt/vebus_error.cpp
    src/gui-v1/alarmbusitem.h
    src/gui-v1/alarmbusitem.cpp
    src/gui-v1/alarmmonitor.h
    src/gui-v1/alarmmonitor.cpp
    src/gui-v1/dbus_service.h
    src/gui-v1/dbus_service.cpp
    src/gui-v1/dbus_services.h
    src/gui-v1/dbus_services.cpp
    src/gui-v1/wakespeed_error.cpp
)

set(VELIB_MQTT_SOURCES
    src/velib/inc/velib/qt/ve_qitems_mqtt.hpp
    src/velib/src/qt/ve_qitems_mqtt.cpp
)

set(VENUS_SOURCES
    src/main.cpp
    src/backendconnection.h
    src/backendconnection.cpp
    src/clocktime.h
    src/clocktime.cpp
    src/theme.h
    src/theme.cpp
    src/language.h
    src/language.cpp
    src/logging.h
    src/enums.h
    src/enums.cpp
    src/notificationsmodel.h
    src/notificationsmodel.cpp
    src/uidhelper.h
    src/uidhelper.cpp
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    list(APPEND SOURCES
        ${VELIB_CORE_SOURCES}
        ${VELIB_MQTT_SOURCES}
        ${VENUS_SOURCES}
        ${QML_RESOURCES}
    )
else()
    list(APPEND SOURCES
        ${CONNMAN_SOURCES}
        ${VELIB_CORE_SOURCES}
        ${VELIB_DBUS_SOURCES}
        ${VELIB_MQTT_SOURCES}
        ${VENUS_SOURCES}
        ${QML_RESOURCES}
    )
endif()

# translations support.
# note: the base venus-gui-v2.ts was generated with:
# lupdate.exe qml.qrc -ts i18n/venus-gui-v2.ts)
set(TRANSLATIONS_TS_FILES
        "i18n/venus-gui-v2.ts"
	"i18n/venus-gui-v2_en.ts"
	"i18n/venus-gui-v2_fr.ts")
set(TRANSLATIONS_QM_FILES
        "i18n/venus-gui-v2.qm"
	"i18n/venus-gui-v2_en.qm"
	"i18n/venus-gui-v2_fr.qm")
# manually generate .ts files via a custom command.
# it would be good if we could do this via qt6_add_lupdate
# instead, but that macro is broken, so do it ourselves.
add_custom_target(${TRANSLATIONS_TS_TARGET}
    SOURCES ${QML_RESOURCES} ${SOURCES})
add_custom_command(
    TARGET ${TRANSLATIONS_TS_TARGET}
    BYPRODUCTS ${TRANSLATIONS_TS_FILES}
    COMMENT "Manually updating translations files"
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lupdate
        ARGS "${CMAKE_CURRENT_SOURCE_DIR}/qml.qrc" src
	     -ts ${TRANSLATIONS_TS_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
# add a custom target to generate the .qm files via qt6_add_lrelease().
# force the .qm generation step to depend on the .ts generation step.
set_source_files_properties(${TRANSLATIONS_TS_FILES}
    PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/i18n")
add_custom_target(${TRANSLATIONS_QM_TARGET}
    SOURCES ${TRANSLATIONS_TS_FILES})
add_dependencies(${TRANSLATIONS_QM_TARGET} ${TRANSLATIONS_TS_TARGET})
# generate .qm files
add_custom_command(
    TARGET ${TRANSLATIONS_QM_TARGET}
    COMMENT "Manually releasing translations files"
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lrelease
        ARGS ${TRANSLATIONS_TS_FILES} -idbased
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    list(APPEND venusCompileFlags "-Wall" "-Wextra" "-Werror" "-Wconversion" "-Wno-exceptions" "-Wextra-semi" "-Wno-inaccessible-base" "-Wcast-align" "-Wcast-qual" "-Wctor-dtor-privacy" "-Wformat=2" "-Winit-self" "-Wmissing-declarations" "-Wmissing-include-dirs" "-Wold-style-cast" "-Woverloaded-virtual" "-Wredundant-decls" "-Wshadow" "-Wsign-conversion" "-Wstrict-overflow=5" "-Wswitch-default" "-Wundef")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(VENUS_DESKTOP_BUILD)
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
else()
    list(APPEND venusCompileFlags "-Wall" "-Wextra" "-Werror" "-Wconversion" "-Wno-exceptions" "-Wextra-semi" "-Wno-inaccessible-base" "-Wcast-align" "-Wcast-qual" "-Wctor-dtor-privacy" "-Wformat=2" "-Winit-self" "-Wmissing-declarations" "-Wmissing-include-dirs" "-Wold-style-cast" "-Woverloaded-virtual" "-Wredundant-decls" "-Wshadow" "-Wsign-conversion" "-Wstrict-overflow=5" "-Wswitch-default" "-Wundef")
    qt_add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

add_dependencies(${PROJECT_NAME} ${TRANSLATIONS_QM_TARGET})
qt_add_resources(${PROJECT_NAME} "i18n"
    PREFIX "/i18n"
    BASE "i18n"
    FILES ${TRANSLATIONS_QM_FILES})

set_source_files_properties(
    ${VENUS_SOURCES}
    PROPERTIES
    COMPILE_OPTIONS "${venusCompileFlags}"
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Svg
        Qt6::Xml
        Qt6::Mqtt
        Qt6::WebSockets
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Quick
        Qt6::Svg
        Qt6::Xml
        Qt6::DBus
        Qt6::Mqtt
    )
endif()

qt_add_qml_module(${PROJECT_NAME}
    URI Victron.VenusOS
    VERSION 2.0
)

# see if the dependency graph is correct, for translations support...
add_custom_target(graphviz
                 "${CMAKE_COMMAND}" "--graphviz=venus" .
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
# disable it for now, can re-enable for future analysis when required.
#add_dependencies(${PROJECT_NAME} graphviz)
