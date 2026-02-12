/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

/*
	Provides a SwitchableOutputSlider with an On/Off toggle button on the left-hand side.
*/
SwitchableOutputSlider {
	id: root

	function toggleOutputState() {
		dimmingState.writeValue(root.switchableOutput.state === 0 ? 1 : 0)
	}

	leftPadding: dimmingToggleButton.width
	highlightColor: enabled
		? (dimmingToggleButton.checked ? Theme.color_ok : Theme.color_button_off_background)
		: (dimmingToggleButton.checked ? Theme.color_button_on_background_disabled : Theme.color_button_off_background_disabled)
	backgroundColor: enabled ? Theme.color_darkOk : Theme.color_background_disabled
	borderColor: enabled ? Theme.color_ok : Theme.color_font_disabled

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			focus = false
			event.accepted = true
			break
		}
	}

	MiniToggleButton {
		id: dimmingToggleButton

		defaultBackgroundHeight: Theme.geometry_iochannel_control_height
		leftInset: root.leftInset
		leftPadding: root.leftInset
		topInset: root.topInset
		bottomInset: root.bottomInset
		checked: dimmingState.expectedValue === 1

		onClicked: root.toggleOutputState()

		Rectangle {
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: Theme.geometry_miniSlider_separator_width
			height: parent.defaultBackgroundHeight - (Theme.geometry_miniSlider_decorator_vertical_padding * 2)
			radius: Theme.geometry_miniSlider_separator_width / 2
			color: enabled ? Theme.color_slider_separator : Theme.color_font_disabled
		}
	}

	SettingSync {
		id: dimmingState
		dataItem: VeQuickItem {
			uid: root.switchableOutput.uid + "/State"
		}
	}
}
