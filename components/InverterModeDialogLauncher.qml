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

	property var _modeDialog

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
		if (!_modeDialog) {
			if (_isInverterChargerItem.value === 1) {
				_modeDialog = _inverterChargerModeDialogComponent.createObject(Global.dialogLayer)
			} else {
				_modeDialog = _inverterModeDialogComponent.createObject(Global.dialogLayer)
			}
		}
		_modeDialog.mode = _modeItem.value
		_modeDialog.open()
	}
}
