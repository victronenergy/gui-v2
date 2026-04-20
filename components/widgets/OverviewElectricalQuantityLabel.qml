/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ElectricalQuantityLabel {
	required property int widgetSize

	alignment: Qt.AlignLeft
	font.pixelSize: widgetSize === VenusOS.OverviewWidget_Size_XS
			  ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
			  : Theme.font_overviewPage_widget_quantityLabel_maximumSize
}
