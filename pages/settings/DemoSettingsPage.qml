/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: ObjectModel {

			SettingsListNavigationItem {
				text: "Page launch"
				secondaryText: "Secondary text"
				onClicked: Global.pageManager.pushPage(newPageComponent)
			}

			SettingsListSwitch {
				text: "Switch"
				onClicked: console.log("Switch now checked?", checked)
			}

			SettingsListSwitch {
				text: "Toggle setting: /Settings/Alarm/Audible"
				source: "com.victronenergy.settings/Settings/Alarm/Audible"
			}

			SettingsListRadioButtonGroup {
				text: "Radio buttons with array model"
				model: [
					{ display: "Option A", value: 1 },
					{ display: "Option B", value: 2 },
					{ display: "Option C", value: 3 },
				]
				currentIndex: 1

				onOptionClicked: function(index) {
					console.log("Radio button clicked at index", index)
					currentIndex = index
				}
			}

			SettingsListRadioButtonGroup {
				text: "Radio buttons with complex model"
				model: ListModel {
					ListElement { display: "Option A"; value: 1 }
					ListElement { display: "Option B"; value: 2 }
					ListElement { display: "Option C"; value: 3 }
				}
				currentIndex: 2

				onOptionClicked: function(index) {
					console.log("Radio button clicked at index", index)
					currentIndex = index
					secondaryText = model.get(index).display
				}
			}

			SettingsListTextItem {
				text: "Text only"
				secondaryText: "Status text"
			}

			SettingsListTextItem {
				text: "Text only, from dbus source"
				source: "com.victronenergy.system/FirmwareBuild"
			}

			SettingsListTextGroup {
				text: "Text groups"
				model: ["204.07V", "4.7A", "950W"]
			}

			SettingsListSlider {
				text: "Slider"

				slider.from: 1
				slider.to: 100
				slider.stepSize: 10
				onValueChanged: function(value) {
					console.log("Value:", value)
				}
			}

			SettingsListButton {
				text: "Button"
				button.text: "Click this"
				onClicked: console.log("Button was clicked")
			}

			SettingsListTextField {
				text: "Text input"
				placeholderText: "Enter text"
			}

			SettingsListItem {
				text: "Custom item"

				content.children: [
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 30
						height: 30
						radius: 15
						color: Theme.color.ok
					},
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 30
						height: 30
						color: Theme.color.warning
					}
				]
			}

			SettingsListTextItem {
				text: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum occaecat cupidatat"
				secondaryText: "Occaecat cupidatat"
			}
		}
	}

	Component {
		id: newPageComponent

		Page {
			SettingsListView {
				model: ObjectModel {
					SettingsListItem {
						text: "New page item"
					}
				}
			}
		}
	}
}
