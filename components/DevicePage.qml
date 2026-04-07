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
				//: Settings page for switchable outputs
				//% "Outputs"
				text: qsTrId("device_page_outputs")
				preferredVisible: switchableOutputModel.count > 0
				onClicked: {
					Global.pageManager.pushPage(switchableOutputPageComponent, { title: text })
				}

				IOChannelProxyModel {
					id: switchableOutputModel
					sourceModel: VeQItemTableModel {
						uids: [ root.serviceUid + "/SwitchableOutput" ]
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
				//% "Inputs"
				text: qsTrId("device_page_inputs")
				preferredVisible: genericInputModel.count > 0
				onClicked: {
					Global.pageManager.pushPage(genericInputPageComponent, { title: text })
				}

				IOChannelProxyModel {
					id: genericInputModel
					sourceModel: VeQItemTableModel {
						uids: [ root.serviceUid + "/GenericInput" ]
						flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
					}
				}

				Component {
					id: genericInputPageComponent
					Page {
						GradientListView {
							model: genericInputModel
							delegate: GenericInputListDelegate {}
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

			SettingsColumn {
				id: guiPluginIntegrationsColumn
				width: parent ? parent.width : 0
				preferredVisible: root.device.productId > 0 && integrationsModel.count

				Repeater {
					model: GuiPluginIntegrationModel {
						id: integrationsModel
						type: GuiPluginLoader.DeviceListSettingsPage
						productId: root.device.productId > 0 ? Utils.toHexFormat(root.device.productId) : ""
					}
					delegate: SettingsListNavigation {
						required property string pluginName
						required property color pluginColor
						required property string url
						required property string title
						text: qsTrId(title)
						indicatorColor: pluginColor
						pageSource: url
						pageProperties: ({"device": root.device})
					}
				}
			}
		}
	}
}
