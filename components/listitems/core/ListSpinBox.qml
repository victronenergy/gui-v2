/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	readonly property alias dataItem: dataItem
	property alias value: rangeModel.value
	property string suffix
	property int decimals
	property real from: !isNaN(dataItem.min) ? dataItem.min : 0
	property real to: !isNaN(dataItem.max) ? dataItem.max : Global.int32Max / Math.pow(10, decimals) // qml int is a signed 32 bit value
	property real stepSize: 1
	property var presets: []
	property string fromErrorText
	property string toErrorText

	property var _numberSelector

	signal selectorAccepted(newValue: var)

	secondaryText: value === undefined ? "--" : Units.formatNumber(value, decimals) + root.suffix
	interactive: (dataItem.uid === "" || dataItem.valid)

	// Connect to this method rather than a JS closure so Qt drops the connection if this row is
	// destroyed while the dialog is still open. The dialog writes dataUid itself; this only updates
	// a local-only value and forwards selectorAccepted while the row still exists.
	function _onNumberSelectorAccepted() {
		const dialog = Global.dialogLayer.currentDialog
		if (!dialog) {
			return
		}
		const newValue = dialog.value
		if (dataItem.uid.length === 0) {
			root.value = newValue
		}
		root.selectorAccepted(newValue)
	}

	onClicked: {
		// Create NumberSelectorDialog from a file URL, not from a Component nested in this row.
		// A nested Component's QQmlContext is this list item; if DelegateComponentModel releases
		// the row while the dialog is open, the dialog freezes even though it is parented to
		// DialogLayer. Translatable fields use Qt.binding so a language change updates them while
		// this row still exists; dataUid owns write-back so accept does not close over root.
		const dialog = Global.dialogLayer.open("/components/dialogs/NumberSelectorDialog.qml", {
			title: Qt.binding(function() { return root.text }),
			titleTextFormat: root.textFormat,
			suffix: Qt.binding(function() { return root.suffix }),
			decimals: root.decimals,
			from: root.from,
			to: root.to,
			stepSize: root.stepSize,
			presets: Qt.binding(function() { return root.presets }),
			fromErrorText: Qt.binding(function() { return root.fromErrorText }),
			toErrorText: Qt.binding(function() { return root.toErrorText }),
			value: root.value,
			dataUid: dataItem.uid,
		})
		if (dialog) {
			dialog.accepted.connect(root._onNumberSelectorAccepted)
		}
	}

	RangeModel {
		id: rangeModel
		minimumValue: isNaN(root.from) ? 0 : root.from
		maximumValue: isNaN(root.to) ? 100 : root.to
		value: dataItem.valid ? dataItem.value : 0
	}

	VeQuickItem {
		id: dataItem
	}
}
