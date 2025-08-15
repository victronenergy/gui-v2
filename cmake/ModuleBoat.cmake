qt_add_qml_module(VictronBoat
    URI Victron.Boat
    STATIC
    OUTPUT_DIRECTORY Victron/Boat
    QML_FILES ${VictronBoat_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

qt_add_resources(VictronBoat "VictronBoat_large_resources"
    BIG_RESOURCES
    FILES ${VictronBoat_QML_MODULE_RESOURCES}
)

if (${LOAD_QML_FROM_FILESYSTEM})
    qt_query_qml_module(VictronBoat QML_FILES module_qml_files QMLDIR module_qmldir)
    install(DIRECTORY pages/boat/  DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Boat)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Boat)
    add_custom_command(
        TARGET VictronBoat
        COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripRegexFromFile.cmake" ${module_qmldir} "^prefer.*$"
        VERBATIM
    )
endif()
