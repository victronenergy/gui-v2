/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string gateway: "can0"

	function _packetsText(packets) {
		//: %1 = number of packets transferred
		//% "Packets: %1"
		return qsTrId("settings_canbus_packets").arg(packets)
	}

	function _droppedPacketsText(dropped, total) {
		if (total) {
			//: %1 = number of dropped packets, %2 = percentage of packets that were dropped
			//% "Dropped: %1 (%2%)"
			return qsTrId("settings_canbus_dropped_packets_percentage").arg(dropped).arg(_percentage(dropped, total))
		}
		//: %1 = number of dropped packets
		//% "Dropped: %1"
		return qsTrId("settings_canbus_dropped_packets").arg(dropped)
	}

	function _overrunsText(overruns, total) {
		if (total) {
			//: %1 = number of overrun errors, %2 = percentage of packets with overrun errors
			//% "Overruns: %1 (%2%)"
			return qsTrId("settings_canbus_overruns_percentage").arg(overruns).arg(_percentage(overruns, total))
		}
		//: %1 = number of overrun errors
		//% "Overruns: %1"
		return qsTrId("settings_canbus_overruns").arg(overruns)
	}

	function _errorsText(errors, total) {
		if (total) {
			//: %1 = number of errors, %2 = percentage of packets with errors
			//% "Errors: %1 (%2%)"
			return qsTrId("settings_canbus_errors_percentage").arg(errors).arg(_percentage(errors, total))
		}
		//: %1 = number of errors
		//% "Errors: %1"
		return qsTrId("settings_canbus_errors").arg(errors)
	}

	function _percentage(count, total) {
		if (!total) {
			return ""
		}
		let perc = count / total * 100
		return perc.toFixed(2)
	}

	Timer {
		interval: 1000
		running: root.animationEnabled
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			if (!root.gateway) {
				return
			}
			const statsText = Global.systemSettings.canBusStatistics(root.gateway)
			let stats
			try {
				stats = JSON.parse(statsText)[0]
			} catch (e) {
				console.warn("Unable to parse JSON:", statsText, "exception:", e)

				// TODO requires venus-platform backend
				console.warn("TODO Global.systemSettings.canBusStatistics() not yet implemented!!")
				return
			}
			if (!stats) {
				return
			}

			stateGroup.visible = stats.linkinfo !== undefined
			if (stats.linkinfo) {
				if (stats.linkinfo.info_data.berr_counter !== undefined) {
					stateGroup.model = [
						stats.linkinfo.info_data.state,
						//% "TEC: %1"
						qsTrId("settings_canbus_tec").arg(stats.linkinfo.info_data.berr_counter.tx),
						//% "REC: %1"
						qsTrId("settings_canbus_rec").arg(stats.linkinfo.info_data.berr_counter.rx),
					]
				} else {
					stateGroup.model = [
						stats.linkinfo.info_data.state,
						//% "TEC: N/A"
						qsTrId("settings_canbus_tec_na"),
						//% "REC: N/A"
						qsTrId("settings_canbus_rec_na"),
					]
				}

				busOffCounters.visible = stats.linkinfo.info_xstats !== undefined
				if (stats.linkinfo.info_xstats) {
					busOffCounters.model = [
						//: %1 = CAN bus statistics: 'bus_off' value
						//% "Bus off: %1"
						qsTrId("settings_canbus_bus_off").arg(stats.linkinfo.info_xstats.bus_off),
						//: %1 = CAN bus statistics: 'error_passive' value
						//% "Error passive: %1"
						qsTrId("settings_canbus_error_passive").arg(stats.linkinfo.info_xstats.error_passive),
						//: %1 = CAN bus statistics: 'error_warning' value
						//% "Bus warning: %1"
						qsTrId("settings_canbus_error_warning").arg(stats.linkinfo.info_xstats.error_warning),
					]
				}
			}

			rxGroup.model = [
				_packetsText(stats.stats64.rx.packets),
				_droppedPacketsText(stats.stats64.rx.dropped, stats.stats64.rx.packets)
			]
			rxErrorGroup.model = [
				_overrunsText(stats.stats64.rx.over_errors, stats.stats64.rx.packets),
				_errorsText(stats.stats64.rx.errors, stats.stats64.rx.packets)
			]

			txGroup.model = [
				_packetsText(stats.stats64.tx.packets),
				_droppedPacketsText(stats.stats64.tx.dropped, stats.stats64.tx.packets)
			]
			txErrorGroup.model = [
				_errorsText(stats.stats64.tx.errors, stats.stats64.tx.packets)
			]
		}
	}

	GradientListView {
		model: ObjectModel {
			ListTextGroup {
				id: stateGroup

				//% "State"
				text: qsTrId("settings_state")
			}

			ListTextGroup {
				id: busOffCounters
			}

			ListTextGroup {
				id: rxGroup

				text: "RX"
				height: implicitHeight + rxErrorGroup.height

				ListTextGroup {
					id: rxErrorGroup

					anchors.bottom: parent.bottom
				}
			}

			ListTextGroup {
				id: txGroup

				text: "TX"
				height: implicitHeight + txErrorGroup.height

				ListTextGroup {
					id: txErrorGroup

					anchors.bottom: parent.bottom
				}
			}
		}
	}
}
