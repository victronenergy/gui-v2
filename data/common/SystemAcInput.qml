/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	An AC input as provided by the details from com.victronenergy.system/Ac/In/<x>.
*/
AcInput {
	id: root

	// True if this is an energy meter, or is the active input for a Multi/Quattro or MultiRS.
	operational: _phaseMeasurements.bindPrefix.length > 0

	// clamp to zero any values with magnitude < 1 (assume it's noise) to avoid UI flicker.
	power: (Math.floor(Math.abs(_phaseMeasurements.power)) < 1.0) ? 0.0 : _phaseMeasurements.power
	current: _phaseMeasurements.current
	measurementsUid: _phaseMeasurements.bindPrefix
	phases: _phaseMeasurements.phases

	// Phase measurements from the input.
	readonly property ObjectAcConnection _phaseMeasurements: ObjectAcConnection {
		id: _phaseMeasurements

		bindPrefix: {
			if (!root.inputInfo || !root.inputInfo.valid) {
				return ""
			}
			switch (root.serviceType) {
			case "vebus":
				// Multi/Quattro can only measure its active input, so if connected=true, then we
				// know this is the active input. Do not attempt to match inputInfo.inputIndex
				// against the value of system /Ac/ActiveIn/ActiveInput, as those do not match if
				// the first vebus input is disconnected.
				if (root.inputInfo.connected) {
					return root.serviceUid + "/Ac/ActiveIn"
				}
				break
			case "acsystem":
				// Multi RS is like the vebus case; it can only measure its active input.
				if (root.inputInfo.connected) {
					return "%1/Ac/In/%2".arg(root.serviceUid).arg(root.inputInfo.inputIndex + 1)
				}
				break
			case "grid":
			case "genset":
				// Energy meter measurements can always be read. Ignore /Ac/In/<x>/Connected value
				// as the meter may produce power even when not connected.
				return root.serviceUid + "/Ac"
			default:
				console.warn("SystemAcInput: unsupported service type", root.serviceType)
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
}
