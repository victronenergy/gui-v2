# Victron.VeUtil (VeQuickItem and the VeQItem producers) is built by the veutil
# submodule. Its options follow this build: D-Bus except in WebAssembly, where
# the MQTT producer connects over a WebSocket instead. Its qmldir goes next to
# the other modules in the build directory, so that qmllint finds it, and it is
# installed next to them. Like cmake/QZXing.cmake, this sets the submodule's
# options and adds its own CMakeLists.txt.
if(VENUS_WEBASSEMBLY_BUILD)
    set(VEUTIL_DBUS OFF)
    set(VEUTIL_MQTT_WEBSOCKETS ON)
else()
    set(VEUTIL_DBUS ON)
    set(VEUTIL_MQTT_WEBSOCKETS OFF)
endif()
set(VEUTIL_QML_INSTALL_DIR "${VENUS_QML_INSTALL_DIR}")
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
add_subdirectory(src/veutil)
unset(QT_QML_OUTPUT_DIRECTORY)
