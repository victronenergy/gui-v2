/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Effects as Effects

Item {
	property int controlBorderWidth: 2
	property color backColor: Theme.color_darkOk
	property color highLightColor: Theme.color_ok
	property color disabledColor: Theme.color_button_down
	property alias serviceUid: switchData.serviceUid
	property alias title : titleText.text


	property QtObject switchData: QtObject {
		id :switchData
		property string serviceUid
		onServiceUidChanged: {
			//console.log ("Switch Del serviceId " + serviceUid)
		}

		readonly property VeQuickItem _status: VeQuickItem {
			uid: serviceUid + "/Status"
		}
		readonly property VeQuickItem _customName: VeQuickItem {
			uid: serviceUid + "/CustomName"
			property bool valueValid: isValid &&  value!==""
		}
		readonly property VeQuickItem _function: VeQuickItem {
			uid: serviceUid + "/Function"
		}

		readonly property VeQuickItem _state: VeQuickItem {
			uid: serviceUid + "/State"
		}
		readonly property VeQuickItem _dimming: VeQuickItem {
			uid: serviceUid + "/Dimming"
		}
	}

	id: root
	height: 90
	visible: switchData._status.isValid
	Column {
		Row {
			id:header
			height: 30
			width: root.width
			Item {
				width: parent.width - statusRect.width
				height: titleText.contentHeight
				Text{
					id:titleText
					verticalAlignment: Text.AlignTop
					font.pixelSize: height
					color: Theme.color_font_primary
					elide: Text.ElideRight
				}
			}

			Rectangle {
				id: statusRect
				visible: !((switchData._status.value === VenusOS.Switch_Status_Off)
					|| (switchData._status.value === VenusOS.Switch_Status_On)
					|| (switchData._status.value === VenusOS.Switch_Status_Input_Active)
					|| ((switchData._status.value === VenusOS.Switch_Status_Active) && (switchData._function.value === VenusOS.Switch_Function_Dimmable)))
				width: 100
				height: 25
				radius: height/2
				color: Global.switches.switchStatusToColor(switchData._status.value)
				Text {
					anchors.centerIn: parent
					color: Qt.colorEqual(statusRect.color,"WHITE") ? "BLACK": "WHITE"
					text: Global.switches.switchStatusToText(switchData._status.value)
				}
			}
		}
		Rectangle {
			id:border
			color: Theme.color_ok
			clip: true
			anchors{
				//top:header.bottom
				horizontalCenter: parent.horizontalCenter
			}
			width: parent.width * 0.9
			height:50
			radius: 18

			DimmingSlider{
				id: dimmingSwitch
				grooveColor: backColor
				highlightColor: switchData._state.value ? highLightColor : disabledColor
				visible: switchData._function.isValid && (switchData._function.value == 2)
				x:root.controlBorderWidth
				y:root.controlBorderWidth
				radius: parent.radius
				from: 1
				to: 100
				value: switchData._dimming.isValid ? switchData._dimming.value : 0
				width: parent.width - root.controlBorderWidth * 2
				height: parent.height - root.controlBorderWidth * 2
				buttonClickedEnabled: true
				onPositionChanged:{
					var newVal = Math.round(value)
					if (newVal !== switchData._dimming.value) switchData._dimming.setValue(value)
				}

				onButtonClicked: {
					if (switchData._state.value) switchData._state.setValue(0)
						else switchData._state.setValue(1)
				}
				Text {
					id: dimText
					color: Theme.color_font_primary
					text: switchData._state.value ? CommonWords.on : CommonWords.off
					font.pixelSize: parent.height * 0.6
					z: border.z + 1
					anchors.centerIn: parent
				}
			}
			Rectangle{
				id: momentarySwitch
				visible: switchData._function.isValid && switchData._function.value == 0
				x:root.controlBorderWidth
				y:root.controlBorderWidth
				radius: parent.radius
				color: switchData._state.value ? highLightColor :backColor
				width: parent.width - root.controlBorderWidth * 2
				height: parent.height - root.controlBorderWidth * 2

				PressArea {
					anchors.fill:  parent
					color: switchData._state.value ? highLightColor :backColor
					radius: parent.radius
					onPressed: switchData._state.setValue(1)
					onReleased: switchData._state.setValue(0)
				}
				Text {
					id: momentaryText
					color: Theme.color_font_primary
					//% "Press"
					text: switchData._state.value ? CommonWords.on : qsTrId("Switches_Press")
					font.pixelSize: parent.height * 0.6
					anchors.centerIn: parent
				}
			}

			Item{
				id: latchingSwitch
				visible: !switchData._function.isValid || (switchData._function.isValid && switchData._function.value == 1)
				x:root.controlBorderWidth
				y:root.controlBorderWidth
				width: parent.width - root.controlBorderWidth * 2
				height: parent.height - root.controlBorderWidth * 2
				PressArea {
					id:pressAreaOff
					x: 0
					y: 0
					width:parent. width / 2
					height:parent.height
					radius: border.radius
					color: !switchData._state.value ? highLightColor :backColor
					onClicked: switchData._state.setValue(0)
				}
				PressArea {
					id: pressAreaOn
					x: parent.width / 2
					y: 0
					width:parent. width/2
					height:parent.height
					radius: border.radius
					color: switchData._state.value ? highLightColor :backColor
					onClicked: switchData._state.setValue(1)
				}
				Rectangle{
					id:maskRect
					anchors.fill:parent
					layer.enabled: true
					visible: false
					color: "black"
					radius: border.radius
				}
				Item {
					id:sourceItem
					visible: false
					anchors.fill:parent
					Rectangle {
						x: 0
						y: 0
						width:parent. width / 2
						height:parent.height
						color: !switchData._state.value ? highLightColor :backColor

						Text {
							id: offText
							color: Theme.color_font_primary
							text: CommonWords.off
							font.pixelSize: parent.height * 0.6
							anchors.centerIn: parent
						}
					}

					Rectangle {
						x: parent.width / 2
						y: 0
						width:parent. width/2
						height:parent.height
						color:  switchData._state.value ? highLightColor :backColor
						Text {
							id: onText
							color: Theme.color_font_primary
							text: CommonWords.on
							font.pixelSize: parent.height * 0.6
							anchors.centerIn: parent
						}
					}
				}
				Effects.MultiEffect {
					visible: true
					anchors.fill: parent
					maskEnabled: true
					maskSource: maskRect
					source: sourceItem
				}
			}
		}
	}
}
