/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	If there is a Motordrive:
		Show Motordrive current/power (based on global unit setting) and the propeller icon

	If there is GPS and no Motordrive:
		Show DC Load current/power

	If there is no GPS and no Motordrive:
		Show AC and DC load
*/

Column {
	id: root

	required property Gps gps
	required property VeQuickItemsQuotient motorDriveDcConsumption

	QuantityLabelIconRow {
		id: motorDriveLoad

		value: motorDriveDcConsumption.numerator
		unit: motorDriveDcConsumption.unit
		icon.source: "qrc:/images/icon_propeller_32.png"
		icon.width: 32
		visible: motorDriveDcConsumption && motorDriveDcConsumption.valid
	}

	QuantityLabelIconRow {
		id: systemAcLoad

		anchors.right: parent.right
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
		height: font.pixelSize
		value: Global.system.load.ac.preferredQuantity
		unit: Global.systemSettings.electricalQuantity
		icon.source: "qrc:/images/acloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible && !isNaN(value) && !gps.valid && !motorDriveDcConsumption.valid
	}

	QuantityLabelIconRow {
		id: systemDcLoad

		anchors.right: parent.right
		font.pixelSize: Theme.font_boatPage_batterySoc_pixelSize
		height: font.pixelSize
		value: Global.system.dc.preferredQuantity
		unit: Global.systemSettings.electricalQuantity
		icon.source: "qrc:/images/dcloads.svg"
		icon.width: Theme.geometry_widgetHeader_icon_size
		visible: !motorDriveLoad.visible && !isNaN(value)
	}
}


