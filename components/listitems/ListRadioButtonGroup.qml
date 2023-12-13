/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as C
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

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	readonly property alias dataSeen: dataPoint.seen
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property var optionModel: []
	property int currentIndex: {
		if (!optionModel || optionModel.length === undefined || dataSource.length === 0 || !dataValid) {
			return defaultIndex
		}
		for (let i = 0; i < optionModel.length; ++i) {
			if (optionModel[i].value === dataValue) {
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

	signal optionClicked(index: int)

	secondaryText: currentIndex >= 0 && optionModel.length !== undefined && currentIndex < optionModel.length
			? optionModel[currentIndex].display
			: defaultSecondaryText

	enabled: userHasReadAccess && (dataSource === "" || dataValid)

	onClicked: {
		if (userHasWriteAccess) {
			Global.pageManager.pushPage(optionsPageComponent, { title: text })
		} else {
			//% "Setting locked for access level"
			Global.notificationLayer.showToastNotification(Enums.Notification_Info, qsTrId("settings_radio_button_group_no_access"))
		}
	}

	DataPoint {
		id: dataPoint
	}

	Component {
		id: optionsPageComponent

		Page {
			id: optionsPage

			GradientListView {
				id: optionsListView

				model: root.optionModel

				delegate: ListRadioButton {
					id: radioButton

					function select() {
						if (root.updateOnClick) {
							if (dataSource.length > 0) {
								dataPoint.setValue(Array.isArray(root.optionModel) ? modelData.value : model.value)
							} else {
								root.currentIndex = model.index
							}
						}
						root.optionClicked(model.index)

						if (root.popDestination !== undefined) {
							popTimer.restart()
						}
					}

					text: Array.isArray(root.optionModel)
						  ? modelData.display || ""
						  : model.display || ""
					enabled: !checked && (Array.isArray(root.optionModel)
						  ? !modelData.readOnly
						  : !model.readOnly)
					visible: (userHasWriteAccess && enabled) || checked
					checked: root.currentIndex === model.index
					showAccessLevel: root.showAccessLevel
					writeAccessLevel: root.writeAccessLevel
					C.ButtonGroup.group: radioButtonGroup

					bottomContent.children: Loader {
						id: bottomContentLoader

						readonly property string caption: Array.isArray(root.optionModel)
							  ? modelData.caption || ""
							  : model.caption || ""
						readonly property string password: Array.isArray(root.optionModel)
							  ? modelData.password || ""
							  : model.password || ""

						width: parent.width
						sourceComponent: password ? passwordComponent : caption ? captionComponent : null
					}

					Component {
						id: passwordComponent

						Column {
							function showPasswordInput() {
								passwordField.visible = true
								passwordField.forceActiveFocus()
							}

							width: parent.width

							ListTextField {
								id: passwordField

								//% "Enter password"
								text: qsTrId("settings_radio_button_enter_password")
								flickable: optionsListView
								primaryLabel.color: Theme.color.font.secondary
								textField.echoMode: TextInput.Password
								enabled: radioButton.enabled
								visible: false

								onAccepted: function(text) {
									if (text === bottomContentLoader.password) {
										radioButton.select()
									} else {
										//% "Incorrect password"
										Global.notificationLayer.showToastNotification(Enums.Notification_Info,
												qsTrId("settings_radio_button_incorrect_password"))
									}
								}
								onHasActiveFocusChanged: {
									if (!hasActiveFocus) {
										textField.text = ""
										visible = false
									}
								}
							}

							ListLabel {
								topPadding: 0
								bottomPadding: 0
								color: Theme.color.font.secondary
								text: bottomContentLoader.caption
								font.pixelSize: Theme.font.size.caption
								visible: bottomContentLoader.caption.length > 0
							}
						}
					}

					Component {
						id: captionComponent

						ListLabel {
							topPadding: 0
							bottomPadding: 0
							color: Theme.color.font.secondary
							text: bottomContentLoader.caption
							font.pixelSize: Theme.font.size.caption
						}
					}

					onClicked: {
						if (bottomContentLoader.sourceComponent === passwordComponent) {
							bottomContentLoader.item.showPasswordInput()
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

				interval: Theme.animation.settings.radioButtonPage.autoClose.duration
				onTriggered: {
					if (!!Global.pageManager) {
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
