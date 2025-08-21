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

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronBoat QML_FILES module_qml_files QMLDIR module_qmldir)
    install(DIRECTORY pages/boat/  DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Boat)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Boat)
endif()
