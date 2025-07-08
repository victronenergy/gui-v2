/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string serviceUid
	required property SwitchableOutputModel switchableOutputModel

	GradientListView {
		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: spacing

			ListText {
				//% "Module state"
				text: qsTrId("settings_module_state")
				dataItem.uid: root.serviceUid + "/State"
				secondaryText: VenusOS.switch_deviceStateToText(dataItem.value)
			}

			ListQuantity {
				//% "Module Voltage"
				text: qsTrId("settings_module_voltage")
				dataItem.uid: root.serviceUid + "/ModuleVoltage"
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Volt_DC
				precision: 1
			}
		}

		model: root.switchableOutputModel

		delegate: ListQuantityGroupNavigation {
			id: outputQuantities

			required property string uid
			required property string name

			text: name
			quantityModel: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: outputCurrent; unit: VenusOS.Units_Amp }
				QuantityObject { object: output.displayPercentage ? output : null; key: "dimming"; unit: VenusOS.Units_Percentage }
				QuantityObject { object: output.displayPercentage ? null : output; key: "statusText" }
				QuantityObject { object: output; key: "typeText" }
			}

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitchableOutput.qml", {
					outputUid: output.uid,
					title: Qt.binding(function() { return outputQuantities.text })
				})
			}

			SwitchableOutput {
				id: output

				readonly property bool displayPercentage: type === VenusOS.SwitchableOutput_Type_Dimmable
						&& ((status === VenusOS.SwitchableOutput_Status_On)
							|| (status === VenusOS.SwitchableOutput_Status_Output_Fault))
				readonly property string statusText: VenusOS.switchableOutput_statusToText(status)
				readonly property string typeText: VenusOS.switchableOutput_typeToText(type, name)

				uid: outputQuantities.uid
			}

			VeQuickItem {
				id: outputCurrent
				uid: outputQuantities.uid + "/Current"
			}
		}

		footer: SettingsColumn {
			width: parent?.width ?? 0
			topPadding: ListView.view.count > 0 ? spacing : 0

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "bindPrefix": root.serviceUid })
				}
			}
		}
	}
}
