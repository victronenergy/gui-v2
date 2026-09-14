/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	property bool interactiveControls: true
	property bool showCaptions
	property bool showControlVariations
	property bool showLongPrimaryText
	readonly property string longPrimaryText: showLongPrimaryText ? ", with some extra longer text" : ""

	QtObject {
		id: customDataObject

		property real power: 123.45
		property real voltage: 0.345
		property real current: NaN
		property string name: "Foo"
	}

	VeQuickItem {
		id: batterySoc
		uid: Global.system.serviceUid + "/Dc/Battery/Soc"
	}

	Timer {
		running: root.isCurrentPage && Global.timersEnabled
		interval: 2000
		repeat: true
		onTriggered: {
			customDataObject.power = Math.random() * 100
			customDataObject.voltage = Math.random()
		}
	}

	component ControlToggle : RowLayout {
		required property string text
		required property bool checked
		signal clicked

		spacing: Theme.geometry_listItem_content_spacing
		Layout.alignment: Qt.AlignRight

		Label {
			text: parent.text
			font.pixelSize: Theme.font_listItem_caption_size
		}
		Switch {
			checked: parent.checked
			onClicked: parent.clicked()
		}
	}

	GradientListView {
		id: controlsView

		headerPositioning: ListView.OverlayFooter
		model: VisibleItemModel {
			SectionHeader {
				text: "Simple controls"
			}

			ListText {
				text: "Text display" + root.longPrimaryText
				dataItem.uid: Global.venusPlatform.serviceUid + "/Device/Model"
				caption: root.showCaptions ? "Show simple textual information." : ""
			}

			ListQuantity {
				text: "Quantity display" + root.longPrimaryText
				caption: root.showCaptions ? "Show a number with a unit." : ""
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Voltage"
				unit: VenusOS.Units_Volt_DC
			}

			ListTemperature {
				text: "Temperature quantity display" + root.longPrimaryText
				dataItem.uid: Global.system.serviceUid + "/Dc/Battery/Temperature"
				caption: root.showCaptions ? "Show a temperature value in the user-preferred unit." : ""
			}

			ListQuantityGroup {
				text: "Multi-quantity display" + root.longPrimaryText
				caption: root.showCaptions ? "Show multiple quantities with specific units." : ""
				model: QuantityObjectModel {
					QuantityObject { object: customDataObject; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: customDataObject; key: "voltage"; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: customDataObject; key: "name"; unit: VenusOS.Units_None }
				}
			}

			ListNavigation {
				text: "Go to sub-page" + root.longPrimaryText
				caption: root.showCaptions ? "Open a sub-page when clicked." : ""
				onClicked: Global.pageManager.pushPage(subPageComponent)

				Component {
					id: subPageComponent
					Page { title: "Example page" }
				}
			}

			ListQuantityGroupNavigation {
				text: "Go to sub-page, with multi-quantity display" + root.longPrimaryText
				caption: root.showCaptions ? "Show multiple numbers and open a sub-page when clicked." : ""
				quantityModel: QuantityObjectModel {
					QuantityObject { object: batterySoc; unit: VenusOS.Units_Percentage } // no "key" set, so default "value" key is used
					QuantityObject { object: customDataObject; key: "current"; unit: VenusOS.Units_Amp }
				}
				onClicked: Global.pageManager.pushPage(subPageComponent)
			}

			ListButton {
				property int clickCount

				text: "Action trigger" + root.longPrimaryText
				secondaryText: clickCount === 0 ? "Click this" : "Clicks: %1".arg(clickCount)
				caption: root.showCaptions ? "Trigger an action when the button is clicked." : ""
				interactive: root.interactiveControls
				onClicked: clickCount++
			}

			SectionHeader {
				text: "Changing and selecting values"
			}

			ListSwitch {
				text: "Value toggle" + root.longPrimaryText
				caption: root.showCaptions ? "Toggle the dark/light colour scheme value when clicked." : ""
				interactive: root.interactiveControls
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/ColorScheme"
			}

			ListSwitch {
				property bool toggledOn

				preferredVisible: root.showControlVariations
				text: "Local property toggle" + root.longPrimaryText
				caption: root.showCaptions ? "Toggle a property value directly when clicked." : ""
				interactive: root.interactiveControls
				checked: toggledOn
				onClicked: toggledOn = !toggledOn
			}

			ListSwitch {
				preferredVisible: root.showControlVariations
				text: "Direct 'checked' toggle" + root.longPrimaryText
				caption: root.showCaptions ? "Toggle 'checked' value directly when clicked; 'checked' is now %1.".arg(checked) : ""
				interactive: root.interactiveControls
				checkable: true
				checked: true
			}

			ListRadioButtonGroup {
				text: "Option selector" + root.longPrimaryText
				caption: root.showCaptions ? "Select an option from a list." : ""
				interactive: root.interactiveControls
				currentIndex: 0
				optionModel: [
					{ display: "Option A", value: 1 },
					{ display: "Option B (read-only)", value: 2, readOnly: true },
					{ display: "Option C", value: 3, caption: "Some optional caption text." },
					{ display: "Option D (with password)", value: 4, promptPassword: true, caption: "Password is 'abc'" },
					{ display: "Option E (with password)", value: 5, promptPassword: true, caption: "Password is '1234'" },
					{ display: "Option F", value: 6 },
					{ display: "Option G", value: 7 },
					{ display: "Option H", value: 8 },
					{ display: "Option I", value: 9 },
					{ display: "Option J", value: 10 },
					{ display: "Option K", value: 11 },
					{ display: "Option L", value: 12 }
				]
				validatePassword: (index, password) => {
					if ((index === 3 && password === "abc") || (index === 4 && password === "1234")) {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					} else {
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Wrong password!")
					}
				}
				onOptionClicked: function(index) {
					currentIndex = index
					console.log("You selected option: %1".arg(index))
				}
			}

			ListRadioButtonGroup {
				preferredVisible: root.showControlVariations
				text: "Option selector (backed by ListModel)" + root.longPrimaryText
				caption: root.showCaptions ? "Select an option from a ListModel." : ""
				interactive: root.interactiveControls
				currentIndex: 2
				secondaryText: optionModel.get(2).display
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
				validatePassword: (index, password) => {
					if (index === 3 && password === "AAA") {
						return Utils.validationResult(VenusOS.InputValidation_Result_OK)
					}
					return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Wrong password!")
				}
				onOptionClicked: function(index) {
					currentIndex = index
					secondaryText = optionModel.get(index).display
					console.log("You selected option: %1".arg(index))
				}
			}

			ListSpinBox {
				text: "Number selector" + root.longPrimaryText
				caption: root.showCaptions ? "Opens a popup to select a number." : ""
				interactive: root.interactiveControls
				from: 0
				to: 10
				value: 123.45
			}

			ListSpinBoxRange {
				text: "Min/max range selector" + root.longPrimaryText
				caption: root.showCaptions ? "Opens popups to select min/max numbers." : ""
				interactive: root.interactiveControls
				unit: VenusOS.Units_Volume_Litre
				dataItemFrom.value: 0
				rangeModelFrom.minimumValue: -10
				rangeModelFrom.maximumValue: 20
				rangeModelFrom.stepSize: 0.5
				dataItemTo.value: 100
				rangeModelTo.minimumValue: 50
				rangeModelTo.maximumValue: 100
				rangeModelTo.stepSize: 10
			}
			ListDateSelector {
				text: "Date selector" + root.longPrimaryText
				caption: root.showCaptions ? "Opens a popup to select a date." : ""
				interactive: root.interactiveControls
				date: new Date()
			}

			ListTimeSelector {
				text: "Time selector" + root.longPrimaryText
				caption: root.showCaptions ? "Opens a popup to select a time." : ""
				interactive: root.interactiveControls
			}

			ListSlider {
				text: "Slider" + root.longPrimaryText
				caption: root.showCaptions ? "Select a value using a slider. Current=%1".arg(value) : ""
				interactive: root.interactiveControls
				from: -10
				to: 10
				value: 0
			}

			ListRangeSlider {
				text: "Min/max range slider" + root.longPrimaryText
				caption: root.showCaptions ? "Select minimum and maximum values using a slider. Min=%1, max=%2".arg(firstValue).arg(secondValue) : ""
				interactive: root.interactiveControls
				from: 0
				to: 100
				firstValue: 10
				secondValue: 80
			}

			SectionHeader {
				text: "Text input"
			}

			ListTextField {
				text: "Simple text input" + root.longPrimaryText
				caption: root.showCaptions ? "Enter some simple text." : ""
				interactive: root.interactiveControls
				placeholderText: "Enter text here"
				secondaryText: "Initial text"
			}

			ListTextField {
				preferredVisible: root.showControlVariations
				text: "Text input without placeholder or initial text" + root.longPrimaryText
				caption: root.showCaptions ? "The text input box should remain appropriately sized." : ""
				interactive: root.interactiveControls
			}

			ListQuantityField {
				text: "Quantity input" + root.longPrimaryText
				caption: root.showCaptions ? "Enter a value with a specific unit." : ""
				interactive: root.interactiveControls
				value: 123.45
				unit: VenusOS.Units_Energy_KiloWattHour
			}

			ListIntField {
				text: "Numeric input" + root.longPrimaryText
				caption: root.showCaptions ? "Enter a number with a maximum of %1 digits.".arg(maximumLength) : ""
				interactive: root.interactiveControls
				maximumLength: 5
				secondaryText: "12345"
			}

			ListIpAddressField {
				text: "IP address input" + root.longPrimaryText
				caption: root.showCaptions ? "Enter an IP address. The entered value will be validated." : ""
				interactive: root.interactiveControls
			}

			SectionHeader {
				text: "Other"
			}

			ListLink {
				text: "QR code link"
				url: "https://www.victronenergy.com"
				interactive: root.interactiveControls
			}

			ListItem {
				id: toastItem

				topPadding: topInset
				bottomPadding: bottomInset
				contentItem: RowLayout {
					spacing: toastItem.spacing

					Label {
						text: "Toasts"
						font: toastItem.font
						Layout.fillWidth: true
					}

					ListItemButton {
						text: "Info"
						onClicked: Global.showToastNotification(VenusOS.Notification_Info, "Generic informational message")
					}

					ListItemButton {
						text: "Warning"
						onClicked: Global.showToastNotification(VenusOS.Notification_Warning, "Warning-type message")
					}

					ListItemButton {
						text: "Alarm"
						onClicked: Global.showToastNotification(VenusOS.Notification_Alarm, "Alarm-type message")
					}
				}
			}

			SectionHeader {
				text: "Development"
			}

			ListSwitch {
				text: "Show control variations"
				checked: root.showControlVariations
				onClicked: root.showControlVariations = !root.showControlVariations
			}
			ListSwitch {
				text: "Show control configurations"
				checked: controlsView.header === headerComponent
				onClicked: controlsView.header = controlsView.header === headerComponent ? null : headerComponent
			}
		}

		Component {
			id: headerComponent

			ListItem {
				z: 2 // show above delegates
				bottomInset: Theme.geometry_gradientList_bottomMargin
				contentItem: GridLayout {
					columns: Theme.screenSize === Theme.Portrait ? 2 : 4
					rowSpacing: Theme.geometry_listItem_content_spacing
					columnSpacing: Theme.geometry_listItem_content_verticalMargin

					ControlToggle {
						text: "Longer text"
						checked: root.showLongPrimaryText
						onClicked: root.showLongPrimaryText = !root.showLongPrimaryText
					}

					ControlToggle {
						text: "Captions"
						checked: root.showCaptions
						onClicked: root.showCaptions = !root.showCaptions
					}

					ControlToggle {
						text: "Interactive"
						checked: root.interactiveControls
						onClicked: root.interactiveControls = !root.interactiveControls
					}

					ControlToggle {
						text: "Dark theme"
						checked: Theme.colorScheme === Theme.Dark
						onClicked: Theme.colorScheme = Theme.colorScheme === Theme.Dark ? Theme.Light : Theme.Dark
					}
				}
				background: ListItemBackground {
					border.color: "black"
					radius: 0
					MouseArea { anchors.fill: parent } // prevent clicks from going through the header
				}
			}
		}
	}
}
