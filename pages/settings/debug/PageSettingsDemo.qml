/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QZXing

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			PrimaryListLabel {
				text: "This page demonstrates the components that can be used to build settings pages."
			}

			ListNavigation {
				text: "Page launch"
				secondaryText: "Secondary text"
				onClicked: Global.pageManager.pushPage(newPageComponent, { title: "Page name" })
			}

			ListSwitch {
				text: "Switch"
				property bool value
				checked: value
				onClicked: {
					value = !checked
					console.log("Switch now checked?", checked)
				}
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
					{ display: "Option D", value: 4, promptPassword: true, caption: "Password is 'abc'" },
					{ display: "Option E", value: 5, promptPassword: true, caption: "Password is '1234'" },
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
				validatePassword: (index, password) => {
					if ((index === 3 && password === "abc") || (index === 4 && password === "1234")) {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Wrong password!")
				}

				onOptionClicked: function(index) {
					currentIndex = index
					console.log("Radio button clicked at index", index)
				}
			}

			ListRadioButtonGroup {
				text: "Radio buttons with complex model"
				optionModel: ListModel {
					ListElement { display: "Option A"; value: 1 }
					ListElement { display: "Option B"; value: 2; readOnly: true }
					ListElement { display: "Option C"; value: 3 }
					ListElement { display: "Option D (with password 'AAA')"; value: 4; promptPassword: true }
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
				validatePassword: (index, password) => {
					if (index === 3 && password === "AAA") {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Wrong password!")
				}

				onOptionClicked: function(index) {
					currentIndex = index
					console.log("Radio button clicked at index", index)
					secondaryText = optionModel.get(index).display
				}
			}

			ListText {
				text: "Text only"
				secondaryText: "Status text"
			}

			ListText {
				text: "Text only, from dbus source"
				dataItem.uid: Global.system.serviceUid + "/FirmwareBuild"
			}

			ListTextGroup {
				text: "Multiple texts"
				textModel: ["204.07V", "4.7A", "950W"]
			}

			ListQuantity {
				text: "Quantity"
				value: 33.5
				unit: VenusOS.Units_Temperature_Celsius
			}

			ListQuantityGroup {
				text: "Multiple quantities"
				textModel: [
					{ value: 5.1, unit: VenusOS.Units_Volt_DC },
					{ value: 48, unit: VenusOS.Units_Watt }
				]
			}

			ListSlider {
				text: "Slider"
				slider.from: 1
				slider.to: 100
				slider.stepSize: 10
			}

			ListRangeSlider {
				text: "Range slider"
				slider.from: 0
				slider.to: 100
				slider.first.value: 25
				slider.second.value: 75
				slider.suffix: "%"
				slider.decimals: 1
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

			ListTextField {
				text: "Text input: forced capitalization, numbers disallowed"
				placeholderText: "Enter text"
				validateInput: function() {
					if (textField.text.match(/[0-9]/)) {
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Numbers are not allowed!")
					} else if (textField.text.match(/[a-z]/)) {
						return Utils.validationResult(VenusOS.InputValidation_Result_Warning, "Characters changed to uppercase", textField.text.toUpperCase())
					} else {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
				}
				saveInput: function() {
					console.log("Saving text: %1".arg(textField.text))
				}
			}

			ListIntField {
				text: "Number with 5 digits max"
				maximumLength: 5
			}

			ListQuantityField {
				text: "Quantity input"
				value: 123.5324
				unit: VenusOS.Units_Amp
				decimals: 1
			}

			ListIpAddressField {
				text: "IP address"
				secondaryText: "12.23.21.4"
			}

			ListSpinBox {
				text: "Spin box"
				value: 1.2
				decimals: 2
				stepSize: Math.pow(10, -decimals)
				from: 1
				to: 1.5
			}

			ListDateSelector {
				text: "Date selection"
				date: new Date()
			}

			ListTimeSelector {
				text: "Time selection"
			}


			ListItem {
				text: "Toast"
				content.children: [

					ListItemButton {
						text: "Warning"
						onClicked: Global.showToastNotification(VenusOS.Notification_Warning, "Warning toast")
					},
					ListItemButton {
						text: "Alarm"
						onClicked: Global.showToastNotification(VenusOS.Notification_Alarm, "Alarm toast")
					},
					ListItemButton {
						text: "Info"
						onClicked: Global.showToastNotification(VenusOS.Notification_Info, "Info toast")
					}
				]
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
				id: customListItem
				text: "Custom bottom content item"

				content.children: [
					Rectangle {
						anchors.verticalCenter: parent.verticalCenter
						width: 100
						height: 100
						radius: width / 2
						color: "orange"

						MouseArea {
							anchors.fill: parent
							onClicked: {
								customListItem.bottomContentSizeMode = customListItem.bottomContentSizeMode === VenusOS.ListItem_BottomContentSizeMode_Compact
										? VenusOS.ListItem_BottomContentSizeMode_Stretch
										: VenusOS.ListItem_BottomContentSizeMode_Compact
							}
						}
					}
				]

				bottomContentChildren: [
					PrimaryListLabel {
						color: Theme.color_listItem_secondaryText
						font.pixelSize: Theme.font_size_body1
						text: "This can wrap next to the content item, or be placed below the content item and stretch to the full item size. Click the orange button to toggle this size mode."
					}
				]
			}

			ListText {
				text: "Primary text is long, maybe long enough to span multiple lines"
				secondaryText: "Short secondary text"
			}

			ListText {
				text: "Short primary text"
				secondaryText: "Secondary text is long, maybe long enough to span multiple lines"
			}

			ListText {
				text: "Both primary and secondary text are quite long"
				secondaryText: "Both primary and secondary text are quite long"
			}

			ListItem {
				text: "Scan the QR code:"
				content.children: [
					Image {
						source: "image://QZXing/encode/" + "https://www.victronenergy.com/" +
								"?correctionLevel=M" +
								"&format=qrcode"
						sourceSize.width: Theme.geometry_listItem_height
						sourceSize.height: Theme.geometry_listItem_height
					}
				]
			}

			ListLink {
				text: "Victron Energy"
				url: "https://www.victronenergy.com"
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
