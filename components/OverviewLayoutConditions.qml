/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	signal conditionChanged

	// Affects whether one or both AcInputWidgets are shown, and their widget sizes.
	readonly property AcInput acInput1: Global.acInputs?.input1 ?? null
	onAcInput1Changed: conditionChanged()
	readonly property AcInput acInput2: Global.acInputs?.input2 ?? null
	onAcInput2Changed: conditionChanged()

	// Affects whether DcInputWidget(s) are shown.
	readonly property bool showDcInputs: Global.dcInputs?.model.count ?? 0 > 0
	onShowDcInputsChanged: conditionChanged()

	// Affects whether SolarYieldWidget is shown, and its widget size.
	readonly property bool showSolar: Global.solarInputs.inputCount > 0
	onShowSolarChanged: conditionChanged()
	readonly property int pvChargerCount: Global.solarInputs?.devices.count ?? 0
	onPvChargerCountChanged: conditionChanged()
	readonly property int pvInverterCount: Global.solarInputs?.pvInverterDevices.count ?? 0
	onPvInverterCountChanged: conditionChanged()

	// Affects whether AcLoadsWidget is shown.
	// When evcharger services are present, the AC loads is required because the EVCS widget might
	// connect to the AC Loads widget.
	readonly property bool showAcLoads: Global.system?.hasAcLoads || Global.evChargers?.model.count > 0
	onShowAcLoadsChanged: conditionChanged()

	// Affects whether DcLoadsWidget is shown.
	readonly property bool showDcLoads: Global.system?.dc.hasPower
	onShowDcLoadsChanged: conditionChanged()

	// Affects whether EssentialLoadsWidget is shown.
	readonly property bool showEssentialLoads: Global.system?.showInputLoads && Global.system?.hasAcOutSystem
	onShowEssentialLoadsChanged: conditionChanged()

	// Affects whether EvcsWidget is shown.
	readonly property bool showEvChargers: Global.evChargers?.model.count ?? 0 > 0
	onShowEvChargersChanged: conditionChanged()

	// Affects the type of DC widget that is shown for a DC input. The meter type of a DC input may
	// change during runtime, based on user configuration.
	readonly property Connections _dcMetersConn: Connections {
		target: Global.dcInputs.model
		function onDataChanged(topLeft, bottomRight, roles) {
			if (roles.indexOf(DcMeterDeviceModel.MeterTypeRole) >= 0) {
				conditionChanged()
			}
		}
	}
}
