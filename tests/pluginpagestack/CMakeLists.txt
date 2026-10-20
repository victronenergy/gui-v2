add_single_file_unit_test(pluginpagestack)

# PageStack.pushPluginPage() loads a plugin page from a URL. These fixtures are that URL.
qt_add_resources(tst_pluginpagestack "pluginpagestack_pages"
	PREFIX "/pluginpagestack"
	FILES
		pages/PluginSettingsPage.qml
		pages/PluginDevicePageTest.qml
		pages/LateTitlePage.qml
		pages/VenusPage.qml
		pages/NotAnItem.qml
		pages/PlainItem.qml
		pages/BrokenPage.qml
)
