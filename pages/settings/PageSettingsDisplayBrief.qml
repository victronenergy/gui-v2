/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Page {
	id: root

	readonly property var _gaugeOptionsModel: {
		const validGaugeOptions = Gauges.briefCentralGauges.map(function(gaugeType) {
			const name = Gauges.tankProperties(gaugeType).name || ""
			return { display: name, value: gaugeType }
		})
		//% "None"
		return [ { display: qsTrId("settings_briefview_level_none"), value: VenusOS.Tank_Type_None } ].concat(validGaugeOptions)
	}

	// Use this intermediate model that is built when the page loads, to avoid changing the model
	// while the radio button group sub-page is shown, as that causes the group options to be rebuilt.
	property var _gaugesModel
	onIsCurrentPageChanged: {
		if (isCurrentPage) {
			_gaugesModel = Global.systemSettings.briefView.centralGauges.preferredOrder
		}
	}

	GradientListView {
		model: root._gaugesModel

		delegate: ListRadioButtonGroup {
			required property int index

			//: Level number
			//% "Level %1"
			text: qsTrId("settings_briefview_level").arg(index + 1)
			optionModel: root._gaugeOptionsModel
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/Level/" + index
		}

		footer: SettingsColumn {
			topPadding: Theme.geometry_gradientList_spacing
			width: parent.width

			ListRadioButtonGroup {
				//: Show percentage values in Brief view
				//% "Brief view unit"
				text: qsTrId("settings_briefview_unit")
				optionModel: [
					//% "No labels"
					{ display: qsTrId("settings_briefview_unit_none"), value: VenusOS.BriefView_Unit_None },
					//% "Show tank volumes"
					{ display: qsTrId("settings_briefview_unit_absolute"), value: VenusOS.BriefView_Unit_Absolute },
					//% "Show percentages"
					{ display: qsTrId("settings_briefview_unit_percentages"), value: VenusOS.BriefView_Unit_Percentage },
				]
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/Unit"
			}
		}
	}
}
