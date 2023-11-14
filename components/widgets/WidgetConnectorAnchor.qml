/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Shapes
import Victron.VenusOS

Image {
	id: root

	property int location

	property real defaultY: location === VenusOS.WidgetConnector_Location_Top
		? -height
		: location === VenusOS.WidgetConnector_Location_Bottom
		  ? parent.height
		  : parent.height/2 - height/2

	x: location === VenusOS.WidgetConnector_Location_Left
		? -width
		: location === VenusOS.WidgetConnector_Location_Right
		  ? parent.width
		  : parent.width/2 - width/2
	y: defaultY

	source: location === VenusOS.WidgetConnector_Location_Left
			|| location === VenusOS.WidgetConnector_Location_Right
			? "qrc:/images/widget_connector_nub_horizontal.svg"
			: "qrc:/images/widget_connector_nub_vertical.svg"
	rotation: location === VenusOS.WidgetConnector_Location_Top
			|| location === VenusOS.WidgetConnector_Location_Left
			? 180 : 0
}
