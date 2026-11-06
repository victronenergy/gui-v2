/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListText {
	id: root

	property int dessMode: VenusOS.DynamicEss_Mode_Auto
	readonly property bool hasError: dataItem.valid && dataItem.value !== VenusOS.DynamicEss_ErrorCode_NoError

	preferredVisible: hasError
	text: CommonWords.error
	secondaryText: dataItem.valid
		? CommonWords.formatError(VenusOS.dynamicEss_errorToText(dataItem.value), dataItem.value)
		: ""
	contentItem: ListItemLabelLayout {
		primaryText: root.text
		primaryLabel.font: root.font
		secondaryText: root.secondaryText

		CaptionLabel {
			text: dataItem.valid ? VenusOS.dynamicEss_errorHint(dataItem.value, root.dessMode) : ""
			Layout.fillWidth: true
			Layout.columnSpan: parent.columns
		}
	}
}
