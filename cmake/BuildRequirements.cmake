set(REQUIRED_QT_VERSION 6.8.3)

find_package(Qt6 ${REQUIRED_QT_VERSION}
    COMPONENTS
        Core Gui Qml Quick QuickControls2 Svg Xml Mqtt LinguistTools ShaderTools
    REQUIRED)

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

if(VENUS_WEBASSEMBLY_BUILD)
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS WebSockets REQUIRED)
else()
    find_package(Qt6 ${REQUIRED_QT_VERSION} COMPONENTS DBus REQUIRED)
endif()

# Qt > 6.5 only.
# Enabling this policy ensures that your QML module is placed under a default import path,
# and its types can be found without manual calls to QQmlEngine::addImportPath.
if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 NEW)
endif()

# Supported languages / translation catalogues.
list(APPEND TS_CODES "af" "ar" "cs" "da" "de" "es" "fr" "it" "ja" "nl" "pl" "pt" "ro" "ru" "sv" "th" "tr" "uk" "zh_CN")
qt_standard_project_setup(REQUIRES ${REQUIRED_QT_VERSION}
    I18N_SOURCE_LANGUAGE en # optional - this is the default
    I18N_TRANSLATED_LANGUAGES ${TS_CODES}
)

