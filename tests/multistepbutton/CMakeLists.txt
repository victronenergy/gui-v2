add_single_file_unit_test(multistepbutton)

# Button's press effect imports Victron.UiTest. The QML import scanner does not follow that
# import, so link the static plugin here or the test cannot create the buttons.
target_link_libraries(tst_multistepbutton PRIVATE
	VictronUiTest
	VictronUiTestplugin
	VictronUiTestplugin_init
	VictronUiTest_resources_1
	VictronUiTest_resources_2
	VictronUiTest_resources_3
)
