add_single_file_unit_test(pluginbutton)

# PluginButton uses Button, whose press effect imports Victron.UiTest. The QML import scanner does
# not follow that import, so link the static plugin here or the test cannot create it.
target_link_libraries(tst_pluginbutton PRIVATE
	VictronUiTest
	VictronUiTestplugin
	VictronUiTestplugin_init
	VictronUiTest_resources_1
	VictronUiTest_resources_2
	VictronUiTest_resources_3
)
