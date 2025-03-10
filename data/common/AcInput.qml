/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: root

	required property AcInputSystemInfo inputInfo

	// True if this is an energy meter, or is the active input for a Multi/Quattro or MultiRS.
	readonly property bool operational: _phaseMeasurements.bindPrefix.length > 0

	readonly property bool connected: inputInfo && inputInfo.connected
	readonly property string serviceType: !!inputInfo ? inputInfo.serviceType : ""
	readonly property string serviceName: !!inputInfo ? inputInfo.serviceName : ""

	readonly property int source: !!inputInfo ? inputInfo.source : VenusOS.AcInputs_InputSource_NotAvailable
	readonly property int gensetStatusCode: _gensetStatusCode.valid ? _gensetStatusCode.value : -1

	// clamp to zero any values with magnitude < 1 (assume it's noise) to avoid UI flicker.
	readonly property real power: (Math.floor(Math.abs(_phaseMeasurements.power)) < 1.0) ? 0.0 : _phaseMeasurements.power
	readonly property real current: _phaseMeasurements.current
	readonly property alias phases: _phaseMeasurements.phases

	// Phase measurements from the input.
	readonly property ObjectAcConnection _phaseMeasurements: ObjectAcConnection {
		id: _phaseMeasurements

		bindPrefix: {
			if (!root.inputInfo || !root.inputInfo.valid) {
				return ""
			}
			switch (root.serviceType) {
			case "vebus":
				// Multi/Quattro can only measure its active input, i.e. when both:
				// - system /Ac/In/<x>/Connected=1 for this input
				// - this input matches the vebus /Ac/ActiveIn value
				if (root.inputInfo.connected
						&& _activeInput.valid
						&& root.inputInfo.inputIndex === _activeInput.value) {
					return root.serviceUid + "/Ac/ActiveIn"
				}
				break
			case "acsystem":
				// Multi RS is like the vebus case; it can only measure its active input.
				if (root.inputInfo.connected
						&& _activeInput.valid
						&& root.inputInfo.inputIndex === _activeInput.value) {
					return "%1/Ac/In/%2".arg(root.serviceUid).arg(_activeInput.value + 1)
				}
				break
			case "grid":
			case "genset":
				// Energy meter measurements can always be read. Ignore /Ac/In/<x>/Connected value
				// as the meter may produce power even when not connected.
				return root.serviceUid + "/Ac"
			default:
				console.warn("AcInput: unsupported service type", root.serviceType)
			}
			return ""
		}
		powerKey: root.serviceType === "vebus" || root.serviceType === "acsystem" ? "P" : "Power"
		currentKey: root.serviceType === "vebus" || root.serviceType === "acsystem" ? "I" : "Current"
		_phaseCount.uid: {
			if (root.inputInfo && root.inputInfo.valid) {
				if (root.serviceType === "vebus" || root.serviceType === "acsystem") {
					return root.serviceUid + "/Ac/NumberOfPhases"
				} else if (root.serviceType === "grid" || root.serviceType === "genset") {
					return root.serviceUid + "/NrOfPhases"
				}
			}
			return ""
		}
	}

	// The currently-active input on vebus or acsystem. 0 = ACin-1, 1 = ACin-2, 240 is none (inverting).
	readonly property VeQuickItem _activeInput: VeQuickItem {
		uid: root.inputInfo && root.inputInfo.valid && (root.serviceType === "vebus" || root.serviceType === "acsystem")
			 ? root.serviceUid + "/Ac/ActiveIn/ActiveInput"
			 : ""
	}

	// StatusCode is only valid for genset devices
	readonly property VeQuickItem _gensetStatusCode: VeQuickItem {
		uid: root.inputInfo && root.inputInfo.valid && root.serviceType === "genset" ? root.serviceUid + "/StatusCode" : ""
	}
}
