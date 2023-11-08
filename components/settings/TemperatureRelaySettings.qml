/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Column {
	id: root

	property int relayNumber
	property string sensorId
	property bool relayActivateOnTemperature
	property bool hasInvalidRelayTempConfig

	readonly property string tempRelayPrefix: "com.victronenergy.temprelay/Sensor/" + sensorId
	readonly property string settingsBindPrefix: "com.victronenergy.settings/Settings/TempSensorRelay/" + sensorId
	readonly property bool relayValue: cRelay.currentValue

	function showEqualValuesWarningToast() {
		//% "Warning: Activation and deactivation temperatures are set to the same value. This will lead the condition to be ignored."
		Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("settings_relay_equal_values_warning"))
	}

	width: parent ? parent.width : 0

	DataPoint {
		id: relay1Item
		source: "com.victronenergy.system/Relay/1/State"
	}

	ListTextItem {
		//% "Condition %1"
		text: qsTrId("settings_relay_condition").arg(root.relayNumber + 1)
		secondaryText: root.relayActivateOnTemperature
			? dataValue
				? CommonWords.active_status
				: CommonWords.inactive_status
			  //% "Function disabled"
			: qsTrId("settings_relay_function_disabled")
		dataSource: "%1/%2/State".arg(root.tempRelayPrefix).arg(root.relayNumber)
	}

	ListRadioButtonGroup {
		id: cRelay

		text: CommonWords.relay
		dataSource: "%1/%2/Relay".arg(root.settingsBindPrefix).arg(root.relayNumber)
		optionModel: [
			//% "None (Disable)"
			{ display: qsTrId("settings_relay_none"), value: -1 },
			//% "Relay 1"
			{ display: qsTrId("settings_relay1"), value: 0 },
			//% "Relay 2"
			{ display: qsTrId("settings_relay2"), value: 1, readOnly: !relay1Item.valid },
		]

		ListLabel {
			//% "Warning: The above selected relay is not configured for temperature, this condition will be ignored."
			text: qsTrId("settings_relay_invalid_temp_config_warning")
			visible: root.hasInvalidRelayTempConfig
		}
	}

	ListSpinBox {
		id: cSet

		//% "Activation value"
		text: qsTrId("settings_relay_activation_value")
		dataSource: "%1/%2/SetValue".arg(root.settingsBindPrefix).arg(root.relayNumber)
		from: -50
		to: 100

		// TODO the unit string shouldn't be determined here. Fix when units are updated to use velib unit features.
		suffix: Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Fahrenheit ? "F" : "C"

		onValueChanged: {
			if (value === cClear.value) {
				showEqualValuesWarningToast()
			}
		}
	}

	ListSpinBox {
		id: cClear

		//% "Deativation value"
		text: qsTrId("settings_relay_deactivation_value")
		dataSource: "%1/%2/ClearValue".arg(root.settingsBindPrefix).arg(root.relayNumber)
		from: cSet.from
		to: cSet.to
		suffix: cSet.suffix

		onValueChanged: {
			if (value === cSet.value) {
				showEqualValuesWarningToast()
			}
		}
	}
}
