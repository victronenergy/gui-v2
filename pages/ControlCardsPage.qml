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

			property real value
			property string suffix: "V"
			property int decimals: 2

			property real from: 0
			property real to: 64
			property real stepSize: 0.5

			signal maxValueReached()
			signal minValueReached()

			onValueChanged: console.log("SpinBox real Value", value)

			function _multiplier() {
				return Math.pow(10, decimals)
			}

			contentItem: Item {
				anchors {
					top: parent.top // (you can click on the header)
					left: parent.left
					right: parent.right
					bottom: parent.footer.top // (but not the footer as it has buttons)

				}
				Column {
					anchors.centerIn: parent
					width: parent.width

					spacing: 2

					Repeater {
						model: 3

						delegate: TextField {
							required property int index
							width: 400
							text: `Text field ${index}`
							objectName: text
							anchors.horizontalCenter: parent.horizontalCenter
						}
					}

					SpinBox {
						id: spinBox

						editable: true

						secondaryText: "Editable Spin Box Secondary Label!"

						property bool _initialized: false

						anchors.horizontalCenter: parent.horizontalCenter
						width: parent.width - 2*Theme.geometry_modalDialog_content_horizontalMargin
						height: Theme.geometry_timeSelector_spinBox_height
						indicatorImplicitWidth: customDialog.decimals > 0
												? Theme.geometry_spinBox_indicator_minimumWidth
												: Theme.geometry_spinBox_indicator_maximumWidth
						textFromValue: function(value, locale) {
							// there is no suffix in the string
							return Units.formatNumber(value / customDialog._multiplier(), customDialog.decimals)
						}
						valueFromText: function(text, locale) {
							// there is no suffix in the string
							return Number.fromLocaleString(locale, text) * customDialog._multiplier()
						}
						from: Math.max(Global.int32Min, customDialog.from * customDialog._multiplier())
						to: Math.min(Global.int32Max, customDialog.to * customDialog._multiplier())
						stepSize: customDialog.stepSize * customDialog._multiplier()
						suffix: customDialog.suffix

						onValueChanged: {
							if (_initialized) {
								customDialog.value = Number(spinBox.value / customDialog._multiplier())
							}
						}

						onMinValueReached: customDialog.minValueReached()
						onMaxValueReached: customDialog.maxValueReached()
						Component.onCompleted: {
							spinBox.value = Math.round(customDialog.value * customDialog._multiplier())
							_initialized = true
						}

						validator: DoubleValidator {
							// text editing needs validating in the non-multiplied range
							// this stops you entering a value outside this range
							bottom: Math.min(customDialog.from, customDialog.to)
							top:  Math.max(customDialog.from, customDialog.to)
							decimals: customDialog.decimals
							notation: DoubleValidator.StandardNotation
						}
					}
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
