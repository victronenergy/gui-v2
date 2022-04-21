/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	readonly property int accessLevel: veAccessLevel.value || -1

	property QtObject briefView: QtObject {
		property ListModel gauges: ListModel {
			ListElement { value: VenusOS.Tank_Type_Battery }
			ListElement { value: VenusOS.Tank_Type_Fuel }
			ListElement { value: VenusOS.Tank_Type_FreshWater }
			ListElement { value: VenusOS.Tank_Type_BlackWater }
		}
		property bool showPercentages

		function setGauge(index, value) {
			const obj = briefViewLevels.objectAt(index)
			if (obj) {
				obj.setValue(value === VenusOS.Tank_Type_Battery ? -1 : value)
				gauges.setProperty(index, "value", value)
			} else {
				console.warn("No gauge at index", index)
			}
		}

		function setShowPercentages(value) {
			veShowPercentages.setValue(value)
			showPercentages = value
		}

		property Instantiator briefViewLevels: Instantiator {
			model: 4
			delegate: VeQuickItem {
				uid: veSettings.childUId("/Settings/Gui/BriefView/Level/" + (model.index + 1))

				onValueChanged: {
					if (value !== undefined) {
						const v = value === -1 ? VenusOS.Tank_Type_Battery : value
						root.briefView.gauges.setProperty(model.index, "value", v)
					}
				}
			}
		}

		property VeQuickItem veShowPercentages: VeQuickItem {
			uid: veSettings.childUId("/Settings/Gui/BriefView/ShowPercentages")
			onValueChanged: if (value !== undefined) root.briefView.showPercentages = value === 1
		}
	}

	function setAccessLevel(value) {
		veAccessLevel.setValue(value)
	}

	function setDisplayMode(value) {
		veDisplayMode.setValue(value)
	}

	VeQuickItem {
		id: veAccessLevel
		uid: veSettings.childUId("/Settings/System/AccessLevel")
	}

	VeQuickItem {
		id: veDisplayMode
		uid: veSettings.childUId("/Settings/Gui/DisplayMode")
		onValueChanged: {
			if (value === Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Dark)
			} else if (value === Theme.Light) {
				Theme.load(Theme.screenSize, Theme.Light)
			}
		}
	}
}
