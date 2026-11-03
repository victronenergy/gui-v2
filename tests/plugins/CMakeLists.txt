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

add_custom_target(test_plugins DEPENDS ${test_plugin_jsons})

# On Windows, the tests are installed, and can run without the build tree, so install the plugins
# with them, into tests/test-plugins next to the test executables. See cmake/UnitTests.cmake.
if (WIN32)
	install(FILES ${test_plugin_jsons}
		CONFIGURATIONS Debug DESTINATION ${CMAKE_INSTALL_BINDIR}/tests/test-plugins)
endif()
