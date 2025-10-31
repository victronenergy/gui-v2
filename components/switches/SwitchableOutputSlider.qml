/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

MiniSlider {
	id: root

	required property SwitchableOutput switchableOutput
	property int sourceUnit
	property int displayUnit

	// True if the slider value is being changed by the user (either by touch or key press)
	readonly property bool dragging: pressed || _valueChangeKeyPressed
	property bool _valueChangeKeyPressed

	property var valueDataItem: VeQuickItem {
		uid: root.switchableOutput.uid + "/Dimming"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	from: dimmingMinItem.valid ? dimmingMinItem.value : 0
	to: dimmingMaxItem.valid ? dimmingMaxItem.value : 100
	stepSize: stepSizeItem.valid ? stepSizeItem.value : 1

	onMoved: {
		valueSync.writeValue(value)
	}

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Up:
		case Qt.Key_Down:
			// When this control has focus, prevent up/down from moving the focus elsewhere.
			event.accepted = true
			return
		case Qt.Key_Left:
		case Qt.Key_Right:
			_valueChangeKeyPressed = true
			break
		}
		event.accepted = false
	}
	Keys.onReleased: (event) => {
		if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
			_valueChangeKeyPressed = false
		}
		event.accepted = false
	}
	KeyNavigationHighlight.active: root.activeFocus

	VeQuickItem {
		id: dimmingMaxItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMax"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: dimmingMinItem
		uid: root.switchableOutput.uid + "/Settings/DimmingMin"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: stepSizeItem
		uid: root.switchableOutput.uid + "/Settings/StepSize"
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}

	SliderSettingSync {
		id: valueSync
		dataItem: root.valueDataItem
		dragging: root.dragging
		onUpdateSliderValue: root.value = dataItem.value || 0
	}
}
