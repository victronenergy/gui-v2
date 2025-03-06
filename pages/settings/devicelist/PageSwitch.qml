/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root
	property SwitchDev device
	readonly property string bindPrefix: device.serviceUid
	readonly property string bindPrefixSwitches:bindPrefix + "/SwitchableOutput"
	property int currentChannel
	title: device.name


	property Instantiator channelsModel:Instantiator{
		model: VeQItemTableModel {
			uids: bindPrefixSwitches
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: QtObject {
			property bool isDimming: functionItem.isValid && functionItem.value === VenusOS.SwitchableOutput_Function_Dimmable
			property string name: customNameItem.isValid && (customNameItem.value !== "") ? "Ch%1: %2".arg(index+1).arg(customNameItem.value) : "Channel %1".arg(index + 1)
			property string status: VenusOS.switchableOutput_statusToText(statusItem.value)
			property bool displayPercentage : isDimming && ((statusItem.value === VenusOS.SwitchableOutput_Status_On) || (statusItem.value === VenusOS.SwitchableOutput_Status_Output_Fault))
			property string combinedStatus: displayPercentage ? "%1%".arg(dimmingItem.value) : status
			//property string groupText: groupNameItem.value.length>18 ? groupNameItem.value.substring(0,15)+"...": groupNameItem.value!=="" ? groupNameItem.value : "--"

			property VeQuickItem functionItem: VeQuickItem {
				uid: model.uid + "/Settings/Type"
				property string statusText: VenusOS.switchableOutput_functionToText(value, (value === VenusOS.SwitchableOutput_Function_Slave ) ? index : null)
				onIsValidChanged:{
					if (!isValid) Global.pageManager.popAllPages()
				}
			}
			property VeQuickItem statusItem: VeQuickItem {
				uid: model.uid + "/Status"
			}

			property VeQuickItem currentItem: VeQuickItem {
				uid: model.uid + "/Current"
			}
			property VeQuickItem dimmingItem: VeQuickItem {
				uid: model.uid + "/Dimming"
			}
			property VeQuickItem customNameItem: VeQuickItem {
				uid: model.uid + "/Settings/CustomName"
				property string shortText: isValid ? value.length > 25 ? value.substring(0,25)  + "...": value : ""
			}
			property VeQuickItem fuseItem: VeQuickItem {
				uid: model.uid + "/Settings/FuseRating"

			}
			property VeQuickItem groupNameItem: VeQuickItem {
				uid: model.uid + "/Settings/Group"
				property string shortText: isValid ? value.length > 18 ? value.substring(0,15)+"...": value : "--"
			}
		}
	}

	GradientListView {
		id: switchTopLevelList
		model: ObjectModel {

			ListText {
				//% "Module state"
				text: qsTrId("settings_module_state")
				dataItem.uid: root.bindPrefix + "/State"
				secondaryText: VenusOS.switch_deviceStateToText(dataItem.value)
			}
			ListQuantity {
				//% "Module Voltage"
				text: qsTrId("settings_module_voltage")
				dataItem.uid: root.bindPrefix + "/ModuleVoltage"
				unit: VenusOS.Units_Volt_DC
				precision: 1
				valueColor: Theme.color_quantityTable_quantityValue
				unitColor: Theme.color_quantityTable_quantityUnit
			}
			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: channelsModel.count
					delegate: ListQuantityGroup {
						property QtObject info: channelsModel.objectAt(index)
						property QuantityObjectModel quantityModel: QuantityObjectModel {
							filterType: QuantityObjectModel.HasValue
							QuantityObject { object: info.currentItem; key: "value"; unit: VenusOS.Units_Amp; defaultValue: "--" }
							QuantityObject { object: info; key: "combinedStatus" }
							QuantityObject { object: info.functionItem; key: "statusText" }
						}
						property QuantityObjectModel baseQuantityModel: QuantityObjectModel {
							filterType: QuantityObjectModel.HasValue
							QuantityObject { object: info; key: "combinedStatus" }
							QuantityObject { object: info.functionItem; key: "statusText" }
						}
						text: info.name
						model: info.currentItem.isValid ? quantityModel : baseQuantityModel
					}
				}
			}
			ListNavigation {

				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage(channellist,
							{"title": text })
				}
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}


	Component {
		id: channellist

		Page {
			GradientListView {
				model: ObjectModel{
					ListTextField {
						//% "Name"
						text: qsTrId("settings_deviceinfo_name")
						dataItem.uid: root.bindPrefix + "/Settings/CustomName"
						dataItem.invalidate: false
						textField.maximumLength: 32
						preferredVisible : dataItem.isValid
						placeholderText: CommonWords.custom_name
					}

					Column {
						width: parent ? parent.width : 0
						   Repeater {
							model: channelsModel.count
							delegate: ListItem {
								id: listQuantityNavigation
								property QtObject info: channelsModel.objectAt(index)
								text: info.name
								//down: pressArea.containsPress
								enabled: userHasReadAccess
								content.children: [
									QuantityRow {
										id: quantityRow
										property QuantityObjectModel quantityModel: QuantityObjectModel {
											filterType: QuantityObjectModel.HasValue
											QuantityObject { object: info.groupNameItem; key: "shortText"; defaultValue: "--" }
											QuantityObject { object: info.functionItem; key: "statusText" }
											QuantityObject { object: info.fuseItem; key: "value"; unit: VenusOS.Units_Amp; defaultValue: "--" }
										}
										property QuantityObjectModel baseQuantityModel: QuantityObjectModel {
											filterType: QuantityObjectModel.HasValue
											QuantityObject { object: info.groupNameItem; key: "shortText"; defaultValue: "--" }
											QuantityObject { object: info.functionItem; key: "statusText" }
										}
										anchors.verticalCenter: parent.verticalCenter
										width: Math.min(implicitWidth, listQuantityNavigation.maximumContentWidth - icon.width - parent.spacing)
										model: info.fuseItem.isValid ? 	quantityModel :	baseQuantityModel
									},

									CP.ColorImage {
										id: icon

										anchors.verticalCenter: parent.verticalCenter
										source: "qrc:/images/icon_arrow_32.svg"
										rotation: 180
										color: listQuantityNavigation.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
										visible: listQuantityNavigation.enabled
									}
								]

								ListPressArea {
									id: pressArea

									radius: backgroundRect.radius
									anchors {
										fill: parent
										bottomMargin: listQuantityNavigation.spacing
									}
									onClicked:{
										root.currentChannel = index
										Global.pageManager.pushPage(channelComponent,
											{ title: text})
									}
								}
							}
						}
					}
				}
			}
		}
	}

	Component {
		id: channelComponent
		Page {
			title: device.name
			VeQuickItem {
				id: validFunctionsItem
				uid: root.bindPrefixSwitches + "/%1/Settings/ValidTypes".arg(root.currentChannel)
				property var options: null
				onValueChanged:{
					var op = [];
					for (var i=0;i<8;i++){
						if (value & (1<<i)) op.push({ display: VenusOS.switchableOutput_functionToText(i), value: i});
					}
					options = op;
				}
			}
			GradientListView {
				model: ObjectModel {
					ListTextField {
						//% "Name"
						text: qsTrId("settings_deviceinfo_name")
						dataItem.uid: root.bindPrefixSwitches + "/%1/Settings/CustomName".arg(root.currentChannel)
						dataItem.invalidate: false
						textField.maximumLength: 32
						preferredVisible : dataItem.isValid
						placeholderText: CommonWords.custom_name
					}
					ListTextField {
						//% "Group"
						text: qsTrId("settings_deviceinfo_group")
						dataItem.uid: root.bindPrefixSwitches + "/%1/Settings/Group".arg(root.currentChannel)
						dataItem.invalidate: false
						textField.maximumLength: 32
						preferredVisible : dataItem.isValid
						placeholderText: qsTrId("settings_deviceinfo_group")
					}
					ListRadioButtonGroup {
						//% "Channel Function "
						id:channelFunction
						text: qsTrId("Type")
						dataItem.uid: root.bindPrefixSwitches + "/%1/Settings/Type".arg(root.currentChannel)
						enabled: userHasWriteAccess
						preferredVisible : dataItem.isValid
						optionModel: validFunctionsItem.options
					}

					ListQuantityField{
						id:fuseListField
						text: "Fuse rating"
						enabled: userHasWriteAccess
						preferredVisible : dataItem.isValid
						unit: VenusOS.Units_Amp
						decimals: 1
						dataItem.uid: root.bindPrefixSwitches + "/%1/Settings/FuseRating".arg(root.currentChannel)

						Timer {
							id: validationTimer
							interval: 2000
							repeat: false
							onTriggered: {
								fuseListField.textField.text = Units.formatNumber(fuseListField.dataItem.value, fuseListField.decimals)
							}
						}
						validateInput: function() {
							const numberValue = Units.formattedNumberToReal(textField.text)
							if (isNaN(numberValue)) {
								return Utils.validationResult(VenusOS.InputValidation_Result_Error, CommonWords.error_nan.arg(textField.text))
							}

							// In case the user has entered a number with a greater precision than what is supported,
							// adjust the precision of the displayed number.
							const formattedNumber = Units.formatNumber(numberValue, fuseListField.decimals)
							//% "Minimum value is %1"
							if (numberValue < dataItem.min) return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Minimum value is %1".arg(dataItem.min), formattedNumber)
							//% "Maximum value is %1"
							if (numberValue > dataItem.max) return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Maximum value is %1".arg(dataItem.max), formattedNumber)
							return Utils.validationResult(VenusOS.InputValidation_Result_OK, "", formattedNumber)
						}
						saveInput: function(){
							if (dataItem.uid) {
							console.log("saveInput - ",textField.text)
							dataItem.setValue(Units.formattedNumberToReal(textField.text))
							validationTimer.start();
							}
						}
					}
				}
			}
		}
	}
}
