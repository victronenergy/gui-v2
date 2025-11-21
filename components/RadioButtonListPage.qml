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
			interactive: !modelObject.readOnly
					// Prevent selection of already selected index
					&& root.currentIndex !== model.index
			primaryLabel.font.family: modelObject.fontFamily || Global.fontFamily
			preferredVisible: !modelObject.readOnly || root.currentIndex === model.index
			showAccessLevel: root.showAccessLevel
			writeAccessLevel: root.writeAccessLevel
			checked: optionsListView.selectedIndex === model.index
			ButtonGroup.group: radioButtonGroup

			bottomContent.z: model.index === optionsListView.selectedIndex ? 1 : -1
			bottomContentChildren: Loader {
				id: bottomContentLoader

				readonly property string caption: modelObject.caption ?? ""
				readonly property bool promptPassword: !!modelObject.promptPassword

				width: parent.width
				sourceComponent: promptPassword ? passwordComponent : (caption ? captionComponent : null)
			}

			Component {
				id: passwordComponent

				SettingsColumn {
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
						preferredVisible: bottomContentLoader.caption.length > 0
					}

					ListPasswordField {
						id: passwordField

						property bool showField

						flickable: optionsListView
						primaryLabel.color: Theme.color_font_secondary
						interactive: radioButton.interactive
						background.color: "transparent"
						showAccessLevel: root.showAccessLevel
						writeAccessLevel: root.writeAccessLevel
						preferredVisible: showField && model.index === optionsListView.selectedIndex && !!root.validatePassword
						KeyNavigationHighlight.fill: radioButton
						validateInput: function() {
							return root.validatePassword(model.index, textField.text)
						}
						saveInput: function() {
							if (preferredVisible) {
								radioButton.select()
							}
						}
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
					optionsListView.selectedIndex = model.index
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
