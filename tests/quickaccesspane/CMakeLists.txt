add_single_file_unit_test(quickaccesspane)

# The test loads the plugins that tests/plugins compiles.
add_dependencies(tst_quickaccesspane test_plugins)
target_compile_definitions(tst_quickaccesspane PRIVATE
	VENUS_TEST_PLUGINS_DIR="${TEST_PLUGINS_DIR}"
)

# The status bar buttons use the button press effect, which imports Victron.UiTest. The QML import
# scanner does not follow that import, so link the static plugin here or the test cannot create them.
target_link_libraries(tst_quickaccesspane PRIVATE
	VictronUiTest
	VictronUiTestplugin
	VictronUiTestplugin_init
	VictronUiTest_resources_1
	VictronUiTest_resources_2
	VictronUiTest_resources_3
)
