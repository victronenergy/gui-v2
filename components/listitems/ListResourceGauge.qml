/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Display-only "label + bar" row for a resource's current value against a
	maximum (e.g. "Storage 620 MB / 1 GB").

	Not a ListSetting: this is a read-only summary row, not something the user
	edits (compare ListResourceGauge to ListSlider, which is the editable
	equivalent used for the actual Memory/CPU-maximum limit rows).
*/
ListItem {
	id: root

	// Title, e.g. "Memory". Formatting of the value readout (e.g. "620 MB / 1 GB")
	// is left to the caller via valueText, same reasoning as ListSlider's own
	// text property - there's no single unit that fits every caller (bytes vs
	// cores vs a bare process count).
	property string text
	property string valueText
	property string caption

	// Raw value/maximum driving the bar fill - NOT already-normalised to 0..1,
	// so callers can pass D-Bus values directly (e.g. MemoryUsedBytes/MemoryLimitBytes).
	property real value
	property real to

	contentItem: ColumnLayout {
		spacing: Theme.geometry_listItem_content_verticalSpacing

		RowLayout {
			Layout.fillWidth: true
			spacing: root.spacing

			Label {
				text: root.text
				font: root.font
				textFormat: root.textFormat
				wrapMode: Text.WordWrap

				Layout.fillWidth: true
			}

			SecondaryListLabel {
				text: root.valueText

				Layout.alignment: Qt.AlignRight
			}
		}

		ProgressBar {
			// to <= 0 (system max not yet published, or genuinely zero) means
			// there is nothing meaningful to show a fraction of - leave the bar
			// empty rather than dividing by zero.
			value: root.to > 0 ? Math.min(root.value / root.to, 1) : 0

			Layout.fillWidth: true
		}

		CaptionLabel {
			text: root.caption
			visible: text.length > 0

			Layout.fillWidth: true
		}
	}
}
