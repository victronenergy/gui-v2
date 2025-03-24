/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

ListItemButton {
	id: root

	required property string generatorUid
	property string gensetUid: BackendConnection.serviceUidFromName(_gensetServiceName.value || "", _gensetInstance.value || 0)

	property int _generatorStateBeforeDialogOpen: -1

	flat: true
	enabled: _state.value !== VenusOS.Generators_State_Error && _state.value !== VenusOS.Generators_State_StoppedByTankLevel
			&& Global.systemSettings.canAccess(VenusOS.User_AccessType_User)
	color: enabled ? Theme.color_font_primary : Theme.color_font_disabled
	backgroundColor: checked ? Theme.color_dimRed : Theme.color_dimGreen

	// If the stop or start dialog is open, set the button color based on the generator
	// state at the time dialog was opened. This avoid changing the color of the button
	// when it is visible below the open start/stop dialogs.
	checked: _generatorStateBeforeDialogOpen < 0
			 ? _runningByConditionCode.value === VenusOS.Generators_RunningBy_Manual
			 : _generatorStateBeforeDialogOpen === VenusOS.Generators_State_Running 
			   && _runningByConditionCode.value === VenusOS.Generators_RunningBy_Manual

	text: checked
			//% "Manual Stop"
		  ? qsTrId("controlcard_generator_subcard_button_manual_stop")
			/* stopped */
			//% "Manual Start"
		  : qsTrId("controlcard_generator_subcard_button_manual_start")

	onClicked: {
		if (!_state.valid) {
			return
		}
		_generatorStateBeforeDialogOpen = _state.value

		// If genset /RemoteStartModeEnabled is set to 0, then it cannot be started/stopped.
		if (_remoteStartMode.valid && _remoteStartMode.value === 0) {
			Global.dialogLayer.open(noStartStopDialogComponent)
			return
		}

		if (_runningByConditionCode.value === VenusOS.Generators_RunningBy_Manual) {
			Global.dialogLayer.open(generatorStopDialogComponent)
		} else {
			Global.dialogLayer.open(generatorStartDialogComponent)
		}
	}

	VeQuickItem {
		id: _state
		uid: root.generatorUid ? root.generatorUid + "/State" : ""
	}

	VeQuickItem {
		id: _runningByConditionCode
		uid: root.generatorUid ? root.generatorUid + "/RunningByConditionCode" : ""
	}

	VeQuickItem {
		id: _gensetServiceName
		uid: root.generatorUid ? root.generatorUid + "/GensetService" : ""
	}

	VeQuickItem {
		id: _gensetInstance
		uid: root.generatorUid ? root.generatorUid + "/GensetInstance" : ""
	}

	VeQuickItem {
		id: _remoteStartMode
		uid: root.gensetUid ? root.gensetUid + "/RemoteStartModeEnabled" : ""
	}

	Component {
		id: generatorStartDialogComponent
		GeneratorStartDialog {
			generatorUid: root.generatorUid
			onAboutToHide: root._generatorStateBeforeDialogOpen = -1
		}
	}

	Component {
		id: generatorStopDialogComponent
		GeneratorStopDialog {
			generatorUid: root.generatorUid
			onAboutToHide: root._generatorStateBeforeDialogOpen = -1
		}
	}

	Component {
		id: noStartStopDialogComponent
		ModalWarningDialog {
			//% "Generator start/stop disabled"
			title: qsTrId("generator_dialog_disabled")

			//% "The remote start functionality is disabled on the genset. The GX will not be able to start or stop the genset now. Enable it on the genset control panel."
			description: qsTrId("generator_dialog_remote_start_disabled")
		}
	}
}
