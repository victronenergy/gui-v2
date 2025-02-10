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
	property int currentChannel
	title: device.name


	property Instantiator channelsModel:Instantiator{
		model: VeQItemTableModel {
			uids:  bindPrefix + "/Channel"
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: QtObject {
			property bool isDimming: functionItem.isValid && functionItem.value === VenusOS.Switch_Function_Dimmable
			property string name: customNameItem.isValid && (customNameItem.value !== "") ? "Ch%1: %2".arg(index+1).arg(customNameItem.value) : "Channel %1".arg(index + 1)
			property string status: Global.switches.switchStatusToText(statusItem.value)
			property bool displayPercentage : isDimming && ((statusItem.value === VenusOS.Switch_Status_On) || (statusItem.value === VenusOS.Switch_Status_Active))
			property string combinedStatus: displayPercentage ? "%1%".arg(dimmingItem.value) : status
			//property string groupText: groupNameItem.value.length>18 ? groupNameItem.value.substring(0,15)+"...": groupNameItem.value!=="" ? groupNameItem.value : "--"

			property VeQuickItem functionItem: VeQuickItem {
				uid: model.uid + "/Function"
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
				uid: model.uid + "/CustomName"
				property string shortText: isValid ? value.length > 25 ? value.substring(0,25)  + "...": value : ""
			}
			property VeQuickItem fuseItem: VeQuickItem {
				uid: model.uid + "/FuseRating"

			}
			property VeQuickItem groupNameItem: VeQuickItem {
				uid: model.uid + "/GroupName"
				property string shortText: isValid ? value.length > 18 ? value.substring(0,15)+"...": value : "--"
			}
		}
	}

	GradientListView {
		id: switchTopLevelList
		model: ObjectModel {

			ListText {
				text: CommonWords.state
				dataItem.uid: root.bindPrefix + "/State"
				secondaryText: Global.switches.switchStatusToText(dataItem.value)
			}
			Column {
				width: parent ? parent.width : 0

				VeQuickItem {
					id: nrOfOutputs
					uid: root.bindPrefix + "/NrOfChannels"
				}

				Repeater {
					model: channelsModel.count
					delegate: ListQuantityGroup {
						property QtObject info: channelsModel.objectAt(index)
						text: info.name
						textModel:info.currentItem.isValid
								   ?[
										{ value: info.currentItem.value, unit: VenusOS.Units_Amp },
										{ value: info.combinedStatus},
										{ value: Global.switches.switchFunctionToText(info.functionItem.value)},
									]
									:[
										{ value: info.combinedStatus},
										{ value: Global.switches.switchFunctionToText(info.functionItem.value)},
									]

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
						dataItem.uid: root.bindPrefix + "/CustomName"
						dataItem.invalidate: false
						textField.maximumLength: 32
						allowed: dataItem.isValid
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
								down: pressArea.containsPress
								enabled: userHasReadAccess
								content.children: [
									QuantityRow {
										id: quantityRow
										anchors.verticalCenter: parent.verticalCenter
										width: Math.min(implicitWidth, listQuantityNavigation.maximumContentWidth - icon.width - parent.spacing)
										model: info.fuseItem.isValid ? [
											{ value: info.groupNameItem.shortText},
											{ value: Global.switches.switchFunctionToText(info.functionItem.value)},
											{ value: info.fuseItem.value, unit: VenusOS.Units_Amp }
										]
										:[
											{ value: info.groupNameItem.shortText},
											{ value: Global.switches.switchFunctionToText(info.functionItem.value)},
										]

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
				uid: root.bindPrefix + "/Channel/%1/ValidFunctions".arg(root.currentChannel)
				property var options: null
				onValueChanged:{
					var op = [];
					for (var i=0;i<8;i++){
						if (value & (1<<i)) op.push({ display: Global.switches.switchFunctionToText(i), value: i});
					}
					options = op;
				}
			}
			GradientListView {
				model: ObjectModel {
					ListTextField {
						//% "Name"
						text: qsTrId("settings_deviceinfo_name")
						dataItem.uid: root.bindPrefix + "/Channel/%1/CustomName".arg(root.currentChannel)
						dataItem.invalidate: false
						textField.maximumLength: 32
						allowed: dataItem.isValid
						placeholderText: CommonWords.custom_name
					}
					ListTextField {
						//% "Group"
						text: qsTrId("settings_deviceinfo_group")
						dataItem.uid: root.bindPrefix + "/Channel/%1/GroupName".arg(root.currentChannel)
						dataItem.invalidate: false
						textField.maximumLength: 32
						allowed: dataItem.isValid
						placeholderText: "Group name" // CommonWords.group_name
					}
					ListRadioButtonGroup {
						//% "Channel Function "
						id:channelFunction
						text: qsTrId("Function")
						dataItem.uid: root.bindPrefix + "/Channel/%1/Function".arg(root.currentChannel)
						enabled: userHasWriteAccess
						allowed: defaultAllowed && dataItem.isValid
						optionModel: validFunctionsItem.options
					}

					ListQuantityField{
						id:fuseListField
						text: "Fuse rating"
						enabled: userHasWriteAccess
						allowed: dataItem.isValid
						unit: VenusOS.Units_Amp
						decimals: 1
						dataItem.uid: root.bindPrefix + "/Channel/%1/FuseRating".arg(root.currentChannel)

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
