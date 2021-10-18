cmake_minimum_required(VERSION 3.5)

cmake_policy(SET CMP0079 NEW)

project(venus-gui-v2 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml LinguistTools)
if (NOT ${Qt6_FOUND})
    # cmake can't automatically find Qt 6.2 on Ubuntu Linux, give it a hint:
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        list(APPEND CMAKE_PREFIX_PATH "/opt/Qt/6.2.0/gcc_64/lib/cmake/")
    endif()

    find_package(Qt6 COMPONENTS Core Qml Quick Svg Xml LinguistTools REQUIRED)
endif()


qt6_add_resources(QML_RESOURCES
    qml.qrc)

list(APPEND SOURCES
    main.cpp
    theme.h
    theme.cpp
    logging.h
    ${QML_RESOURCES}
)

message("Building VenusOS for ${CMAKE_SYSTEM_NAME}")
if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    add_executable(venus-gui-v2
      MACOSX_BUNDLE
      ${SOURCES}
    )
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    add_compile_definitions(VENUS_DESKTOP_BUILD)
    add_executable(venus-gui-v2
        ${SOURCES}
    )
else()
    add_executable(venus-gui-v2
        ${SOURCES}
    )
endif()

target_compile_definitions(venus-gui-v2
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(venus-gui-v2 PRIVATE
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::Svg
    Qt6::Xml
)

qt6_add_qml_module(venus-gui-v2
    URI Victron.VenusOS
    VERSION 2.0
)

find_package(Qt6QmlImportScanner)
if (Qt6QmlImportScanner_FOUND)
    qt6_import_qml_plugins(venus-gui-v2)
endif()

# translations support.
# note: the base venus-gui-v2.ts was generated with:
# lupdate.exe qml.qrc -ts i18n/venus-gui-v2.ts
add_custom_command(
    TARGET venus-gui-v2
    PRE_BUILD
    COMMAND ${QT_CMAKE_EXPORT_NAMESPACE}::lupdate
    ARGS "qml.qrc" -ts "i18n/venus-gui-v2.ts"
                       "i18n/venus-gui-v2_en.ts"
                       "i18n/venus-gui-v2_fr.ts"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Manually generating base translations file"
)
# the custom command above shouldn't be required...
qt6_add_translations(venus-gui-v2
    TS_FILES
        i18n/venus-gui-v2.ts # base
        i18n/venus-gui-v2_en.ts
        i18n/venus-gui-v2_fr.ts
    SOURCES
        ${QML_RESOURCES}
    LRELEASE_OPTIONS
        -idbased
)
