find_package(Qt6 ${REQUIRED_QT_VERSION}
    COMPONENTS
        Core Gui Qml Quick QuickTest QuickControls2 Svg Xml Mqtt
    REQUIRED)

if(VENUS_WEBASSEMBLY_BUILD)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS WebSockets REQUIRED)
else()
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS DBus REQUIRED)
endif()


macro(add_unit_test DIR_NAME TEST_NAME TEST_SOURCES TEST_QML)

qt_add_executable(${TEST_NAME}
    ${TEST_SOURCES}
    ${TEST_QML}
)

set_target_properties(${TEST_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

option(VENUS_INSTALL_TESTS "enable test installation via cmake -DVENUS_INSTALL_TESTS=ON" OFF) # Disabled by default
if (VENUS_INSTALL_TESTS)
    install(FILES ${TEST_QML} DESTINATION ${CMAKE_BINARY_DIR}/install/tests/${DIR_NAME}/)
    install(TARGETS ${TEST_NAME} DESTINATION ${CMAKE_BINARY_DIR}/install/tests/)
else()
    add_custom_command(
        TARGET ${TEST_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
                    "${CMAKE_BINARY_DIR}/tests/${DIR_NAME}"
        COMMAND ${CMAKE_COMMAND} -E copy
                    "${CMAKE_CURRENT_SOURCE_DIR}/${TEST_QML}"
                    "${CMAKE_BINARY_DIR}/tests/${DIR_NAME}/${TEST_QML}")
endif()

target_link_libraries(${TEST_NAME} PRIVATE
    VictronVenusOS
    VictronVenusOSplugin
    VictronVenusOSShaders
    VictronVenusOSShadersplugin
    VictronGauges
    VictronGaugesplugin
    VictronBoat
    VictronBoatplugin
    VictronMock
    VictronMockplugin
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickTest
    Qt6::QuickPrivate
    Qt6::Svg
    Qt6::Xml
    Qt6::Mqtt
)

if(VENUS_WEBASSEMBLY_BUILD)
    target_link_libraries(${TEST_NAME} PRIVATE
        Qt6::WebSockets
    )
else()
    target_link_libraries(${TEST_NAME} PRIVATE
        Qt6::DBus
    )
endif()

qt_import_qml_plugins(${TEST_NAME})

add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})

endmacro()


macro(add_single_file_unit_test NAME)
add_unit_test(${NAME} "tst_${NAME}" "tst_${NAME}.cpp" "tst_${NAME}.qml")
endmacro()
