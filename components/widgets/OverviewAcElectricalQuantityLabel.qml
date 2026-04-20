/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ElectricalQuantityLabel {
	id: root

	required property AcWidget widget

	leftPadding: acInputDirectionIcon.visible ? (acInputDirectionIcon.width + Theme.geometry_acInputDirectionIcon_rightMargin) : 0
	alignment: Qt.AlignLeft
	sourceType: VenusOS.ElectricalQuantity_Source_Ac

	// In the smallest widget size, when there are 3 phases, only show the phases, and not
	// the quantity label.
	visible: root.widget.size > VenusOS.OverviewWidget_Size_XS || (!!dataObject && root.widget.phaseCount <= 1)

	// Size the text according to the widget size.
	font.pixelSize: root.widget.size === VenusOS.OverviewWidget_Size_XS ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
		: root.widget.size === VenusOS.OverviewWidget_Size_S
			 ? root.widget.phaseCount > 1
				? Theme.font_overviewPage_widget_quantityLabel_smallSizeWithExtraContent // allow space for 3-phase metrics
				: Theme.font_overviewPage_widget_quantityLabel_maximumSize
		: root.widget.size === VenusOS.OverviewWidget_Size_M
			? root.widget.phaseCount > 1
				? Theme.font_overviewPage_widget_quantityLabel_minimumSize
				: Theme.font_overviewPage_widget_quantityLabel_maximumSize
		// Size L and XL
		: Theme.font_overviewPage_widget_quantityLabel_maximumSize

	AcInputDirectionIcon {
		id: acInputDirectionIcon
		y: parent.implicitHeight/2 - height/2 // vertically centre on the first line, not the stretched label height
		input: root.widget.input
	}
}
