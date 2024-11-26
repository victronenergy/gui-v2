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

ListNavigation {
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

	property bool updateCurrentIndexOnClick: true
	property bool updateDataOnClick: true
	property var popDestination: null   // if undefined, will not automatically pop page when value is selected
	property var validatePassword

	property int defaultIndex: -1
	//% "Unknown"
	property string defaultSecondaryText: qsTrId("settings_radio_button_group_unknown")

	signal optionClicked(index: int)
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

				property bool selectionChanged

				model: root.optionModel
				currentIndex: root.currentIndex

				delegate: ListRadioButton {
					id: radioButton

					function select() {
						// If the user selects the already-selected option, ignore this and just
						// pop the page, unless the user changed the selection and then selected the
						// original option again. (The latter case can only occur if the page is not
						// popped automatically, by setting popDestination=undefined.)
						if (optionsListView.currentIndex !== root.currentIndex || optionsListView.selectionChanged) {
							optionsListView.selectionChanged = true
							if (root.updateDataOnClick && dataItem.uid.length > 0) {
								dataItem.setValue(Array.isArray(root.optionModel) ? modelData.value : model.value)
							}
							root.optionClicked(model.index)
						}
						popTimer.restartIfNeeded()
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
						readonly property bool promptPassword: Array.isArray(root.optionModel)
							  ? !!modelData.promptPassword
							  : !!model.promptPassword

						width: parent.width
						sourceComponent: promptPassword ? passwordComponent : (caption ? captionComponent : null)
					}

					Component {
						id: passwordComponent

						Column {
							function focusPasswordInput() {
								passwordField.showField = true
								passwordField.secondaryText = ""
								passwordField.forceActiveFocus()
							}

							width: parent.width

							PrimaryListLabel {
								topPadding: 0
								color: Theme.color_font_secondary
								text: bottomContentLoader.caption
								font.pixelSize: Theme.font_size_caption
								allowed: bottomContentLoader.caption.length > 0
							}

							ListTextField {
								id: passwordField

								readonly property ListItemButton confirmButton: ListItemButton {
									//: Confirm password, and verify it if possible
									//% "Confirm"
									text: qsTrId("settings_radio_button_group_confirm")
									onClicked: {
										passwordField.validateOnConfirm = true
										if (passwordField.textField.activeFocus) {
											// Trigger the validation that occurs when focus is lost.
											passwordField.textField.focus = false
										} else {
											passwordField.runValidation(VenusOS.InputValidation_ValidateAndSave)
										}
									}
								}
								property bool validateOnConfirm
								property bool showField

								//% "Enter password"
								placeholderText: qsTrId("settings_radio_button_enter_password")
								text: ""
								flickable: optionsListView
								primaryLabel.color: Theme.color_font_secondary
								textField.echoMode: TextInput.Password
								enabled: radioButton.enabled
								backgroundRect.color: "transparent"
								allowed: showField && model.index === optionsListView.currentIndex && !!root.validatePassword
								validateInput: function() {
									// Validate the password on Enter/Return, or when "Confirm" is
									// clicked. Ignore validation requests when the field does not
									// have focus: e.g. when the selected radio button changes, or
									// when this page is popped, or when an external dialog opens
									// and causes focus to be lost. We want to only validate the
									// password when the user explicitly indicates it should be done.
									if (!textField.activeFocus && !passwordField.validateOnConfirm) {
										return Utils.validationResult(VenusOS.InputValidation_Result_Unknown)
									}
									passwordField.validateOnConfirm = false
									return root.validatePassword(model.index, textField.text)
								}
								saveInput: function() {
									if (allowed) {
										radioButton.select()
									}
								}
								content.children: [
									defaultContent,
									confirmButton
								]
							}
						}
					}

					Component {
						id: captionComponent

						PrimaryListLabel {
							topPadding: 0
							bottomPadding: 0
							color: Theme.color_font_secondary
							text: bottomContentLoader.caption
							font.pixelSize: Theme.font_size_caption
						}
					}

					onClicked: {
						if (root.updateCurrentIndexOnClick) {
							optionsListView.currentIndex = model.index
						} else {
							optionsListView.selectionChanged = true
						}
						if (bottomContentLoader.sourceComponent === passwordComponent) {
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

				function restartIfNeeded() {
					if (root.popDestination !== undefined) {
						restart()
					}
				}

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
