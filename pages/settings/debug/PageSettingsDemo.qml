/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListLabel {
				text: "This page demonstrates the components that can be used to build settings pages."
			}

			ListNavigationItem {
				text: "Page launch"
				secondaryText: "Secondary text"
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo(newPageComponent, { title: "Page name" }, listIndex)
			}

			ListSwitch {
				text: "Switch"
				onClicked: console.log("Switch now checked?", checked)
			}

			ListSwitch {
				text: "Toggle setting: /Settings/Alarm/Audible"
				dataSource: "com.victronenergy.settings/Settings/Alarm/Audible"
			}

			ListRadioButtonGroup {
				text: "Radio buttons with array model"
				optionModel: [
					{ display: "Option A", value: 1 },
					{ display: "Option B", value: 2, readOnly: true },
					{ display: "Option C", value: 3 },
				]
				currentIndex: 1
				listPage: root
				listIndex: ObjectModel.index

				onOptionClicked: function(index) {
					console.log("Radio button clicked at index", index)
				}
			}

			ListRadioButtonGroup {
				text: "Radio buttons with complex model"
				optionModel: ListModel {
					ListElement { display: "Option A"; value: 1 }
					ListElement { display: "Option B"; value: 2; readOnly: true }
					ListElement { display: "Option C"; value: 3 }
				}
				currentIndex: 2
				secondaryText: optionModel.get(2).display
				listPage: root
				listIndex: ObjectModel.index

				onOptionClicked: function(index) {
					console.log("Radio button clicked at index", index)
					secondaryText = optionModel.get(index).display
				}
			}

			ListTextItem {
				text: "Text only"
				secondaryText: "Status text"
			}

			ListTextItem {
				text: "Text only, from dbus source"
				dataSource: "com.victronenergy.system/FirmwareBuild"
			}

			ListTextGroup {
				text: "Text groups"
				textModel: ["204.07V", "4.7A", "950W"]
			}

			ListSlider {
				text: "Slider"
				slider.from: 1
				slider.to: 100
				slider.stepSize: 10
				onValueChanged: function(value) {
					console.log("Value:", value)
				}
			}

			ListButton {
				text: "Button"
				button.text: "Click this"
				onClicked: console.log("Button was clicked")
			}

			ListTextField {
				text: "Text input"
				placeholderText: "Enter text"
			}

			ListIpAddressField {
				text: "IP address"
			}

			ListSpinBox {
				text: "Spin box"
				value: 5.789
				decimals: 2
				from: 5
				to: 10
			}

			ListDateSelector {
				text: "Date selection"
			}

			ListTimeSelector {
				text: "Time selection"
			}

			ListItem {
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

			ListTextItem {
				text: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum occaecat cupidatat"
				secondaryText: "Occaecat cupidatat"
			}
		}
	}

	Component {
		id: newPageComponent

		ListPage {
			listView: GradientListView {
				model: ObjectModel {
					ListItem {
						text: "New page item"
					}
				}
			}
		}
	}
}
