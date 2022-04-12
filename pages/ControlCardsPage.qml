/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	property int cardWidth: cardsView.count > 2
			? Theme.geometry.controlCard.minimumWidth
			: Theme.geometry.controlCard.maximumWidth

	navigationButton: StatusBar.NavigationButton.ControlsActive

	ListView {
		id: cardsView

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCardsPage.horizontalMargin
			right: parent.right
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCardsPage.bottomMargin
		}
		rightMargin: Theme.geometry.controlCardsPage.horizontalMargin
		spacing: Theme.geometry.controlCardsPage.spacing
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.DragOverBounds

		model: ObjectModel {
			Row {
				height: cardsView.height

				Repeater {
					model: generators ? generators.model : null

					GeneratorCard {
						width: root.cardWidth
						state: model.generator.state
						runtime: model.generator.runtime
						runningBy: model.generator.runningBy
						manualStartTimer: model.generator.manualStartTimer

						// TODO bind 'autostart' property to dbus backend value (not yet available)
						// and add changeAutoStart() handler to update when autostart switch is toggled.

						onManualStart: function(durationSecs) {
							model.generator.start(durationSecs)
						}
						onManualStop: {
							model.generator.stop()
						}
					}
				}
			}

			Row {
				height: cardsView.height

				Repeater {
					model: inverters ? inverters.model : null

					InverterCard {
						width: root.cardWidth
						state: model.inverter.state
						ampOptions: model.inverter.ampOptions
						mode: model.inverter.mode
						modeAdjustable: model.inverter.modeAdjustable
						currentLimits: [
							{
								inputType: model.inverter.input1Type,
								currentLimit: model.inverter.currentLimit1,
								currentLimitAdjustable: model.inverter.currentLimit1Adjustable,
							},
							{
								inputType: model.inverter.input2Type,
								currentLimit: model.inverter.currentLimit2,
								currentLimitAdjustable: model.inverter.currentLimit2Adjustable,
							},
						]

						onChangeMode: function (newMode) {
							model.inverter.setMode(newMode)
						}

						onChangeCurrentLimit: function (inputIndex, newCurrentLimit) {
							if (inputIndex === 0) {
								model.inverter.setCurrentLimit1(newCurrentLimit)
							} else if (inputIndex === 1) {
								model.inverter.setCurrentLimit2(newCurrentLimit)
							} else {
								console.warn('Unknown input index', inputIndex)
							}
						}
					}
				}
			}

			ESSCard {
				width: root.cardWidth
				state: ess ? ess.state : Ess.State.Unused
				minimumStateOfCharge: ess ? ess.minimumStateOfCharge : 0
				stateOfChargeLimit: ess ? ess.stateOfChargeLimit : 0

				onChangeState: function(newState) {
					ess.setState(newState)
				}
				onChangeMinimumStateOfCharge: function(newMinSoc) {
					ess.setMinimumStateOfCharge(newMinSoc)
				}
			}

			SwitchesCard {
				width: root.cardWidth
				model: relays ? relays.model : null
			}
		}
	}
}
