/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

MiniSlider {
	id: root

	required property SwitchableOutput switchableOutput
	readonly property bool hasDimmingProperties: switchableOutput.type === VenusOS.SwitchableOutput_Type_Dimmable
			|| switchableOutput.type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
			|| switchableOutput.type === VenusOS.SwitchableOutput_Type_BasicSlider
	property int sourceUnit
	property int displayUnit

	// True if the slider value is being changed by the user (either by touch or key press)
	readonly property bool dragging: pressed || _valueChangeKeyPressed
	property bool _valueChangeKeyPressed

	property var valueDataItem: VeQuickItem {
		uid: root.hasDimmingProperties ? root.switchableOutput.uid + "/Dimming" : ""
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
	KeyNavigationHighlight.topMargin: root.topInset
	KeyNavigationHighlight.bottomMargin: root.bottomInset
	KeyNavigationHighlight.leftMargin: root.leftInset
	KeyNavigationHighlight.rightMargin: root.rightInset

	VeQuickItem {
		id: dimmingMaxItem
		uid: root.hasDimmingProperties ? root.switchableOutput.uid + "/Settings/DimmingMax" : ""
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: dimmingMinItem
		uid: root.hasDimmingProperties ? root.switchableOutput.uid + "/Settings/DimmingMin" : ""
		sourceUnit: Units.unitToVeUnit(root.sourceUnit)
		displayUnit: Units.unitToVeUnit(root.displayUnit)
	}
	VeQuickItem {
		id: stepSizeItem
		uid: root.hasDimmingProperties ? root.switchableOutput.uid + "/Settings/StepSize" : ""
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
