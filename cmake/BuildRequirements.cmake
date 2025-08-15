set(REQUIRED_QT_VERSION 6.8.3)

find_package(Qt6 ${REQUIRED_QT_VERSION}
    COMPONENTS
        Core Gui Qml Quick QuickControls2 Svg Xml Mqtt LinguistTools ShaderTools
    REQUIRED)

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
list(APPEND TS_CODES "af" "ar" "cs" "da" "de" "es" "fr" "it" "nl" "pl" "ro" "ru" "sv" "th" "tr" "uk" "zh_CN")
qt_standard_project_setup(REQUIRES ${REQUIRED_QT_VERSION}
    I18N_SOURCE_LANGUAGE en # optional - this is the default
    I18N_TRANSLATED_LANGUAGES ${TS_CODES}
)

