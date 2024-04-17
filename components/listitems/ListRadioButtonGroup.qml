/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

// Each item in the model is expected to have at least 2 values:
//      - "display": the text to display for this option
//      - "value": some backend value associated with this option
//
// The default behaviour supports a simple array-based model. When using a ListModel or C++ model,
// set the currentIndex and secondaryText properties manually.

ListNavigationItem {
	id: root

	readonly property alias dataItem: dataItem
	property var optionModel: []
	property int currentIndex: {
		if (!optionModel || optionModel.length === undefined || dataItem.uid.length === 0 || !dataItem.isValid) {
			return defaultIndex
		}
		for (let i = 0; i < optionModel.length; ++i) {
			if (optionModel[i].value === dataItem.value) {
				return i
			}
		}
		return defaultIndex
	}

	readonly property var currentValue: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].value
			: undefined

	property bool updateOnClick: true
	property var popDestination: null   // if undefined, will not automatically pop page when value is selected

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

	signal optionClicked(index: int, password: string)
	signal aboutToPop()

	secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText

	enabled: userHasReadAccess && (dataItem.uid === "" || dataItem.isValid)

	onClicked: {
		if (userHasWriteAccess) {
			Global.pageManager.pushPage(optionsPageComponent, { title: text })
		} else {
			//% "Setting locked for access level"
			Global.notificationLayer.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_radio_button_group_no_access"))
		}
	}

	VeQuickItem {
		id: dataItem
	}

	Component {
		id: optionsPageComponent

		Page {
			id: optionsPage

			GradientListView {
				id: optionsListView

				model: root.optionModel
				currentIndex: root.currentIndex

				delegate: ListRadioButton {
					id: radioButton

					function select(password) {
						if (!checked) {
							if (root.updateOnClick && dataItem.uid.length > 0) {
								dataItem.setValue(Array.isArray(root.optionModel) ? modelData.value : model.value)
							}
							root.optionClicked(model.index, password)
						}

						if (root.popDestination !== undefined) {
							popTimer.restart()
						}
					}

					text: Array.isArray(root.optionModel)
						  ? modelData.display || ""
						  : model.display || ""
					enabled: (Array.isArray(root.optionModel)
						  ? !modelData.readOnly
						  : !model.readOnly)
					primaryLabel.font.family: Array.isArray(root.optionModel)
						  ? modelData.fontFamily || Global.fontFamily
						  : model.fontFamily || Global.fontFamily

					allowed: (userHasWriteAccess && enabled) || checked
					checked: optionsListView.currentIndex === model.index
					showAccessLevel: root.showAccessLevel
					writeAccessLevel: root.writeAccessLevel
					C.ButtonGroup.group: radioButtonGroup

					bottomContent.z: model.index === optionsListView.currentIndex ? 1 : -1
					bottomContentMargin: Theme.geometry_radioButton_bottomContentMargin
					bottomContentChildren: Loader {
						id: bottomContentLoader

						readonly property string caption: Array.isArray(root.optionModel)
							  ? modelData.caption || ""
							  : model.caption || ""
						readonly property string password: Array.isArray(root.optionModel)
							  ? modelData.password || ""
							  : model.password || ""
						readonly property bool promptPassword: Array.isArray(root.optionModel)
							  ? !!modelData.promptPassword
							  : !!model.promptPassword

						width: parent.width
						sourceComponent: (password.length > 0 || promptPassword) ? passwordComponent
																				 : caption ? captionComponent
																						   : null
					}

					Component {
						id: passwordComponent

						Column {
							function focusPasswordInput() {
								passwordField.forceActiveFocus()
							}

							width: parent.width

							ListLabel {
								topPadding: 0
								bottomPadding: 0
								color: Theme.color_font_secondary
								text: bottomContentLoader.caption
								font.pixelSize: Theme.font_size_caption
								allowed: bottomContentLoader.caption.length > 0
							}

							ListTextField {
								id: passwordField

								//% "Enter password"
								placeholderText: qsTrId("settings_radio_button_enter_password")
								text: ""
								flickable: optionsListView
								primaryLabel.color: Theme.color_font_secondary
								textField.echoMode: TextInput.Password
								enabled: radioButton.enabled
								backgroundRect.color: "transparent"
								Component.onCompleted: allowed = model.index !== root.currentIndex

								validateInput: function() {
									if (!allowed) {
										return validationResult(VenusOS.InputValidation_Result_Unknown)
									}
									if (textField.text !== bottomContentLoader.password) {
										//% "%1: Incorrect password"
										return validationResult(VenusOS.InputValidation_Result_Error, qsTrId("settings_radio_button_incorrect_password").arg(radioButton.text))
									}
									return validationResult(VenusOS.InputValidation_Result_OK)
								}
								saveInput: function() {
									if (allowed) {
										radioButton.select()
									}
								}

								onEditingFinished: {
									allowed = false
									textField.text = ""
								}
								onAccepted: {
									if (bottomContentLoader.promptPassword) {
										radioButton.select(textField.text)
									} else if (textField.text === bottomContentLoader.password) {
										radioButton.select()
									}
								}

								Connections {
									target: root
									enabled: passwordField.allowed

									function onOptionClicked(clickedIndex) {
										if (clickedIndex !== model.index) {
											passwordField.allowed = false
										}
									}
								}
							}
						}
					}

					Component {
						id: captionComponent

						ListLabel {
							topPadding: 0
							bottomPadding: 0
							color: Theme.color_font_secondary
							text: bottomContentLoader.caption
							font.pixelSize: Theme.font_size_caption
						}
					}

					onClicked: {
						if (root.currentIndex === model.index) {
							optionsListView.currentIndex = model.index
							popTimer.restart()
						} else if (bottomContentLoader.sourceComponent === passwordComponent) {
							optionsListView.currentIndex = model.index
							bottomContentLoader.item.focusPasswordInput()
						} else {
							radioButton.select()
						}
					}
				}

				C.ButtonGroup {
					id: radioButtonGroup
				}
			}

			onIsCurrentPageChanged: {
				if (!isCurrentPage) {
					popTimer.stop()
				}
			}

			Timer {
				id: popTimer

				interval: Theme.animation_settings_radioButtonPage_autoClose_duration
				onTriggered: {
					if (!!Global.pageManager) {
						root.aboutToPop()
						if (root.popDestination) {
							Global.pageManager.popPage(root.popDestination)
						} else {
							Global.pageManager.popPage()
						}
					}
				}
			}
		}
	}
}
