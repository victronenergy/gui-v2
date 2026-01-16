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
	required property MotorDrives motorDrives
	readonly property int visibleCount: motorDriveLoad.visible + systemAcLoad.visible + systemDcLoad.visible
	readonly property int _pixelSize: root.visibleCount > 1
									 ? Theme.font_boatPage_consumptionGauge_smallPixelSize
									 : Theme.font_boatPage_consumptionGauge_largePixelSize

	spacing: Theme.font_boatPage_consumptionGauge_columnSpacing

	QuantityLabelIconRow {
		id: motorDriveLoad

		sourceType: VenusOS.ElectricalQuantity_Source_Dc
		dataObject: root.motorDrives.dcConsumption.scalar
		font.pixelSize: root._pixelSize
		icon.source: "qrc:/images/icon_propeller.svg"
		visible: root.gps.valid && !isNaN(value)
	}

	QuantityLabelIconRow {
		id: systemAcLoad

		anchors.right: parent.right
		font.pixelSize: root._pixelSize
		height: font.pixelSize
		sourceType: VenusOS.ElectricalQuantity_Source_Ac
		dataObject: Global.system.load.ac
		icon.source: "qrc:/images/acloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible && Global.system?.hasAcLoads // && !isNaN(value) once #2159 is resolved
	}

	QuantityLabelIconRow {
		id: systemDcLoad

		anchors.right: parent.right
		font.pixelSize: root._pixelSize
		height: font.pixelSize
		sourceType: VenusOS.ElectricalQuantity_Source_Dc
		dataObject: Global.system.dc
		icon.source: "qrc:/images/dcloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible && !isNaN(value)
	}
}


