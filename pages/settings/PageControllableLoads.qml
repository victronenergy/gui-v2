/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: mode

		uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
	}

	GradientListView {
		id: gradientListView

		header: SettingsColumn {
			width: parent?.width ?? 0

			ListSwitch {
				dataItem.uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
				text: CommonWords.enabled
				interactive: dEssModeItem.value === 0
				//% "Opportunity loads cannot be enabled while Dynamic ESS is running. Disable Dynamic ESS first."
				caption: interactive ? "" : qsTrId("pagecontrollableloads_disable_dess_first")

				VeQuickItem {
					id: dEssModeItem
					uid: Global.systemSettings.serviceUid + "/Settings/DynamicEss/Mode"
				}
			}

			SettingsListHeader {
				text: mode.value && loads.valid ?
						  //% "Devices and Priorities"
						  qsTrId("pagecontrollableloads_devices_and_priorities") :
						  //% "Starting, this may take a few seconds..."
						  qsTrId("pagecontrollableloads_starting")
				visible: mode.value
			}
		}

		model: mode.value && loads.valid ? opportunityLoadsModel : []
		delegate: ListDevicePriority {
			leftInset: Theme.geometry_page_content_horizontalMargin + Theme.geometry_priorityLabel_width
			leftPadding: leftInset + Theme.geometry_opportunityLoad_margin
		}

		Column {	// The priority numbers on the LHS should remain stationary, unlike the device delegates
					// which animate up & down by clicking the up & down arrows.
			y: -gradientListView.contentY
			leftPadding: Theme.geometry_page_content_horizontalMargin
			spacing: Theme.geometry_gradientList_spacing

			Repeater {
				model: gradientListView.count
				delegate: Label {
					width: Theme.geometry_priorityLabel_width
					height: Theme.geometry_listItem_height
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					text: index + 1
					color: Theme.color_font_disabled
					font.pixelSize: Theme.font_listItem_caption_size
				}
			}
		}

		move: Transition {
			enabled: Global.animationEnabled
			NumberAnimation {
				duration: Theme.animation_devicePriorityDelegateMove_duration
				properties: "x,y"
				easing.type: Easing.InOutQuad
			}
		}
		displaced: Transition {
			enabled: Global.animationEnabled
			NumberAnimation {
				duration: Theme.animation_devicePriorityDelegateMove_duration
				properties: "x,y"
				easing.type: Easing.InOutQuad
			}
		}

		footer: SettingsColumn {
			width: parent?.width ?? 0

			PrimaryListLabel {
				//% "Devices will be controlled in order, based on available solar surplus."
				text: qsTrId("pagecontrollableloads_controlled_in_order_based_on_available_solar_surplus")
				preferredVisible: mode.value
			}

			ListNavigation {
				//% "Preferences"
				text: qsTrId("pagecontrollableloads_preferences")
				preferredVisible: mode.value && loads.valid
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageControllableLoadsPreferences.qml", { title: text })
				}
			}

			ListLink {
				id: documentation

				//% "Documentation"
				text: qsTrId("pagecontrollableloads_documentation")
				url: "http://ve4.nl/ol"
			}
		}
	}

	ListModel {
		id: opportunityLoadsModel

		function writeToBackEnd() {
			let newValue = []

			for (let i = 0; i < opportunityLoadsModel.count; ++i) {
				newValue.push(opportunityLoadsModel.get(i))
			}
			loads.setValue(JSON.stringify(newValue))
		}
	}

	VeQuickItem {
		id: loads

		uid: BackendConnection.serviceUidForType("opportunityloads") + "/AvailableServices"
		invalidate: true
		onValueChanged: {
			if (value === undefined || value === null || value === "") {
				return
			}

			let jsv
			try {
				jsv = (typeof value === "string") ? JSON.parse(value) : value
			} catch (e) {
				console.warn("AvailableServices JSON parse failed:", e, "value:", value)
				return
			}

			if (!Array.isArray(jsv)) {
				console.warn("AvailableServices is not an array:", jsv)
				return
			}

			for (let i = 0; i < jsv.length; ++i) {
				const newValue = jsv[i]
				const oldValue = (i < opportunityLoadsModel.count) ? opportunityLoadsModel.get(i) : null

				const changed =  !oldValue
							  || oldValue.uniqueIdentifier !== newValue.uniqueIdentifier
							  || oldValue.deviceInstance !== newValue.deviceInstance
							  || oldValue.serviceType !== newValue.serviceType
							  || oldValue.controllable !== newValue.controllable

				if (changed) {
					opportunityLoadsModel.set(i, newValue)
				}
			}

			if (opportunityLoadsModel.count > jsv.length) {
				opportunityLoadsModel.remove(jsv.length, opportunityLoadsModel.count - jsv.length)
			}
		}
	}
}
