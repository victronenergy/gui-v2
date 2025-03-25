/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Effects as Effects

Item {
	id: root

	height: mainItem.contentHeight
	visible: switchData._status.valid
	property int type
	property int controlBorderWidth: Theme.geometry_switchableOutput_delegate_control_border_width //2
	property color backColor: Theme.color_darkOk
	property color highLightColor: Theme.color_ok
	property color disabledColor: Theme.color_button_down
	property alias serviceUid: switchData.serviceUid
	property alias title : titleText.text
	property bool showSeparator: true

	property QtObject switchData: QtObject {
		id :switchData
		property string serviceUid
		onServiceUidChanged: {
			//console.log ("Switch Del serviceId " + serviceUid)
		}

		readonly property VeQuickItem _status: VeQuickItem {
			uid: serviceUid + "/Status"
		}

		readonly property VeQuickItem _type: VeQuickItem {
			uid: serviceUid + "/Settings/Type"
		}

		readonly property VeQuickItem _state: VeQuickItem {
			uid: serviceUid + "/State"
		}
		readonly property VeQuickItem _dimming: VeQuickItem {
			uid: serviceUid + "/Dimming"
		}
	}

	Column {
		id: mainItem
		Row {
			id:header
			height: Theme.geometry_switchableOutput_delegate_header_height
			width: root.width * Theme.geometry_switchableOutput_delegate_inner_proportionateWidth
			Label {
				anchors.bottom: statusRect.bottom
				width: statusRect.visible ? parent.width - statusRect.width : parent.width
				height: header.height - Theme.geometry_switchableOutput_delegate_header_margin * 2
				Text{
					id:titleText
					width: parent.width
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: height
					color: Theme.color_font_primary
					elide: Text.ElideMiddle
				}
			}

			Rectangle {
				id: statusRect
				visible: !((switchData._status.value === VenusOS.SwitchableOutput_Status_Off)
					|| (switchData._status.value === VenusOS.SwitchableOutput_Status_On)
					|| (switchData._status.value === VenusOS.SwitchableOutput_Status_Powered)
					|| ((switchData._status.value === VenusOS.SwitchableOutput_Status_Output_Fault) && (switchData._type.value === VenusOS.SwitchableOutput_Function_Dimmable)))
				width: childText.width < 80 ? 100 : childText.width + 20

				height: header.height - Theme.geometry_switchableOutput_delegate_header_margin * 2
				radius: height/2
				color: Global.switches.switchableOutputStatusToColor(switchData._status.value, false)
				Text {
					id: childText
					anchors.centerIn: parent
					color: Global.switches.switchableOutputStatusToColor(switchData._status.value,true)
					text: VenusOS.switchableOutput_statusToText(switchData._status.value)
				}
			}
		}
		Rectangle {
			id:border
			color: Theme.color_ok
			clip: true
			anchors{
				horizontalCenter: parent.horizontalCenter
			}
			width: parent.width * Theme.geometry_switchableOutput_delegate_inner_proportionateWidth
			height: Theme.geometry_switchableOutput_delegate_control_height
			radius: Theme.geometry_switchableOutput_delegate_control_radius

			DimmingSlider{
				id: dimmingSwitch
				grooveColor: backColor
				highlightColor: switchData._state.value ? highLightColor : disabledColor
				visible: switchData._type.valid && (switchData._type.value == 2)
				x:root.controlBorderWidth
				y:root.controlBorderWidth
				radius: parent.radius
				from: 1
				to: 100
				value: switchData._dimming.valid ? switchData._dimming.value : 0
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
					font.pixelSize: parent.height * Theme.geometry_switchableOutput_delegate_control_text_proportionateHeight
					z: border.z + 1
					anchors.centerIn: parent
				}
			}
			Rectangle{
				id: momentarySwitch
				visible: switchData._type.valid && switchData._type.value == 0
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
					font.pixelSize: parent.height * Theme.geometry_switchableOutput_delegate_control_text_proportionateHeight
					anchors.centerIn: parent
				}
			}

			Item{
				id: latchingSwitch
				visible: !switchData._type.valid || (switchData._type.valid && switchData._type.value == 1)
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
							font.pixelSize: parent.height * Theme.geometry_switchableOutput_delegate_control_text_proportionateHeight
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
							font.pixelSize: parent.height * Theme.geometry_switchableOutput_delegate_control_text_proportionateHeight
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
		Item {
			visible: showSeparator
			height: showSeparator ? 14 : 0
			width: parent.width
		}
		Rectangle {
			visible: showSeparator
			height: showSeparator ? 2 : 0
			anchors{
				horizontalCenter: parent.horizontalCenter
			}
			width: parent.width
			color: Theme.color_card_separator
		}
	}

}
