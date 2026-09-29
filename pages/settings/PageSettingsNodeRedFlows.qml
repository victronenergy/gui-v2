/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

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
		}
	}

	VeQuickItem {
		id: setFlowsEnabled
		uid: Global.venusPlatform.serviceUid + "/Services/NodeRed/Flows/SetEnabled"
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
				visible: flowsView.count > 0
				font.pixelSize: Theme.font_size_caption
			}
		}

		delegate: ListSwitch {
			required property var modelData

			text: modelData["label"] ?? ""
			checked: modelData["enabled"] === true
			onClicked: Global.dialogLayer.open(confirmationDialogComponent, {
				flowId: modelData["id"],
				flowLabel: text,
				enable: !checked
			})
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
			onAccepted: {
				let request = {}
				request[flowId] = enable
				setFlowsEnabled.setValue(JSON.stringify(request))
			}
		}
	}
}
