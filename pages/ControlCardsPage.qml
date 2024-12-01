/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Page {
	id: root

	property int cardWidth: cardsView.count > 2
			? Theme.geometry_controlCard_minimumWidth
			: Theme.geometry_controlCard_maximumWidth

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive
	width: parent.width
	anchors {
		top: parent.top
		bottom: parent.bottom
		bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
	}

	Component {
		id: customDialogComponent

		ModalDialog {
			id: customDialog

			property real dialogYDelta

			contentItem: MouseArea {
				anchors {
					top: parent.top
					left: parent.left
					right: parent.right
					bottom: parent.footer.top
				}

				// Remove focus when the user clicks outside of the text fields.
				onClicked: focusScope.focus = false

				FocusScope {
					id: focusScope
					anchors.fill: parent

					Column {
						anchors.centerIn: parent
						spacing: 2

						Repeater {
							model: 5

							delegate: TextField {
								id: dialogTextField
								width: 400
								text: "Text field " + (model.index)

								// When the text field receives active focus, slide the dialog
								// upwards if necessary, to ensure the focused field is not hidden
								// beneath the VKB.
								// When the text field loses active focus, restore the original
								// dialog position.
								onActiveFocusChanged: {
									if (activeFocus) {
										const textFieldBottomPos = dialogTextField.mapToItem(Global.mainView, 0, implicitHeight).y
										const vkbTopPos = Global.mainView.height - Qt.inputMethod.keyboardRectangle.height
										if (textFieldBottomPos > vkbTopPos) {
											// Need to move the dialog upwards to see the whole text field
											customDialog.dialogYDelta = vkbTopPos - textFieldBottomPos
										} else {
											// Text field is already visible, no need to move the dialog upwards
											customDialog.dialogYDelta = 0
										}
									}
									focusScope.state = activeFocus ? "focused" : ""
								}
							}
						}
					}

					states: [
						State {
							name: "focused"
							PropertyChanges {
								target: customDialog
								y: customDialog.centeredY + customDialog.dialogYDelta
								explicit: true
							}
						}
					]

					transitions: [
						Transition {
							NumberAnimation {
								target: customDialog
								properties: "y"
								duration: Theme.animation_inputPanel_slide_duration
								easing.type: Easing.InOutQuad
							}
						}
					]

				}
			}
		}
	}

	ListView {
		id: cardsView

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		boundsBehavior: Flickable.StopAtBounds
		maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
		flickDeceleration: Theme.geometry_flickable_flickDeceleration

		model: ObjectModel {
			Rectangle {
				width: root.cardWidth
				height: cardsView.height
				color: "transparent"
				border.color: "orange"

				ListItemButton {
					anchors.centerIn: parent
					text: "Open dialog"
					onClicked: Global.dialogLayer.open(customDialogComponent, {})
				}
			}

			Loader {
				active: systemType.value === "ESS" || systemType.value === "Hub-4"
				width: active ? root.cardWidth : -cardsView.spacing
				sourceComponent: ESSCard {
					width: root.cardWidth
					height: cardsView.height
				}

				VeQuickItem {
					id: systemType
					uid: Global.system.serviceUid + "/SystemType"
				}
			}

			Row {
				height: cardsView.height
				spacing: Theme.geometry_controlCardsPage_spacing

				Repeater {
					model: Global.evChargers.model

					EVCSCard {
						width: root.cardWidth
						evCharger: model.device
					}
				}
			}

			Row {
				height: cardsView.height
				spacing: Theme.geometry_controlCardsPage_spacing

				Repeater {
					model: Global.generators.model

					GeneratorCard {
						width: root.cardWidth
						generator: model.device
					}
				}
			}

			Row {
				height: cardsView.height
				spacing: Theme.geometry_controlCardsPage_spacing

				Repeater {
					model: Global.inverterChargers.veBusDevices

					InverterChargerCard {
						width: root.cardWidth
						serviceUid: model.device.serviceUid
						name: model.device.name
					}
				}

				Repeater {
					model: Global.inverterChargers.acSystemDevices

					InverterChargerCard {
						width: root.cardWidth
						serviceUid: model.device.serviceUid
						name: model.device.name
					}
				}

				Repeater {
					model: Global.inverterChargers.inverterDevices

					InverterChargerCard {
						width: root.cardWidth
						serviceUid: model.device.serviceUid
						name: model.device.name
					}
				}
			}

			Loader {
				active: manualRelays.count > 0
				width: active ? root.cardWidth : -cardsView.spacing
				sourceComponent: SwitchesCard {
					width: root.cardWidth
					height: cardsView.height
					model: manualRelays
				}

				ManualRelayModel { id: manualRelays }
			}
		}
	}
}
