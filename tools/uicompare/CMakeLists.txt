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
    SOURCES imagecomparator.h imagecomparator.cpp
    SOURCES imageprovider.h imageprovider.cpp
)

set_target_properties(uicompare PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if(APPLE)
    # Recent macOS/Xcode toolchains cannot link against AGL.
    # Qt6::Gui links WrapOpenGL::WrapOpenGL, which injects AGL via FindWrapOpenGL.
    # Remove that wrapper link and keep the regular OpenGL framework linkage.
    # NOTE: This is a workaround for Qt6 bug QTBUG-137687, which will be fixed in Qt 6.8.4.
    if(TARGET Qt6::Gui)
        get_target_property(_qt_gui_link_libs Qt6::Gui INTERFACE_LINK_LIBRARIES)
        if(_qt_gui_link_libs)
            list(REMOVE_ITEM _qt_gui_link_libs WrapOpenGL::WrapOpenGL)
            set_property(TARGET Qt6::Gui PROPERTY INTERFACE_LINK_LIBRARIES "${_qt_gui_link_libs}")
        endif()
    endif()
endif()

target_link_libraries(uicompare
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS uicompare
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
