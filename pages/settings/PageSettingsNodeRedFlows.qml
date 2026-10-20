/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// The requested enabled state per flow id, until Flows/List shows it. venus-platform
	// applies a change asynchronously, as it restarts Node-RED when it is running.
	property var pendingChanges: ({})

	readonly property bool nodeRedRunning: nodeRedMode.valid && nodeRedMode.value !== VenusOS.NodeRed_Mode_Disabled

	function flowEnabled(flowId) {
		const flows = flowsView.model ?? []
		for (let i = 0; i < flows.length; ++i) {
			if (flows[i].id === flowId) {
				return flows[i].enabled === true
			}
		}
		return undefined
	}

	function setFlowEnabled(flowId, enable) {
		// The flow might have changed or disappeared while the confirmation was open.
		if (flowEnabled(flowId) !== !enable) {
			return
		}

		let request = {}
		request[flowId] = enable
		setFlowsEnabled.setValue(JSON.stringify(request))

		let temp = Object.assign({}, pendingChanges)
		temp[flowId] = enable
		pendingChanges = temp
		pendingTimeout.restart()
	}

	function updatePendingChanges() {
		let temp = {}
		for (const flowId in pendingChanges) {
			const enabled = flowEnabled(flowId)
			if (enabled !== undefined && enabled !== pendingChanges[flowId]) {
				temp[flowId] = pendingChanges[flowId]
			}
		}
		pendingChanges = temp
		if (Object.keys(temp).length === 0) {
			pendingTimeout.stop()
		}
	}

	// Value is a JSON string. For example:
	// '[{"enabled":true,"id":"de710832a415f877","label":"Flow 1"}]'
	VeQuickItem {
		id: flowList
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Flows/List"
		onValueChanged: {
			if (!valid) {
				flowsView.model = []
				return
			}
			let model = []
			try {
				model = JSON.parse(value)
			} catch (e) {
				console.warn(uid, ": unable to parse JSON:", value, "exception:", e)
				model = []
			}
			flowsView.model = model
			root.updatePendingChanges()
		}
	}

	VeQuickItem {
		id: setFlowsEnabled
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Flows/SetEnabled"
	}

	VeQuickItem {
		id: nodeRedMode
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Mode"
	}

	// Stopping Node-RED can take up to 30 seconds before venus-platform gives up, then it
	// has to start again.
	Timer {
		id: pendingTimeout
		interval: 45000
		onTriggered: {
			root.pendingChanges = {}
			//% "The Node-RED flows could not be changed."
			Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("settings_nodered_flows_change_failed"))
		}
	}

	GradientListView {
		id: flowsView

		header: SettingsColumn {
			width: parent?.width ?? 0

			PrimaryListLabel {
				//% "No Node-RED flows found."
				text: qsTrId("settings_nodered_flows_none")
				visible: flowsView.count === 0
			}

			PrimaryListLabel {
				//% "Enabling or disabling a flow restarts Node-RED. All flows are briefly interrupted."
				text: qsTrId("settings_nodered_flows_restart_description")
				visible: flowsView.count > 0 && root.nodeRedRunning
				font.pixelSize: Theme.font_size_caption
			}
		}

		delegate: ListSwitch {
			required property var modelData
			readonly property bool pending: root.pendingChanges[modelData["id"]] !== undefined

			text: modelData["label"] ?? ""
			checked: pending ? root.pendingChanges[modelData["id"]] : modelData["enabled"] === true
			//% "Applying..."
			secondaryText: pending ? qsTrId("settings_nodered_flows_applying") : ""
			interactive: !pending
			onClicked: {
				if (root.nodeRedRunning) {
					Global.dialogLayer.open(confirmationDialogComponent, {
						flowId: modelData["id"],
						flowLabel: text,
						enable: !checked
					})
				} else {
					// Nothing is interrupted, venus-platform only updates the flows file.
					root.setFlowEnabled(modelData["id"], !checked)
				}
			}
		}
	}

	Component {
		id: confirmationDialogComponent

		ModalWarningDialog {
			required property string flowId
			required property string flowLabel
			required property bool enable

			title: enable
				   //% "Enable %1?"
				   ? qsTrId("settings_nodered_flows_enable_title").arg(flowLabel)
				   //% "Disable %1?"
				   : qsTrId("settings_nodered_flows_disable_title").arg(flowLabel)
			//% "Node-RED will restart. All flows are briefly interrupted."
			description: qsTrId("settings_nodered_flows_restart_confirmation")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			onAccepted: root.setFlowEnabled(flowId, enable)
		}
	}
}
