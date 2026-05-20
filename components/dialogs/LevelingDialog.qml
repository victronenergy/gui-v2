/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	//% "Leveling"
	title: qsTrId("leveling_title")
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly

	readonly property real _roll: Global.leveling ? Global.leveling.roll : NaN
	readonly property real _pitch: Global.leveling ? Global.leveling.pitch : NaN
	readonly property bool _isRollLevel: !isNaN(_roll) && Math.abs(_roll) <= 2.0
	readonly property bool _isPitchLevel: !isNaN(_pitch) && Math.abs(_pitch) <= 2.0
	readonly property bool _isLight: Theme.colorScheme === Theme.Light
	readonly property string _svgSuffix: _isLight ? "_light.svg" : ".svg"

	VeQuickItem {
		id: setRefItem
		uid: (Global.leveling?.serviceUid ?? "") + "/Orientation/SetRef"
	}

	Component {
		id: calibrationDialogComponent
		ModalWarningDialog {
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			//% "Set level reference"
			title: qsTrId("leveling_set_reference_title")
			//% "Use the current orientation as the level reference?"
			description: qsTrId("leveling_set_reference_description")
			onAccepted: setRefItem.setValue(1)
		}
	}

	contentItem: Item {
		Column {
			anchors.centerIn: parent
			spacing: Theme.geometry_modalDialog_content_spacing / 2

			Row {
				anchors.horizontalCenter: parent.horizontalCenter
				spacing: Theme.geometry_modalDialog_content_spacing

				Rectangle {
					width: 6
					height: 6
					radius: 3
					color: Theme.color_font_primary
					anchors.verticalCenter: parent.verticalCenter
				}

				Item {
					width: 160
					height: 160
					anchors.verticalCenter: parent.verticalCenter

					Item {
						anchors.fill: parent
						rotation: isNaN(root._roll) ? 0 : root._roll

						Image {
							anchors.fill: parent
							fillMode: Image.PreserveAspectFit
							source: root._isRollLevel
								? "qrc:/images/icon_leveling_roll_level" + root._svgSuffix
								: "qrc:/images/icon_leveling_roll_tilted" + root._svgSuffix
						}

						Label {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.top: parent.top
							anchors.topMargin: 24
							font.pixelSize: Theme.font_size_body1
							text: isNaN(root._roll) ? "--" : root._roll.toFixed(0) + "°"
						}

						Label {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 24
							font.pixelSize: Theme.font_size_body1
							//% "Roll"
							text: qsTrId("leveling_roll_axis_label")
						}
					}
				}

				Rectangle {
					width: 6
					height: 6
					radius: 3
					color: Theme.color_font_primary
					anchors.verticalCenter: parent.verticalCenter
				}

				Image {
					width: 42
					height: 42
					anchors.verticalCenter: parent.verticalCenter
					fillMode: Image.PreserveAspectFit
					source: (root._isRollLevel && root._isPitchLevel)
						? "qrc:/images/icon_leveling_ok" + root._svgSuffix
						: "qrc:/images/icon_leveling_warning" + root._svgSuffix
				}

				Rectangle {
					width: 6
					height: 6
					radius: 3
					color: Theme.color_font_primary
					anchors.verticalCenter: parent.verticalCenter
				}

				Item {
					width: 160
					height: 160
					anchors.verticalCenter: parent.verticalCenter

					Item {
						anchors.fill: parent
						// D-Bus pitch convention is inverted (positive = nose down)
						rotation: isNaN(root._pitch) ? 0 : -root._pitch

						Image {
							anchors.fill: parent
							fillMode: Image.PreserveAspectFit
							source: root._isPitchLevel
								? "qrc:/images/icon_leveling_pitch_level" + root._svgSuffix
								: "qrc:/images/icon_leveling_pitch_tilted" + root._svgSuffix
						}

						Label {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.top: parent.top
							anchors.topMargin: 24
							font.pixelSize: Theme.font_size_body1
							text: isNaN(root._pitch) ? "--" : root._pitch.toFixed(0) + "°"
						}

						Label {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.bottom: parent.bottom
							anchors.bottomMargin: 24
							font.pixelSize: Theme.font_size_body1
							//% "Pitch"
							text: qsTrId("leveling_pitch_axis_label")
						}
					}
				}

				Rectangle {
					width: 6
					height: 6
					radius: 3
					color: Theme.color_font_primary
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			ListItemButton {
				anchors.horizontalCenter: parent.horizontalCenter
				//% "Calibrate"
				text: qsTrId("leveling_calibrate_button")
				onClicked: Global.dialogLayer.open(calibrationDialogComponent)
			}
		}
	}
}
