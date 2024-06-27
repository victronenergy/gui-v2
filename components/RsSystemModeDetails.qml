/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string bindPrefix
	readonly property string modeText: Global.inverterChargers.inverterChargerModeToText(_modeItem.value)

	function openDialog() {
		Global.dialogLayer.open(_modeDialogComponent)
	}

	//--- internal members below ---

	readonly property VeQuickItem _modeItem: VeQuickItem {
		uid: root.bindPrefix + "/Mode"
	}

	readonly property VeQuickItem _numberOfPhases: VeQuickItem {
		uid: root.bindPrefix + "/Ac/NumberOfPhases"
	}

	readonly property VeQuickItem _hasPassthroughSupport: VeQuickItem {
		uid: root.bindPrefix + "/Capabilities/HasAcPassthroughSupport"
	}

	readonly property Component _modeDialogComponent: Component {
		InverterChargerModeDialog {
			isMulti: _numberOfPhases.isValid && _numberOfPhases.value > 1
			hasPassthroughSupport: _hasPassthroughSupport.value === 1
			mode: _modeItem.value
			onAccepted: _modeItem.setValue(mode)
		}
	}
}
