/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	HubData {
		id: data
	}

	GradientListView {
		model: VisibleItemModel {
			ListQuantityGroup {
				text: "PV On ACIn1"
				model: QuantityObjectModel {
					QuantityObject { object: data.pvOnAcIn1; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn1.powerL1; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn1.powerL2; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn1.powerL3; unit: VenusOS.Units_Watt }
				}
			}

			ListQuantityGroup {
				text: "PV On ACIn2"
				model: QuantityObjectModel {
					QuantityObject { object: data.pvOnAcIn2; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn2.powerL1; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn2.powerL2; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcIn2.powerL3; unit: VenusOS.Units_Watt }
				}
			}

			ListQuantityGroup {
				text: "PV On AC Out"
				model: QuantityObjectModel {
					QuantityObject { object: data.pvOnAcOut; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcOut.powerL1; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcOut.powerL2; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.pvOnAcOut.powerL3; unit: VenusOS.Units_Watt }
				}
			}

			ListQuantityGroup {
				text: "AC loads"
				model: QuantityObjectModel {
					QuantityObject { object: data.acLoad; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.acLoad.powerL1; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.acLoad.powerL2; unit: VenusOS.Units_Watt }
					QuantityObject { object: data.acLoad.powerL3; unit: VenusOS.Units_Watt }
				}
			}

			ListQuantityGroup {
				text: "Battery"
				model: QuantityObjectModel {
					QuantityObject { object: Global.system.battery; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: Global.system.battery; key: "voltage"; unit: VenusOS.Units_Volt_DC }
					QuantityObject { object: Global.system.battery; key: "current"; unit: VenusOS.Units_Amp }
				}
			}

			ListQuantity {
				text: "PV Charger"
				value: data.pvCharger.power.value
				unit: VenusOS.Units_Watt
			}
		}
	}
}
