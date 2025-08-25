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
			id: temperatureQuantity

			readonly property real temperature: output.displayTemperature
				? Units.convert(output.dimming, VenusOS.Units_Temperature_Celsius, Global.systemSettings.temperatureUnit) : NaN

			object: output.displayTemperature ? temperatureQuantity : null
			key: "temperature"
			unit: Global.systemSettings.temperatureUnit
		}
		QuantityObject { object: output.displayPercentage ? output : null; key: "dimming"; unit: VenusOS.Units_Percentage }
		QuantityObject { object: output.displayPercentage ? null : output; key: "statusText" }
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

		readonly property bool displayTemperature: type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
		readonly property bool displayPercentage: type === VenusOS.SwitchableOutput_Type_Dimmable
				&& ((status === VenusOS.SwitchableOutput_Status_On)
					|| (status === VenusOS.SwitchableOutput_Status_Output_Fault))
		readonly property string statusText: VenusOS.switchableOutput_statusToText(status)
		readonly property string typeText: VenusOS.switchableOutput_typeToText(type, name)

		uid: root.uid
	}

	VeQuickItem {
		id: outputCurrent
		uid: root.uid + "/Current"
	}
}
