#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#

# Compiles the plugins in this folder with tools/gui-v2-plugin-compiler.py into TEST_PLUGINS_DIR.
# A test loads them by setting VENUS_GUI_PLUGINS_DIR to that folder, and by depending on the
# test_plugins target.

set(PLUGIN_COMPILER "${CMAKE_SOURCE_DIR}/tools/gui-v2-plugin-compiler.py")

# Compiles the plugin in the NAME folder, which holds the SOURCES files, with the compiler
# arguments COMPILER_ARGS.
function(add_test_plugin NAME)
	cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "SOURCES;COMPILER_ARGS")
	set(json "${TEST_PLUGINS_DIR}/${NAME}.json")
	list(TRANSFORM arg_SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/${NAME}/" OUTPUT_VARIABLE sources)
	add_custom_command(
		OUTPUT "${json}"
		COMMAND ${CMAKE_COMMAND}
			"-DPYTHON=${Python3_EXECUTABLE}"
			"-DCOMPILER=${PLUGIN_COMPILER}"
			"-DLUPDATE=$<TARGET_FILE:Qt6::lupdate>"
			"-DLRELEASE=$<TARGET_FILE:Qt6::lrelease>"
			"-DRCC=$<TARGET_FILE:Qt6::rcc>"
			"-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/${NAME}"
			"-DWORK_DIR=${CMAKE_CURRENT_BINARY_DIR}/${NAME}"
			"-DOUTPUT=${json}"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/compile_test_plugin.cmake"
			-- ${arg_COMPILER_ARGS}
		DEPENDS
			${sources}
			"${CMAKE_CURRENT_SOURCE_DIR}/compile_test_plugin.cmake"
			"${PLUGIN_COMPILER}"
			"${CMAKE_SOURCE_DIR}/tools/guiplugins-api.json"
		VERBATIM
	)
	set(test_plugin_jsons ${test_plugin_jsons} "${json}" PARENT_SCOPE)
endfunction()

set(test_plugin_jsons "")

# Cards for the Controls and Switches panes. Each pane gets a card that is taller than the screen,
# then a short card, so that a test can move the focus back into the tall card from the next card.
# TestCards_CardThatCannotBeCreated.qml is packed, but is not a card integration: a test adds it.
add_test_plugin(TestCards
	SOURCES
		TestCards_TallControlsCard.qml
		TestCards_ControlsCard.qml
		TestCards_TallSwitchesCard.qml
		TestCards_SwitchesCard.qml
		TestCards_CardThatCannotBeCreated.qml
	COMPILER_ARGS
		--card TestCards_TallControlsCard.qml 1
		--card TestCards_ControlsCard.qml 1
		--card TestCards_TallSwitchesCard.qml 2
		--card TestCards_SwitchesCard.qml 2
)

# Quick access panes for tst_quickaccesspane. Panes A and B have an active icon, and pane C does not.
add_test_plugin(TestQuickAccess
	SOURCES
		TestQuickAccess_PaneA.qml
		TestQuickAccess_PaneB.qml
		TestQuickAccess_PaneC.qml
		icon_pane.svg
		icon_pane_active.svg
	COMPILER_ARGS
		--quickaccess TestQuickAccess_PaneA.qml icon_pane.svg icon_pane_active.svg
		--quickaccess TestQuickAccess_PaneB.qml icon_pane.svg icon_pane_active.svg
		--quickaccess TestQuickAccess_PaneC.qml icon_pane.svg
)

add_custom_target(test_plugins DEPENDS ${test_plugin_jsons})

# On Windows, the tests are installed, and can run without the build tree, so install the plugins
# with them, into tests/test-plugins next to the test executables. See cmake/UnitTests.cmake.
if (WIN32)
	install(FILES ${test_plugin_jsons}
		CONFIGURATIONS Debug DESTINATION ${CMAKE_INSTALL_BINDIR}/tests/test-plugins)
endif()

# Quick access pane used by the UI tests in tests/ui/plugins. The icon is copied from the example.
set(PLUGIN_ICON "${CMAKE_SOURCE_DIR}/examples/QuickAccessExample/icon_brick_off.svg")
set(PROBE_ROOT "${CMAKE_BINARY_DIR}/probe-plugins")

function(add_probe_plugin DIR QML)
	set(work "${PROBE_ROOT}/${DIR}")
	set(json "${PROBE_ROOT}/${DIR}.json")
	set(prepared "${work}/prepared")
	add_custom_command(
		OUTPUT "${prepared}"
		COMMAND ${CMAKE_COMMAND} -E make_directory "${work}" "${TEST_PLUGINS_DIR}"
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			"${CMAKE_CURRENT_SOURCE_DIR}/${DIR}/${QML}" "${work}/${QML}"
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			"${PLUGIN_ICON}" "${work}/icon_brick.svg"
		COMMAND ${CMAKE_COMMAND} -E touch "${prepared}"
		DEPENDS
			"${CMAKE_CURRENT_SOURCE_DIR}/${DIR}/${QML}"
			"${PLUGIN_ICON}"
		VERBATIM
	)
	add_custom_command(
		OUTPUT "${json}"
		COMMAND ${CMAKE_COMMAND}
		        "-DPYTHON=${Python3_EXECUTABLE}"
			"-DCOMPILER=${PLUGIN_COMPILER}"
			"-DLUPDATE=$<TARGET_FILE:Qt6::lupdate>"
			"-DLRELEASE=$<TARGET_FILE:Qt6::lrelease>"
			"-DRCC=$<TARGET_FILE:Qt6::rcc>"
			"-DSOURCE_DIR=${work}"
			"-DWORK_DIR=${CMAKE_CURRENT_BINARY_DIR}/${DIR}"
			"-DOUTPUT=${json}"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/compile_test_plugin.cmake"
			-- ${ARGN}
		DEPENDS
			"${prepared}"
			"${CMAKE_CURRENT_SOURCE_DIR}/compile_test_plugin.cmake"
			"${PLUGIN_COMPILER}"
			"${CMAKE_SOURCE_DIR}/tools/guiplugins-api.json"
		VERBATIM
	)
	set(accumulated ${probe_jsons})
	list(APPEND accumulated "${json}")
	set(probe_jsons "${accumulated}" PARENT_SCOPE)
endfunction()

set(probe_jsons "")
add_probe_plugin(ProbeQuick ProbeQuick_Pane.qml
	--quickaccess ProbeQuick_Pane.qml icon_brick.svg icon_brick.svg)

add_custom_target(probe_plugins DEPENDS ${probe_jsons})
add_custom_command(TARGET probe_plugins POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E rm -f
		"${CMAKE_BINARY_DIR}/bin/plugins/ProbeQuick.json"
	VERBATIM
)
