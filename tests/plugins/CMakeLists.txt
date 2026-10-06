set(PLUGIN_COMPILER "${CMAKE_SOURCE_DIR}/tools/gui-v2-plugin-compiler.py")
set(PLUGIN_ICON "${CMAKE_SOURCE_DIR}/examples/NavigationExample/icon_brick.svg")
set(PLUGINS_DIR "${CMAKE_BINARY_DIR}/bin/plugins")
set(PROBE_ROOT "${CMAKE_BINARY_DIR}/probe-plugins")

function(add_probe_plugin DIR QML)
	set(work "${PROBE_ROOT}/${DIR}")
	set(json "${PLUGINS_DIR}/${DIR}.json")
	add_custom_command(
		OUTPUT "${json}"
		COMMAND ${CMAKE_COMMAND} -E make_directory "${work}" "${PLUGINS_DIR}"
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			"${CMAKE_CURRENT_SOURCE_DIR}/${DIR}/${QML}" "${work}/${QML}"
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			"${PLUGIN_ICON}" "${work}/icon_brick.svg"
		COMMAND ${CMAKE_COMMAND} -E chdir "${work}"
			python3 "${PLUGIN_COMPILER}" ${ARGN}
		COMMAND ${CMAKE_COMMAND} -E copy_if_different "${work}/${DIR}.json" "${json}"
		DEPENDS
			"${CMAKE_CURRENT_SOURCE_DIR}/${DIR}/${QML}"
			"${PLUGIN_COMPILER}"
			"${PLUGIN_ICON}"
		VERBATIM
	)
	set(accumulated ${probe_jsons})
	list(APPEND accumulated "${json}")
	set(probe_jsons "${accumulated}" PARENT_SCOPE)
endfunction()

set(probe_jsons "")
add_probe_plugin(ProbeNav ProbeNav_Page.qml
	--navigation ProbeNav_Page.qml icon_brick.svg Probe)
add_probe_plugin(ProbeQuick ProbeQuick_Pane.qml
	--quickaccess ProbeQuick_Pane.qml icon_brick.svg icon_brick.svg)
add_probe_plugin(ProbeCard ProbeCard_Card.qml
	--card ProbeCard_Card.qml 1)

add_custom_target(probe_plugins ALL DEPENDS ${probe_jsons})
