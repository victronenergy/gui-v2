/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	property string serviceUid
	property string serviceType

	readonly property real totalPower: (!hasTotalPower || !item) ? NaN
			: isNaN(_itemPower) ? NaN
			: _feedbackEnabled ? _itemPower
			: _itemPower > 0 ? _itemPower // see AcInputs.clampMeasurement()
			: 0.0
	readonly property bool hasTotalPower: serviceType === "vebus" || serviceType == "grid" || serviceType == "genset"

	readonly property real currentLimit: !!item ? item.currentLimit : NaN
	readonly property int gensetStatusCode: _gensetStatusCode.value === undefined ? -1 : _gensetStatusCode.value

	// StatusCode is only valid for genset devices
	readonly property VeQuickItem _gensetStatusCode: VeQuickItem {
		uid: root.active && root.serviceUid && root.serviceType === "genset" ? root.serviceUid + "/StatusCode" : ""
	}

	readonly property bool _feedbackEnabled: Global.systemSettings.essFeedbackToGridEnabled

	readonly property real _itemPower: !item ? 0.0
			: item.power === undefined ? NaN
			: item.power

	sourceComponent: {
		if (serviceUid == "" || serviceType == "") {
			return null
		} else if (serviceType == "vebus") {
			return vebusComponent
		} else if (serviceType == "multi") {
			return multiComponent
		} else if (serviceType == "grid" || serviceType == "genset") {
			return gridOrGensetComponent
		} else {
			console.warn("Unsupported AC input service:", serviceType, "for uid:", serviceUid)
			return null
		}
	}

	onStatusChanged: {
		if (status === Loader.Error) {
			console.warn("Unable to load AC input service:", serviceUid)
		}
	}

	Component {
		id: vebusComponent

		QtObject {
			readonly property real power: !_power.isValid ? _powerValue // Will be NaN.
					: root._feedbackEnabled ? _powerValue
					: _powerValue > 0 ? _powerValue // see AcInputs.clampMeasurement().
					: 0.0
			readonly property real currentLimit: _currentLimit.numberValue
			readonly property real _powerValue: _power.numberValue

			readonly property VeQuickItem _power: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/P"
			}

			readonly property VeQuickItem _activeInput: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/ActiveInput"
			}
			// Current limit for each AC input: /Ac/In/<1+>/CurrentLimit
			readonly property VeQuickItem _currentLimit: VeQuickItem {
				uid: _activeInput.value === undefined ? ""
				   : root.serviceUid + "/Ac/In/" + (_activeInput.value + 1) + "/CurrentLimit"
			}
		}
	}


	Component {
		id: multiComponent

		QtObject {
			readonly property real currentLimit: _currentLimit.numberValue

			readonly property VeQuickItem _activeInput: VeQuickItem {
				uid: root.serviceUid + "/Ac/ActiveIn/ActiveInput"
			}
			readonly property VeQuickItem _currentLimit: VeQuickItem {
				uid: _activeInput.value === undefined ? ""
				   : root.serviceUid + "/Ac/In/" + (_activeInput.value + 1) + "/CurrentLimit"
			}
		}
	}

	// Paths are same for com.victronenergy.grid and com.victronenergy.genset, so this
	// component is used for both.
	Component {
		id: gridOrGensetComponent

		QtObject {
			readonly property bool _feedbackEnabled: Global.systemSettings.essFeedbackToGridEnabled

			readonly property real power: isNaN(_power.numberValue) ? _power.numberValue
					: _feedbackEnabled ? _power.numberValue
					: _power.numberValue > 0 ? _power.numberValue // See AcInputs.clampMeasurement().
					: 0

			// For these devices, there is no current limit.
			readonly property real currentLimit: NaN

			readonly property VeQuickItem _power: VeQuickItem {
				uid: root.serviceUid + "/Ac/Power"
			}
		}
	}
}
