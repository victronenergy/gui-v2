/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function configCount() {
		if (!_settingsListView) {
			_settingsListView = Global.pageManager.currentPage.settingsListView
			if (!_settingsListView) {
				console.warn("Cannot find settingsListView!")
				return 0
			}
		}
		return _settingsListView.model.length
	}

	property var _settingsListView

	function loadConfig(configIndex) {
		const modelData = _settingsListView.model[configIndex]
		if (!modelData) {
			console.warn("Bad settings index", configIndex)
			return
		}
		Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
		return modelData.text
	}
}
