/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function configCount() {
		const settingsListView = Global.pageManager.currentPage.settingsListView
		return settingsListView ? settingsListView.model.length : 0
	}

	function loadConfig(configIndex) {
		const settingsListView = Global.pageManager.currentPage.settingsListView
		if (!settingsListView) {
			return
		}

		const modelData = settingsListView.model[configIndex]
		if (!modelData) {
			console.warn("Bad settings index", configIndex)
			return
		}
		Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
		return modelData.text
	}
}
