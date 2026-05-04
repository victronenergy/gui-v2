/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property real power: model.totalPower
	readonly property real current: model.totalCurrent
	readonly property real maximumPower: _maximumPower.valid ? _maximumPower.value : NaN

	readonly property DcMeterDeviceModel model: DcMeterDeviceModel {
		serviceTypes: ["alternator", "fuelcell", "dcsource", "dcgenset"]
	}

	readonly property VeQuickItem _maximumPower: VeQuickItem {
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Dc/Input/Power/Max"
	}

	function overviewWidgetTypeForService(serviceType, dcMeterType = -1) {
		switch (serviceType) {
		case "alternator":
			return VenusOS.OverviewWidget_Type_Alternator
		case "dcgenset":
			return VenusOS.OverviewWidget_Type_DcGenerator
		case "fuelcell":
			return VenusOS.OverviewWidget_Type_FuelCell
		case "dcsource":
			// If dcMeterType is set, return a specific widget for this meter type. Otherwise, group
			// it together with other dcsource devices, into a "Generic source" box.
			switch (dcMeterType) {
			case VenusOS.DcMeter_Type_AcCharger:
				return VenusOS.OverviewWidget_Type_AcCharger
			case VenusOS.DcMeter_Type_DcCharger:
				return VenusOS.OverviewWidget_Type_DcCharger
			case VenusOS.DcMeter_Type_ShaftGenerator:
				return VenusOS.OverviewWidget_Type_ShaftGenerator
			case VenusOS.DcMeter_Type_WaterGenerator:
				return VenusOS.OverviewWidget_Type_WaterGenerator
			case VenusOS.DcMeter_Type_WindCharger:
				return VenusOS.OverviewWidget_Type_WindCharger
			default:
				break
			}
			return VenusOS.OverviewWidget_Type_GenericDcSource
		default:
			console.warn("DC input service type was", serviceType, "which is not in Global.dcInputs.model!")
			return -1
		}
	}

	Component.onCompleted: Global.dcInputs = root
}
