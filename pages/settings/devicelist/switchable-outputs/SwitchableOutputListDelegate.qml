/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroupNavigation {
	id: root

	required property string uid
	required property string name

	text: name
	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: outputCurrent; unit: VenusOS.Units_Amp }
		QuantityObject {
			// Show either the dimming value or the status text
			object: output
			key: output.displayDimmingValue ? "dimmingValue" : "statusText"
			unit: output.displayDimmingValue ? output.dimmingUnit : VenusOS.Units_None
		}
		QuantityObject { object: output; key: "typeText" }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/switchable-outputs/PageSwitchableOutput.qml", {
			outputUid: output.uid,
			title: Qt.binding(function() { return root.text })
		})
	}

	SwitchableOutput {
		id: output

		// TODO fix this to show the unit as well, once we have more info on the exact details
		// to show depending on the output type.
		readonly property bool displayDimmingValue: !isNaN(dimmingValue)
				&& (status === VenusOS.SwitchableOutput_Status_On
					|| status === VenusOS.SwitchableOutput_Status_Output_Fault)
		readonly property real dimmingValue: type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
				? Units.convert(dimming, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit)
				: (type === VenusOS.SwitchableOutput_Type_Dimmable || type === VenusOS.SwitchableOutput_Type_BasicSlider)
					? dimming
					: NaN
		readonly property int dimmingUnit: type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
				? Global.systemSettings.temperatureUnit
				: VenusOS.Units_Percentage

		readonly property string statusText: VenusOS.switchableOutput_statusToText(status)
		readonly property string typeText: VenusOS.switchableOutput_typeToText(type, name)

		uid: root.uid
	}

	VeQuickItem {
		id: outputCurrent
		uid: root.uid + "/Current"
	}
}
