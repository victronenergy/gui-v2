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

			contentItem: MouseArea {

				anchors {
					top: parent.top // (you can click on the header)
					left: parent.left
					right: parent.right
					bottom: parent.footer.top // (but not the footer as it has buttons)
				}

				// Remove focus when the user clicks outside of the text fields.
				onClicked: focusScope.focus = false

				FocusScope {
					id: focusScope
					anchors.fill: parent

					readonly property Item inputItem: customDialog.visible && Qt.inputMethod.visible ?
														  (Window.activeFocusItem as TextField ??
														   Window.activeFocusItem as TextInput ??
														   // Window.activeFocusItem as TextArea ?? // not used
														   Window.activeFocusItem as TextEdit) : null

					// vkbTopPos is const - it will always be the same value when the keyboard is open;
					// - we only need this value when the keyboard is open (inputItem is not null)
					readonly property real vkbTopPos: Global.mainView.height - Qt.inputMethod.keyboardRectangle.height

					property bool componentComplete: false
					property real targetDialogY: 0

					Component.onCompleted: componentComplete = true

					onInputItemChanged: {

						if(!componentComplete || !inputItem) {

							focusScope.state = "default"
							return
						}

						focusScope.state = "interrupted"

						const currentDialogOffset = customDialog.y - customDialog.centeredY // 0 or negative
						const inputItemBottomPos = inputItem.mapToItem(Global.mainView, 0, inputItem.implicitHeight).y - currentDialogOffset

						if (inputItemBottomPos > focusScope.vkbTopPos) {

							focusScope.targetDialogY = customDialog.centeredY + (focusScope.vkbTopPos - inputItemBottomPos)
							focusScope.targetDialogY -= column.spacing

						} else {

							focusScope.targetDialogY = customDialog.centeredY
						}

						focusScope.state = "focused"
					}

					Column {
						id: column
						anchors.centerIn: parent
						spacing: 2

						Repeater {
							model: 7

							delegate: TextField {
								required property int index
								width: 400
								text: `Text field ${index}`
								objectName: text
							}
						}
					}

					state: "default"

					states: [
						State {
							name: "default"
							PropertyChanges {
								// reset to the "default" binding explicity
								// so we can get the transition
								customDialog.y: customDialog.centeredY
							}
						},
						State {
							name: "interrupted"
							// no PropertyChanges, interrupts any Transitions, does not change any properties
							// due to the restoreEntryValues of the focused state being false
						},
						State {
							name: "focused"

							PropertyChanges {
								// the object.property we want to change to the given value
								customDialog.y: focusScope.targetDialogY
								restoreEntryValues: false
							}
						}
					]

					transitions: [
						Transition {
							to: "*"
							NumberAnimation {
								target: customDialog
								property: "y"
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
