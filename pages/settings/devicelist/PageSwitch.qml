/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string serviceUid

	function switchableOutputDisplayName(output) {
		if (output.customName) {
			return "%1: %2".arg(output.name).arg(output.customName)
		} else {
			return output.name
		}
	}

	VeQItemTableModel {
		id: switchableOutputModel
		uids: [ root.serviceUid + "/SwitchableOutput" ]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	GradientListView {
		model: VisibleItemModel {
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

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: switchableOutputModel.rowCount > 0

				Repeater {
					model: switchableOutputModel
					delegate: ListQuantityGroup {
						id: outputQuantities

						required property string uid

						text: root.switchableOutputDisplayName(output)
						model: QuantityObjectModel {
							filterType: QuantityObjectModel.HasValue

							QuantityObject { object: outputCurrent; unit: VenusOS.Units_Amp }
							QuantityObject { object: output.displayPercentage ? output : null; key: "dimming"; unit: VenusOS.Units_Percentage }
							QuantityObject { object: output.displayPercentage ? null : output; key: "statusText" }
							QuantityObject { object: output; key: "typeText" }
						}

						// Do not show invalid outputs (e.g. those configured as inputs)
						preferredVisible: output.state >= 0

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
				}
			}

			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage(outputListComponent)
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "bindPrefix": root.serviceUid })
				}
			}
		}
	}

	Component {
		id: outputListComponent

		Page {
			title: CommonWords.setup

			GradientListView {
				header: SettingsColumn {
					width: parent.width
					bottomPadding: spacing

					ListTextField {
						//% "Name"
						text: qsTrId("page_switch_device_name")
						dataItem.uid: root.serviceUid + "/CustomName"
						dataItem.invalidate: false
						textField.maximumLength: 32
						preferredVisible : dataItem.valid
						placeholderText: CommonWords.custom_name
					}
				}
				model: switchableOutputModel
				delegate: ListQuantityGroupNavigation {
					id: outputQuantities

					required property string uid

					text: root.switchableOutputDisplayName(output)
					quantityModel: QuantityObjectModel {
						filterType: QuantityObjectModel.HasValue

						QuantityObject { object: output; key: "group" }
						QuantityObject { object: output; key: "typeText" }
						QuantityObject { object: outputFuseRating; unit: VenusOS.Units_Amp }
					}

					onClicked: {
						Global.pageManager.pushPage("/pages/settings/devicelist/PageSwitchableOutput.qml", {
							outputUid: output.uid,
							title: Qt.binding(function() { return root.switchableOutputDisplayName(output) })
						})
					}

					SwitchableOutput {
						id: output
						readonly property string typeText: VenusOS.switchableOutput_typeToText(type, name)
						uid: outputQuantities.uid
					}

					VeQuickItem {
						id: outputFuseRating
						uid: outputQuantities.uid + "/Settings/FuseRating"
					}
				}
			}
		}
	}
}
