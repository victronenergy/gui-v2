/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property var optionModel
	readonly property alias optionView: optionsListView

	property int showAccessLevel: VenusOS.User_AccessType_User
	property int writeAccessLevel: VenusOS.User_AccessType_Installer

	property int currentIndex
	property bool updateCurrentIndexOnClick: true
	property var popDestination: null
	property var validatePassword

	property alias footer: optionsListView.footer

	signal optionClicked(index: int, value : var)
	signal aboutToPop()

	onIsCurrentPageChanged: {
		if (!isCurrentPage) {
			popTimer.stop()
		}
	}

	GradientListView {
		id: optionsListView

		// Use a separate "selectedIndex" property rather than "currentIndex" to track the selected
		// index, as BaseListView internally modifies its currentIndex to track the focused item.
		property int selectedIndex: root.currentIndex
		property bool selectionChanged

		model: root.optionModel

		delegate: ListRadioButton {
			id: radioButton

			readonly property var modelObject: Array.isArray(root.optionModel) ? modelData : model

			function select() {
				// Get a reference to popTimer in case the delegate is destroyed by the
				// optionClicked handler.
				let popTimerRef = popTimer

				// If the user selects the already-selected option, ignore this and just
				// pop the page, unless the user changed the selection and then selected the
				// original option again. (The latter case can only occur if the page is not
				// popped automatically, by setting popDestination=undefined.)
				if (optionsListView.selectedIndex !== root.currentIndex || optionsListView.selectionChanged) {
					optionsListView.selectionChanged = true
					root.optionClicked(model.index, modelObject.value)
				}

				if (popTimerRef) {
					popTimerRef.restartIfNeeded()
				}
			}

			// TODO this is a hack to cancel out the GradientListView spacing, to avoid
			// showing extra spacing between items if an item is not visible. See #1907.
			height: effectiveVisible ? implicitHeight : -Theme.geometry_gradientList_spacing

			text: modelObject.display || ""
			secondaryText: modelObject.secondaryText || ""
			caption: modelObject.caption ?? ""
			interactive: !modelObject.readOnly
					// Prevent selection of already selected index
					&& root.currentIndex !== model.index
			font.family: modelObject.fontFamily || Global.fontFamily
			preferredVisible: !modelObject.readOnly || root.currentIndex === model.index
			showAccessLevel: root.showAccessLevel
			writeAccessLevel: root.writeAccessLevel
			checked: optionsListView.selectedIndex === model.index
			bottomPadding: bottomContentLoader.height > 0
					? bottomContentLoader.height
						+ (2 * Theme.geometry_listItem_content_verticalMargin) // margin above and below Loader
					: Theme.geometry_listItem_content_verticalMargin

			ButtonGroup.group: radioButtonGroup

			Loader {
				id: bottomContentLoader

				property bool showField

				function focusPasswordInput() {
					showField = true
					item.forceInputFocus()
				}

				anchors {
					right: parent.right
					bottom: parent.bottom
					bottomMargin: Theme.geometry_listItem_content_verticalMargin
				}
				active: !!modelObject.promptPassword
						&& model.index === optionsListView.selectedIndex
				visible: showField // don't show until an option is explicitly selected
				height: active && visible ? implicitHeight : 0
				sourceComponent: Component {
					TextValidationField {
						id: passwordField

						width: Theme.geometry_textField_width + rightInset
						rightPadding: rightInset
						rightInset: confirmButton.width + radioButton.spacing + radioButton.horizontalContentPadding
						flickable: optionsListView
						echoMode: TextInput.Password
						placeholderText: CommonWords.enter_password
						validateOnFocusLost: false // don't validate until 'Confirm' is clicked
						validateInput: function() {
							if (!!root.validatePassword) {
								return root.validatePassword(model.index, text)
							} else {
								console.warn("Password validation not supported!")
								return VenusOS.InputValidation_Result_Error
							}
						}
						onInputValidated: {
							radioButton.select()
						}

						KeyNavigationHighlight.fill: radioButton

						ListItemButton {
							id: confirmButton

							anchors {
								right: parent.right
								rightMargin: radioButton.horizontalContentPadding
							}
							text: CommonWords.confirm
							focusPolicy: Qt.NoFocus
							onClicked: passwordField.runValidation(VenusOS.InputValidation_ValidateAndSave)
						}
					}
				}
			}

			onClicked: {
				if (root.updateCurrentIndexOnClick) {
					optionsListView.selectedIndex = model.index
				} else {
					optionsListView.selectionChanged = true
				}
				if (bottomContentLoader.status === Loader.Ready) {
					bottomContentLoader.focusPasswordInput()
				} else {
					radioButton.select()
				}
			}
		}

		ButtonGroup {
			id: radioButtonGroup
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
