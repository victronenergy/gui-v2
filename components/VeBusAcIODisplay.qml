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
	sourceComponent: numberOfAcInputs.value === 0 ? null
				   : numberOfPhases.value === 1 ? singlePhaseAcInOut
				   : numberOfPhases.value === 3 ? threePhaseTables : null

	VeQuickItem {
		id: numberOfPhases
		uid: root.serviceUid + "/Ac/NumberOfPhases"
	}

	VeQuickItem {
		id: numberOfAcInputs
		uid: root.serviceUid + "/Ac/NumberOfAcInputs"
	}

	Component {
		id: singlePhaseAcInOut

		SettingsColumn {
			PVCFListQuantityGroup {
				text: CommonWords.ac_in
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/ActiveIn/L1" }
			}

			PVCFListQuantityGroup {
				text: CommonWords.ac_out
				data: AcPhase { serviceUid: root.serviceUid + "/Ac/Out/L1" }
			}
		}
	}

	Component {
		id: threePhaseTables

		ThreePhaseIOTable {
			width: parent ? parent.width : 0
			phaseCount: numberOfPhases.value || 0
			inputPhaseUidPrefix: root.serviceUid + "/Ac/ActiveIn"
			outputPhaseUidPrefix: root.serviceUid + "/Ac/Out"
			totalInputPowerUid: root.serviceUid + "/Ac/ActiveIn/P"
			totalOutputPowerUid: root.serviceUid + "/Ac/Out/P"
			voltPrecision: 2
		}
	}
}
