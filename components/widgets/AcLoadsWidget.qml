/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

AcWidget {
	id: root

	readonly property ObjectAcConnection measurements: Global.system.showInputLoads
			? Global.system.load.acIn
			: Global.system.load.ac

	type: VenusOS.OverviewWidget_Type_AcLoads
	phaseCount: root.measurements.phases.count

	contentItem: ColumnLayout {
		spacing: 0

		WidgetHeader {
			//% "AC Loads"
			text: qsTrId("overview_widget_acloads_title")
			icon.source: "qrc:/images/acloads.svg"
			Layout.fillWidth: true
		}

		OverviewAcElectricalQuantityLabel {
			widget: root
			dataObject: root.measurements
			Layout.fillWidth: true
			Layout.fillHeight: true
		}

		ThreePhaseDisplay {
			model: root.phaseCount > 1 || root.measurements.l2AndL1OutSummed ? root.measurements.phases : null
			widgetSize: root.size
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			maximumValue: Global.system.load.maximumAcCurrent
			Layout.fillWidth: true
		}
	}

	// AC meters with Position=1 (AC input) are considered as "AC Loads", so they are
	// accessible from this AC Loads widget.
	// For 3-phase systems, the drilldown is always enabled.
	// For 1-phase systems, only enable the drilldown if there are devices to be shown.
	enabled: root.measurements.phaseCount > 1 || acLoadDevices.count > 0

	onClicked: {
		Global.pageManager.pushPage("/pages/loads/AcLoadListPage.qml", {
			title: root.title,
			measurements: root.measurements,
			model: acLoadDevices,
		})
	}

	FilteredDeviceModel {
		id: acLoadDevices
		serviceTypes: ["acload", "evcharger", "heatpump"]
		childFilterIds: Global.system.showInputLoads
				? { "acload": ["Position"], "evcharger": ["Position"], "heatpump": ["Position"] }
				: {}
		childFilterFunction: (device, childItems) => {
			// If a service does not have a /Position value, assume it is in the "input" position.
			const pos = childItems["Position"]
			return !pos || pos.value === undefined || pos.value === VenusOS.AcPosition_AcInput
		}
	 }
}
