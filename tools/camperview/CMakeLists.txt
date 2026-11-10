cmake_minimum_required(VERSION 3.24)

project(camperview VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Svg Mqtt)

qt_standard_project_setup(REQUIRES 6.8)

set(GUIV2_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Victron.VeUtil provides VeQuickItem and the MQTT backend. It needs the same definitions as in
# the gui-v2 build (see cmake/BuildDefines.cmake).
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Emscripten")
	set(VENUS_WEBASSEMBLY_BUILD ON)
	add_compile_definitions(VENUS_WEBASSEMBLY_BUILD MQTT_WEBSOCKETS_ENABLED)
	find_package(Qt6 REQUIRED COMPONENTS WebSockets)
else()
	find_package(Qt6 REQUIRED COMPONENTS DBus Xml)
endif()
set(VENUS_QML_INSTALL_DIR ".")
include("${GUIV2_ROOT_DIR}/cmake/VeUtil_Sources.cmake")
# The source list is relative to the gui-v2 root, as cmake/Translations.cmake expects.
list(TRANSFORM VictronVeUtil_CPP_SOURCES PREPEND "${GUIV2_ROOT_DIR}/")
include_directories("${GUIV2_ROOT_DIR}/src/veutil/inc")
include("${GUIV2_ROOT_DIR}/cmake/ModuleVeUtil.cmake")
set(CAMPER_SHARED_QML_DIR "${GUIV2_ROOT_DIR}/components/camper")

set(CAMPER_SHARED_QML_FILES
	"${CAMPER_SHARED_QML_DIR}/CamperBattery.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperDevice.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperDomainCard.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperFlowArrow.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperOverviewScene.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperOverviewView.qml"
	"${CAMPER_SHARED_QML_DIR}/CamperStateModel.qml"
)

foreach(qml_file IN LISTS CAMPER_SHARED_QML_FILES)
	get_filename_component(qml_name "${qml_file}" NAME)
	set_source_files_properties("${qml_file}" PROPERTIES QT_RESOURCE_ALIAS "${qml_name}")
endforeach()

file(GLOB CAMPER_ILLUSTRATION_FILES CONFIGURE_DEPENDS "${GUIV2_ROOT_DIR}/images/camper/camper_*.svg")

set(CAMPER_IMAGE_FILES
	${CAMPER_ILLUSTRATION_FILES}
	"${GUIV2_ROOT_DIR}/images/shore.svg"
	"${GUIV2_ROOT_DIR}/images/grid.svg"
	"${GUIV2_ROOT_DIR}/images/solaryield.svg"
	"${GUIV2_ROOT_DIR}/images/generator.svg"
	"${GUIV2_ROOT_DIR}/images/alternator.svg"
	"${GUIV2_ROOT_DIR}/images/dcloads.svg"
	"${GUIV2_ROOT_DIR}/images/acloads.svg"
)

foreach(image_file IN LISTS CAMPER_IMAGE_FILES)
	file(RELATIVE_PATH image_alias "${GUIV2_ROOT_DIR}" "${image_file}")
	set_source_files_properties("${image_file}" PROPERTIES QT_RESOURCE_ALIAS "${image_alias}")
endforeach()

qt_add_executable(camperview
	main.cpp
	camperbackend.cpp
	camperbackend.h
)

qt_add_qml_module(camperview
	URI CamperView
	VERSION 1.0
	QML_FILES
		qml/Main.qml
		${CAMPER_SHARED_QML_FILES}
)

qt_add_resources(camperview "camperview_images"
	PREFIX "/"
	FILES ${CAMPER_IMAGE_FILES}
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
)

qt_import_qml_plugins(camperview)
