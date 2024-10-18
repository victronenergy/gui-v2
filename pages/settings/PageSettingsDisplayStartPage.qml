/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _timeoutOptions() {
		//% "Never"
		let options = [ { display: qsTrId("settings_startpage_timeout_never"), value: 0 } ]
		const timeouts = [ 1, 5, 10, 30, 60 ]
		for (let i = 0; i < timeouts.length; ++i) {
			const minutes = timeouts[i]
			//% "After %n minute(s)"
			options.push({
				display: qsTrId("settings_startpage_timeout_minutes", minutes),
				value: minutes * 60
			})
		}
		return options
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				id: startPageName
				//% "Start page"
				text: qsTrId("settings_startpage_name")
				optionModel: Global.systemSettings.startPageConfiguration.options
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StartPage"
				bottomContentChildren: [
					ListLabel {
						width: Math.min(implicitWidth, startPageName.width)
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						//% "Go to this page when the application starts."
						text: qsTrId("settings_startpage_description")
					}
				]
			}

			ListRadioButtonGroup {
				id: startPageTimeout
				//% "Timeout"
				text: qsTrId("settings_startpage_timeout")
				optionModel: root._timeoutOptions()
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui2/StartPageTimeout"
				bottomContentChildren: [
					ListLabel {
						width: Math.min(implicitWidth, startPageTimeout.width)
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						//% "Revert to the start page when the application is inactive."
						text: qsTrId("settings_startpage_timeout_description")
					}
				]
			}
		}
	}

}
