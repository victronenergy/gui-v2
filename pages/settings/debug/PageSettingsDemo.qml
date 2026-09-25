/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		id: settingsListView

		model: DelegateComponentModel {
			DelegateComponent {
				PrimaryListLabel {
					text: "This page demonstrates the components that can be used to build settings pages."
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "Page launch"
					secondaryText: "Secondary text"
					onClicked: Global.pageManager.pushPage(newPageComponent, { title: "Page name" })
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "Key navigation"
					onClicked: Global.pageManager.pushPage(keyNavigationComponent, { title: "Press up/down to navigate" })
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "DelegateComponentModel demo"
					onClicked: Global.pageManager.pushPage(visibleItemDemoComponent, { title: text })
				}
			}

			DelegateComponent {
				id: demoSwitchDC
				property bool value
				ListSwitch {
					text: "Switch"
					checked: demoSwitchDC.value
					onClicked: {
						demoSwitchDC.value = !checked
						console.log("Switch now checked?", checked)
					}
				}
			}

			DelegateComponent {
				ListSwitch {
					text: "Toggle setting: /Settings/Alarm/Audible"
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/Audible"
				}
			}

			DelegateComponent {
				id: demoRadioArrayDC
				property int currentIndex: 1
				ListRadioButtonGroup {
					text: "Radio buttons with array model"
					currentIndex: demoRadioArrayDC.currentIndex
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
					validatePassword: (index, password) => {
						if ((index === 3 && password === "abc") || (index === 4 && password === "1234")) {
							return Utils.validationResult(VenusOS.InputValidation_Result_OK)
						}
						return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Wrong password!")
					}

					onOptionClicked: function(index) {
						demoRadioArrayDC.currentIndex = index
						console.log("Radio button clicked at index", index)
					}
				}
			}

			DelegateComponent {
				id: demoRadioModelDC
				property int currentIndex: 2
				property string secondaryText: "Option C"
				ListRadioButtonGroup {
					text: "Radio buttons with complex model"
					currentIndex: demoRadioModelDC.currentIndex
					secondaryText: demoRadioModelDC.secondaryText
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
						demoRadioModelDC.currentIndex = index
						console.log("Radio button clicked at index", index)
						demoRadioModelDC.secondaryText = optionModel.get(index).display
					}
				}
			}

			DelegateComponent {
				ListText {
					text: "Text only"
					secondaryText: "Status text"
				}
			}

			DelegateComponent {
				ListText {
					text: "Text only, from dbus source"
					dataItem.uid: Global.system.serviceUid + "/FirmwareBuild"
				}
			}

			DelegateComponent {
				ListQuantity {
					text: "Quantity"
					value: 33.5
					unit: VenusOS.Units_Temperature_Celsius
				}
			}

			DelegateComponent {
				ListQuantityGroup {
					text: "Multiple quantities or text"

					model: QuantityObjectModel {
						QuantityObject { object: customDataObject; key: "voltage"; unit: VenusOS.Units_Volt_DC }
						QuantityObject { object: customDataObject; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: customDataObject; key: "name" }

						// This does not specify a "key", as the default key is "value", which is appropriate for VeQuickItem.
						QuantityObject { object: batterySoc; unit: VenusOS.Units_Percentage }
					}

					QtObject {
						id: customDataObject
						property real voltage: 0.345
						property real current: NaN
						property string name: "Foo"
					}

					Timer {
						running: root.isCurrentPage && Global.timersEnabled
						interval: 3000
						repeat: true
						onTriggered: customDataObject.voltage = Math.random()
					}

					VeQuickItem {
						id: batterySoc
						uid: Global.system.serviceUid + "/Dc/Battery/Soc"
					}
				}
			}

			DelegateComponent {
				id: demoSliderDC
				property real value
				ListSlider {
					text: "Slider"
					from: 1
					to: 100
					stepSize: 10
					value: demoSliderDC.value
					onValueChanged: demoSliderDC.value = value
				}
			}

			DelegateComponent {
				id: demoRangeSliderDC
				property real firstValue: 25
				property real secondValue: 75
				ListRangeSlider {
					text: "Range slider"
					from: 0
					to: 100
					firstValue: demoRangeSliderDC.firstValue
					secondValue: demoRangeSliderDC.secondValue
					onFirstValueChanged: demoRangeSliderDC.firstValue = firstValue
					onSecondValueChanged: demoRangeSliderDC.secondValue = secondValue
					suffix: "%"
					decimals: 1
				}
			}

			DelegateComponent {
				ListButton {
					text: "Button"
					secondaryText: "Click this"
					onClicked: console.log("Button was clicked")
				}
			}

			DelegateComponent {
				ListButton {
					text: "Read-only button"
					readOnly: true
					secondaryText: "Try to click this"
					onClicked: console.log("Will not happen, button cannot be clicked")
				}
			}

			DelegateComponent {
				id: demoTextFieldDC
				property string secondaryText
				ListTextField {
					text: "Text input"
					placeholderText: "Enter text"
					secondaryText: demoTextFieldDC.secondaryText
					onSecondaryTextChanged: demoTextFieldDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: demoTextValidateDC
				property string secondaryText
				ListTextField {
					text: "Text input: forced capitalization, numbers disallowed"
					placeholderText: "Enter text"
					secondaryText: demoTextValidateDC.secondaryText
					onSecondaryTextChanged: demoTextValidateDC.secondaryText = secondaryText
					validateInput: function() {
						if (secondaryText.match(/[0-9]/)) {
							return Utils.validationResult(VenusOS.InputValidation_Result_Error, "Numbers are not allowed!")
						} else if (secondaryText.match(/[a-z]/)) {
							return Utils.validationResult(VenusOS.InputValidation_Result_Warning, "Characters changed to uppercase", secondaryText.toUpperCase())
						} else {
							return Utils.validationResult(VenusOS.InputValidation_Result_OK)
						}
					}
					saveInput: function() {
						console.log("Saving text: %1".arg(secondaryText))
					}
				}
			}

			DelegateComponent {
				id: demoIntFieldDC
				property string secondaryText
				ListIntField {
					text: "Number with 5 digits max"
					maximumLength: 5
					secondaryText: demoIntFieldDC.secondaryText
					onSecondaryTextChanged: demoIntFieldDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: demoQuantityDC
				property real value: 123.5324
				property string secondaryText: Units.formatNumber(123.5324, 1)
				ListQuantityField {
					text: "Quantity input"
					value: demoQuantityDC.value
					secondaryText: demoQuantityDC.secondaryText
					onSecondaryTextChanged: demoQuantityDC.secondaryText = secondaryText
					unit: VenusOS.Units_Amp
					decimals: 1
					saveInput: function() {
						demoQuantityDC.value = Units.formattedNumberToReal(secondaryText)
					}
				}
			}

			DelegateComponent {
				id: demoIpDC
				property string secondaryText: "12.23.21.4"
				ListIpAddressField {
					text: "IP address"
					secondaryText: demoIpDC.secondaryText
					onSecondaryTextChanged: demoIpDC.secondaryText = secondaryText
				}
			}

			DelegateComponent {
				id: demoSpinBoxDC
				property real value: 1.2
				ListSpinBox {
					text: "Spin box"
					value: demoSpinBoxDC.value
					onValueChanged: demoSpinBoxDC.value = value
					decimals: 2
					stepSize: Math.pow(10, -decimals)
					from: 1
					to: 1.5
				}
			}

			DelegateComponent {
				id: demoSpinRangeDC
				property real fromValue: 0
				property real toValue: 75
				ListSpinBoxRange {
					text: "Spin box range"

					dataItemFrom.value: demoSpinRangeDC.fromValue
					dataItemFrom.onValueChanged: demoSpinRangeDC.fromValue = dataItemFrom.value
					rangeModelFrom.minimumValue: -5
					rangeModelFrom.maximumValue: 20
					rangeModelFrom.stepSize: 0.5

					dataItemTo.value: demoSpinRangeDC.toValue
					dataItemTo.onValueChanged: demoSpinRangeDC.toValue = dataItemTo.value
					rangeModelTo.minimumValue: 50
					rangeModelTo.maximumValue: 100
					rangeModelTo.stepSize: 10

					unit: VenusOS.Units_Volume_Litre
				}
			}

			DelegateComponent {
				id: demoDateDC
				property var date: new Date()
				ListDateSelector {
					text: "Date selection"
					Component.onCompleted: date = demoDateDC.date
					onDateChanged: {
						if (date)
							demoDateDC.date = date
					}
				}
			}

			DelegateComponent {
				id: demoTimeDC
				property int hour
				property int minute
				ListTimeSelector {
					text: "Time selection"
					hour: demoTimeDC.hour
					minute: demoTimeDC.minute
					onHourChanged: demoTimeDC.hour = hour
					onMinuteChanged: demoTimeDC.minute = minute
				}
			}

			DelegateComponent {
				ListItem {
					id: toastItem

					topPadding: topInset
					bottomPadding: bottomInset
					contentItem: RowLayout {
						spacing: toastItem.spacing

						Label {
							text: "Toast"
							font: toastItem.font
							Layout.fillWidth: true
						}
						ListItemButton {
							text: "Warning"
							onClicked: Global.showToastNotification(VenusOS.Notification_Warning, "Warning toast")
						}
						ListItemButton {
							text: "Alarm"
							onClicked: Global.showToastNotification(VenusOS.Notification_Alarm, "Alarm toast")
						}
						ListItemButton {
							text: "Info"
							onClicked: Global.showToastNotification(VenusOS.Notification_Info, "Info toast")
						}
					}
				}
			}

			DelegateComponent {
				ListItem {
					id: customItem

					contentItem: RowLayout {
						spacing: customItem.spacing

						Label {
							text: "Custom item"
							font: customItem.font
							Layout.fillWidth: true
						}
						Rectangle {
							width: 30
							height: 30
							radius: 15
							color: Theme.color_ok
						}
						Rectangle {
							width: 30
							height: 30
							color: Theme.color_warning
						}
					}
				}
			}

			DelegateComponent {
				ListText {
					text: "Primary text is long, maybe long enough to span multiple lines"
					secondaryText: "Short secondary text"
				}
			}

			DelegateComponent {
				ListText {
					text: "Short primary text"
					secondaryText: "Secondary text is long, maybe long enough to span multiple lines"
				}
			}

			DelegateComponent {
				ListText {
					text: "Both primary and secondary text are quite long"
					secondaryText: "Both primary and secondary text are quite long"
				}
			}

			DelegateComponent {
				ListLink {
					text: "Victron Energy"
					url: "https://www.victronenergy.com"
				}
			}
		}
	}

	Component {
		id: newPageComponent

		Page {
			GradientListView {
				model: DelegateComponentModel {
					DelegateComponent {
						ListText {
							text: "New page item"
						}
					}
				}
			}
		}
	}

	Component {
		id: visibleItemDemoComponent

		Page {
			component VisibleModelSwitch : ListSwitch {
				property bool rowVisible: true
				signal toggleRequested()
				checked: rowVisible
				onClicked: toggleRequested()
			}

			GradientListView {
				header: PrimaryListLabel {
					text: "DelegateComponentModel filters out any non-visible items from the model.\nFor example, click a switch below to set preferredVisible=false and remove it from the model."
				}
				footer: Column {
					width: parent.width
					PrimaryListLabel {
						horizontalAlignment: Text.AlignHCenter
						text: "%1 items in source model, %2 items in visible model"
								.arg(visibleItemModel.entries.length)
								.arg(visibleItemModel.count)
					}
					ListItemButton {
						anchors.horizontalCenter: parent.horizontalCenter
						text: "Reset 'preferredVisible' values"
						onClicked: {
							toggle1DC.rowVisible = true
							toggle2DC.rowVisible = true
							toggle3DC.rowVisible = true
						}
					}
				}

				model: DelegateComponentModel {
					id: visibleItemModel

					DelegateComponent {
						id: toggle1DC
						property bool rowVisible: true
						preferredVisible: rowVisible
						VisibleModelSwitch {
							rowVisible: toggle1DC.rowVisible
							onToggleRequested: toggle1DC.rowVisible = !toggle1DC.rowVisible
							text: "Toggle A"
						}
					}

					DelegateComponent {
						id: toggle2DC
						property bool rowVisible: true
						preferredVisible: rowVisible
						VisibleModelSwitch {
							rowVisible: toggle2DC.rowVisible
							onToggleRequested: toggle2DC.rowVisible = !toggle2DC.rowVisible
							text: "Toggle B"
						}
					}

					DelegateComponent {
						id: toggle3DC
						property bool rowVisible: true
						preferredVisible: rowVisible
						VisibleModelSwitch {
							rowVisible: toggle3DC.rowVisible
							onToggleRequested: toggle3DC.rowVisible = !toggle3DC.rowVisible
							text: "Toggle C"
						}
					}
				}
			}
		}
	}

	Component {
		id: keyNavigationComponent

		Page {
			GradientListView {
				header: SettingsColumn {
					width: parent ? parent.width : 0

					Repeater {
						model: 5
						delegate: ListText {
							text: "Header item " + model.index
						}
					}
				}

				model: 10
				delegate: ListText {
					text: "List item " + model.index
				}

				footer: SettingsColumn {
					width: parent ? parent.width : 0

					ListItem {
						contentItem: Rectangle {
							implicitWidth: 120
							implicitHeight: 80
							color: Theme.color_ok
						}
					}
				}
			}
		}
	}
}
