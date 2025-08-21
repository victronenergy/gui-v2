/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A page that shows a list of settings items for a Device.
*/
Page {
	id: root

	// The uid of the service that provides the device information.
	required property string serviceUid

	// The Device object used to fetch device metadata.
	readonly property alias device: _device

	// Customizations for the settings list.
	property alias settingsHeader: settingsListView.header
	property alias settingsModel: settingsListView.model
	property alias settingsDelegate: settingsListView.delegate

	// True if a "Switches" item should be shown in the footer (if /SwitchableOutput entries are
	// present on the service).
	property bool showSwitches: true

	// Additional settings to be loaded by PageDeviceInfo.
	property Component extraDeviceInfo

	title: _device.name

	Device {
		id: _device
		serviceUid: root.serviceUid
	}

	GradientListView {
		id: settingsListView

		footer: SettingsColumn {
			width: parent?.width ?? 0
			topPadding: ListView.view.count > 0 ? spacing : 0

			ListNavigation {
				//% "Switches"
				text: qsTrId("device_page_switches")
				preferredVisible: root.showSwitches && switchableOutputModel.count > 0
				onClicked: {
					Global.pageManager.pushPage(switchableOutputPageComponent, { title: text })
				}

				SwitchableOutputModel {
					id: switchableOutputModel
					sourceModel: VeQItemTableModel {
						uids: root.showSwitches ? [ root.serviceUid + "/SwitchableOutput" ] : []
						flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
					}
				}

				Component {
					id: switchableOutputPageComponent
					Page {
						GradientListView {
							model: switchableOutputModel
							delegate: SwitchableOutputListDelegate {}
						}
					}
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml", {
						serviceUid: root.serviceUid,
						extraDeviceInfo: root.extraDeviceInfo
					})
				}
			}
		}
	}
}
