/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	If there is a Motordrive and a GPS:
		Show Motordrive current/power (based on global unit setting) and the propeller icon

	Otherwise:
		Show AC / DC Load current/power
*/

Column {
	id: root

	required property Gps gps
	required property VeQuickItemsQuotient motorDriveDcConsumption
	readonly property int visibleCount: motorDriveLoad.visible + systemAcLoad.visible + systemDcLoad.visible
	readonly property int _pixelSize: visibleCount > 1
									 ? Theme.font_boatPage_consumptionGauge_smallPixelSize
									 : Theme.font_boatPage_consumptionGauge_largePixelSize

	spacing: Theme.font_boatPage_consumptionGauge_columnSpacing

	QuantityLabelIconRow {
		id: motorDriveLoad

		font.pixelSize: root._pixelSize
		value: motorDriveDcConsumption.numerator
		unit: motorDriveDcConsumption.displayUnit
		icon.source: "qrc:/images/icon_propeller.svg"
		visible: gps.valid && motorDriveDcConsumption && motorDriveDcConsumption.valid
	}

	QuantityLabelIconRow {
		id: systemAcLoad

		anchors.right: parent.right
		font.pixelSize: root._pixelSize
		height: font.pixelSize
		value: Global.system.load.ac.preferredQuantity
		unit: Global.systemSettings.electricalQuantity
		icon.source: "qrc:/images/acloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible // && !isNaN(value) once #2159 is resolved
	}

	QuantityLabelIconRow {
		id: systemDcLoad

		anchors.right: parent.right
		font.pixelSize: root._pixelSize
		height: font.pixelSize
		value: Global.system.dc.preferredQuantity
		unit: Global.systemSettings.electricalQuantity
		icon.source: "qrc:/images/dcloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible && !isNaN(value)
	}
}


