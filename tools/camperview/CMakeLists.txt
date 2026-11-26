cmake_minimum_required(VERSION 3.24)

project(camperview VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Svg Mqtt LinguistTools)

qt_standard_project_setup(REQUIRES 6.8)

set(GUIV2_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Build Victron.VeUtil (VeQuickItem and the MQTT backend) from the veutil submodule, as
# gui-v2's cmake/VeUtil.cmake does. The app only reads over MQTT, so D-Bus is left out.
set(VEUTIL_DBUS OFF)
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
	set(VENUS_WEBASSEMBLY_BUILD ON)
	set(VEUTIL_MQTT_WEBSOCKETS ON)
else()
	set(VEUTIL_MQTT_WEBSOCKETS OFF)
endif()
set(VEUTIL_QT_VERSION 6.8)
set(VEUTIL_QML_INSTALL_DIR ".")
add_subdirectory("${GUIV2_ROOT_DIR}/src/veutil" veutil)

include("${GUIV2_ROOT_DIR}/cmake/ModuleCamper_Sources.cmake")
set(VictronCamper_ROOT_DIR "${GUIV2_ROOT_DIR}")
include("${GUIV2_ROOT_DIR}/cmake/ModuleCamper.cmake")

set(CAMPER_HOST_FILES ${VictronCamper_HOST_IMAGES} fonts/Roboto-Regular.ttf)
set(CAMPER_HOST_RESOURCES "")
foreach(host_file IN LISTS CAMPER_HOST_FILES)
	set_source_files_properties("${GUIV2_ROOT_DIR}/${host_file}" PROPERTIES QT_RESOURCE_ALIAS "${host_file}")
	list(APPEND CAMPER_HOST_RESOURCES "${GUIV2_ROOT_DIR}/${host_file}")
endforeach()

qt_add_executable(camperview
	main.cpp
	camperbackend.cpp
	camperbackend.h
	camperlanguage.cpp
	camperlanguage.h
	"${GUIV2_ROOT_DIR}/src/mqttaddress.cpp"
	"${GUIV2_ROOT_DIR}/src/mqttaddress.h"
)

# Shares src/mqttaddress.cpp with gui-v2, so both apps pick the same VRM broker.
target_include_directories(camperview PRIVATE "${GUIV2_ROOT_DIR}/src")

qt_add_qml_module(camperview
	URI CamperView
	VERSION 1.0
	QML_FILES
		qml/Main.qml
)

qt_add_resources(camperview "camperview_images"
	PREFIX "/"
	FILES ${CAMPER_HOST_RESOURCES}
)

# A small catalogue per language, with only this app's ids, cut from gui-v2's translations.
# lupdate -no-obsolete drops every message that the camper sources do not use, keeping the
# translations of those that they do. venus-gui-v2.ts gives the English catalogue.
set(CAMPER_TRANSLATION_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/qml/Main.qml")
foreach(qml_file IN LISTS VictronCamper_QML_MODULE_SOURCES)
	list(APPEND CAMPER_TRANSLATION_SOURCES "${GUIV2_ROOT_DIR}/${qml_file}")
endforeach()
file(GLOB CAMPER_GUIV2_TS_FILES CONFIGURE_DEPENDS "${GUIV2_ROOT_DIR}/i18n/venus-gui-v2_*.ts")
list(APPEND CAMPER_GUIV2_TS_FILES "${GUIV2_ROOT_DIR}/i18n/venus-gui-v2.ts")
set(CAMPER_QM_FILES "")
foreach(guiv2_ts IN LISTS CAMPER_GUIV2_TS_FILES)
	get_filename_component(ts_name "${guiv2_ts}" NAME_WE)
	string(REPLACE "venus-gui-v2" "camperview" catalogue "${ts_name}")
	if(catalogue STREQUAL "camperview")
		set(catalogue "camperview_en")
	endif()
	set(camper_ts "${CMAKE_CURRENT_BINARY_DIR}/i18n/${catalogue}.ts")
	set(camper_qm "${CMAKE_CURRENT_BINARY_DIR}/i18n/${catalogue}.qm")
	add_custom_command(
		OUTPUT "${camper_qm}"
		COMMAND ${CMAKE_COMMAND} -E copy "${guiv2_ts}" "${camper_ts}"
		COMMAND Qt6::lupdate -silent -no-obsolete ${CAMPER_TRANSLATION_SOURCES} -ts "${camper_ts}"
		COMMAND Qt6::lrelease -silent -idbased "${camper_ts}" -qm "${camper_qm}"
		DEPENDS "${guiv2_ts}" ${CAMPER_TRANSLATION_SOURCES}
		COMMENT "Generating ${catalogue}.qm"
	)
	set_source_files_properties("${camper_qm}" PROPERTIES QT_RESOURCE_ALIAS "${catalogue}.qm" GENERATED TRUE)
	list(APPEND CAMPER_QM_FILES "${camper_qm}")
endforeach()

qt_add_resources(camperview "camperview_translations"
	PREFIX "/i18n"
	FILES ${CAMPER_QM_FILES}
)

set_target_properties(camperview PROPERTIES
	WIN32_EXECUTABLE TRUE
	MACOSX_BUNDLE TRUE
)

target_link_libraries(camperview PRIVATE
	Qt6::Core
	Qt6::Gui
	Qt6::Qml
	Qt6::Quick
	Qt6::Svg
	VictronVeUtil
	VictronVeUtilplugin
	VictronCamper
	VictronCamperplugin
)

# main.cpp and camperbackend.cpp read the connection differently in WebAssembly.
if(VENUS_WEBASSEMBLY_BUILD)
	target_compile_definitions(camperview PRIVATE VENUS_WEBASSEMBLY_BUILD)
endif()

qt_import_qml_plugins(camperview)

# Stops the configure if Victron.Camper links another Victron module, as in gui-v2.
include("${GUIV2_ROOT_DIR}/cmake/CheckModuleLinks.cmake")
