/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListLoader {
	id: root

	property string serviceUid

	width: parent ? parent.width : 0
	sourceComponent: numberOfPhases.value === 1 ? singlePhaseAcInOut
				   : numberOfPhases.value === 3 ? threePhaseTables : null

	VeQuickItem {
		id: numberOfPhases
		uid: root.serviceUid + "/Ac/NumberOfPhases"
	}

	Component {
		id: singlePhaseAcInOut

		SettingsColumn {
			readonly property string singlePhaseName: acOutL3.valid ? "L3"
					: acOutL2.valid ? "L2"
					: "L1"  // i.e. if _phase.value === 0 || !_phase.valid

			VeQuickItem { id: acOutL1; uid: root.serviceUid + "/Ac/Out/L1/P" }
			VeQuickItem { id: acOutL2; uid: root.serviceUid + "/Ac/Out/L2/P" }
			VeQuickItem { id: acOutL3; uid: root.serviceUid + "/Ac/Out/L3/P" }

			PVCFListQuantityGroup {
				text: CommonWords.ac_in
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/In/1/" + singlePhaseName }
			}

			PVCFListQuantityGroup {
				text: CommonWords.ac_out
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/Out/" + singlePhaseName }
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			phaseCount: numberOfPhases.value || 0
			inputPhaseUidPrefix: root.serviceUid + "/Ac/In/1"
			outputPhaseUidPrefix: root.serviceUid + "/Ac/Out"
			totalInputPowerUid: root.multiPhase ? root.serviceUid + "/Ac/In/1/P" : ""
			totalOutputPowerUid: root.multiPhase ? root.serviceUid + "/Ac/Out/P" : ""
			voltPrecision: 2
		}
	}
}
