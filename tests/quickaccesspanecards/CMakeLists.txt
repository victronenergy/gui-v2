add_single_file_unit_test(quickaccesspanecards)

# The test loads the plugins that tests/plugins compiles.
add_dependencies(tst_quickaccesspanecards test_plugins)
target_compile_definitions(tst_quickaccesspanecards PRIVATE
	VENUS_TEST_PLUGINS_DIR="${TEST_PLUGINS_DIR}"
)

# The cards use buttons, whose press effect imports Victron.UiTest. The QML import scanner does not
# follow that import, so link the static plugin here or the test cannot create them.
target_link_libraries(tst_quickaccesspanecards PRIVATE
	VictronUiTest
	VictronUiTestplugin
	VictronUiTestplugin_init
	VictronUiTest_resources_1
	VictronUiTest_resources_2
	VictronUiTest_resources_3
)
