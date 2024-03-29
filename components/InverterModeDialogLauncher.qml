/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string serviceUid

	readonly property string modeText: _isInverterChargerItem.value === 1
			? Global.inverterChargers.inverterChargerModeToText(_modeItem.value)
			: Global.inverterChargers.inverterModeToText(_modeItem.value)

	property VeQuickItem _isInverterChargerItem: VeQuickItem {
		uid: root.serviceUid + "/IsInverterCharger"
	}

	property VeQuickItem _modeItem: VeQuickItem {
		uid: root.serviceUid + "/Mode"
	}

	property Component _inverterModeDialogComponent: Component {
		InverterModeDialog {
			onAccepted: root._modeItem.setValue(mode)
		}
	}

	property Component _inverterChargerModeDialogComponent: Component {
		InverterChargerModeDialog {
			onAccepted: root._modeItem.setValue(mode)
		}
	}

	function openDialog() {
		if (!_modeDialog) { // TODO: "_modeDialog is not defined" if you click the mode button on an inverter card
			if (_isInverterChargerItem.value === 1) {
				Global.dialogLayer.open(_inverterChargerModeDialogComponent)
			} else {
				Global.dialogLayer.open(_inverterModeDialogComponent)
			}
		}
	}
}
