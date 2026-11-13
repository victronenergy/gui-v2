add_single_file_unit_test(pluginconfirmationdialog)

# The dialog's buttons use a press effect that imports Victron.UiTest. The QML import scanner does
# not follow that import, so link the static plugin here or the test cannot create the dialog.
target_link_libraries(tst_pluginconfirmationdialog PRIVATE
	VictronUiTest
	VictronUiTestplugin
	VictronUiTestplugin_init
	VictronUiTest_resources_1
	VictronUiTest_resources_2
	VictronUiTest_resources_3
)
