cmake_minimum_required(VERSION 3.5)

cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml DBus LinguistTools)
if (NOT ${Qt6_FOUND})
    # cmake can't automatically find Qt 6.2 on Ubuntu Linux, give it a hint:
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        list(APPEND CMAKE_PREFIX_PATH "/opt/Qt/6.2.0/gcc_64/lib/cmake/")
    endif()

    find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml DBus LinguistTools REQUIRED)
endif()

option(VENUS_DESKTOP_BUILD "enable desktop build via cmake -DVENUS_DESKTOP_BUILD=ON" OFF) # Disabled by default

qt6_add_resources(QML_RESOURCES
    qml.qrc)

include_directories(velib/inc .)

set(VELIB_SOURCES
    velib/inc/velib/velib_config.h
    velib/inc/velib/qt/ve_qitems_dbus.hpp
    velib/inc/velib/qt/ve_qitem_dbus_publisher.hpp
    velib/inc/velib/qt/ve_qitem.hpp
    velib/inc/velib/qt/ve_qitem_loader.hpp
    velib/inc/velib/qt/ve_qitem_tree_model.hpp
    velib/inc/velib/qt/v_busitems.h
    velib/src/qt/v_busitem_proxy.h
    velib/src/qt/v_busitem_proxy.cpp
    velib/src/qt/ve_qitem_dbus_virtual_object.hpp
    velib/src/qt/ve_qitem_dbus_virtual_object.cpp
    velib/src/qt/ve_qitems_dbus.cpp
    velib/src/qt/ve_qitem_dbus_publisher.cpp
    velib/src/qt/ve_qitem.cpp
    velib/src/qt/ve_qitem_loader.cpp
    velib/src/qt/ve_qitem_tree_model.cpp
    velib/src/qt/v_busitems.cpp
)

list(APPEND SOURCES
    main.cpp
    theme.h
    theme.cpp
    language.h
    language.cpp
    logging.h
    ${VELIB_SOURCES}
    ${QML_RESOURCES}
)

message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")
if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    add_executable(${PROJECT_NAME}
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
elseif(VENUS_DESKTOP_BUILD)
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
else()
    add_executable(${PROJECT_NAME}
        ${SOURCES}
    )
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::Xml
    Qt6::DBus
)

qt6_add_qml_module(${PROJECT_NAME}
    URI Victron.VenusOS
    VERSION 2.0
)

find_package(Qt6QmlImportScanner)
if (Qt6QmlImportScanner_FOUND)
    qt6_import_qml_plugins(${PROJECT_NAME})
endif()

# translations support.
# note: the base venus-gui-v2.ts was generated with:
# lupdate.exe qml.qrc -ts i18n/venus-gui-v2.ts
add_custom_command(
    TARGET ${PROJECT_NAME}
    PRE_BUILD
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lupdate
    ARGS "qml.qrc" -ts "i18n/venus-gui-v2.ts"
                       "i18n/venus-gui-v2_en.ts"
                       "i18n/venus-gui-v2_fr.ts"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Manually generating base translations file"
)
# the custom command above shouldn't be required...
qt6_add_translations(${PROJECT_NAME}
    TS_FILES
        i18n/venus-gui-v2.ts # base
        i18n/venus-gui-v2_en.ts
        i18n/venus-gui-v2_fr.ts
    SOURCES
        ${QML_RESOURCES}
    LRELEASE_OPTIONS
        -idbased
)
