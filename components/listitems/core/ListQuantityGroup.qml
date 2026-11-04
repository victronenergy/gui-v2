/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	property QuantityObjectModel model

	// Standard layout:
	// | Primary label       | Quantity row |
	//
	// A column layout is used if the minimum primary text length would not fit together with the
	// quantity row on one line:
	// | Primary label   |
	// | Quantity row    |
	contentItem: ListItemQuantitiesLayout {
		text: root.text
		label.font: root.font
		label.textFormat: root.textFormat
		model: root.model
	}
}
