cmake_minimum_required(VERSION 3.16)

project(uicompare VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(uicompare
    main.cpp
)

qt_add_qml_module(uicompare
    URI uicompare
    VERSION 1.0
    QML_FILES Main.qml ImageListView.qml CompareView.qml ImageListViewDelegate.qml Toolbar.qml
    SOURCES applicationsettings.h applicationsettings.cpp
    SOURCES comparemodel.h comparemodel.cpp
    SOURCES imageprovider.h imageprovider.cpp
)

set_target_properties(uicompare PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(uicompare
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS uicompare
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
