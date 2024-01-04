/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListLabel {
				text: "This page demonstrates the components that can be used to build settings pages."
			}

			ListNavigationItem {
				text: "Page launch"
				secondaryText: "Secondary text"
				onClicked: Global.pageManager.pushPage(newPageComponent, { title: "Page name" })
			}

			ListSwitch {
				text: "Switch"
				onClicked: console.log("Switch now checked?", checked)
			}

			ListSwitch {
				text: "Toggle setting: /Settings/Alarm/Audible"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"
			}

			ListRadioButtonGroup {
				text: "Radio buttons with array model"
				optionModel: [
					{ display: "Option A", value: 1 },
					{ display: "Option B", value: 2, readOnly: true },
					{ display: "Option C", value: 3, caption: "Some extra description below" },
					{ display: "Option D", value: 4, password: "123" },
					{ display: "Option E", value: 5, password: "456", caption: "This needs a password" },
					{ display: "Option F", value: 6 },
					{ display: "Option G", value: 7 },
					{ display: "Option H", value: 8 },
					{ display: "Option I", value: 9 },
					{ display: "Option J", value: 10 },
					{ display: "Option K", value: 11 },
					{ display: "Option L", value: 12 },
					{ display: "Option M", value: 13 },
					{ display: "Option N", value: 14 },
					{ display: "Option O", value: 15 },
					{ display: "Option P", value: 16 },
					{ display: "Option Q", value: 17 },
					{ display: "Option R", value: 18 },
					{ display: "Option S", value: 19 },
					{ display: "Option T", value: 20 },
					{ display: "Option U", value: 21 },
				]
				currentIndex: 1

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
					ListElement { display: "Option D"; value: 4 }
					ListElement { display: "Option E"; value: 5 }
					ListElement { display: "Option F"; value: 6 }
					ListElement { display: "Option G"; value: 7 }
					ListElement { display: "Option H"; value: 8 }
					ListElement { display: "Option I"; value: 9 }
					ListElement { display: "Option J"; value: 10 }
					ListElement { display: "Option K"; value: 11 }
					ListElement { display: "Option L"; value: 12 }
					ListElement { display: "Option M"; value: 13 }
					ListElement { display: "Option N"; value: 14 }
					ListElement { display: "Option O"; value: 15 }
					ListElement { display: "Option P"; value: 16 }
					ListElement { display: "Option Q"; value: 17 }
					ListElement { display: "Option R"; value: 18 }
					ListElement { display: "Option S"; value: 19 }
					ListElement { display: "Option T"; value: 20 }
					ListElement { display: "Option U"; value: 21 }
				}
				currentIndex: 2
				secondaryText: optionModel.get(2).display

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
				dataItem.uid: Global.system.serviceUid + "/FirmwareBuild"
			}

			ListTextGroup {
				text: "Multiple texts"
				textModel: ["204.07V", "4.7A", "950W"]
			}

			ListQuantityItem {
				text: "Quantity"
				value: 33.5
				unit: VenusOS.Units_Temperature_Celsius
			}

			ListQuantityGroup {
				text: "Multiple quantities"
				textModel: [
					{ value: 5.1, unit: VenusOS.Units_Volt },
					{ value: 48, unit: VenusOS.Units_Watt }
				]
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

			ListRangeSlider {
				text: "Range slider"
				slider.from: 0
				slider.to: 100
				slider.first.value: 25
				slider.second.value: 75
				slider.suffix: "%"
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
				date: new Date()
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
						color: Theme.color_ok
					},
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 30
						height: 30
						color: Theme.color_warning
					}
				]
			}

			ListItem {
				text: "Custom bottom content item"

				bottomContent.children: [
					ListLabel {
						topPadding: 0
						bottomPadding: 0
						color: Theme.color_font_secondary
						text: "Custom text label"
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

		Page {
			GradientListView {
				model: ObjectModel {
					ListItem {
						text: "New page item"
					}
				}
			}
		}
	}
}
