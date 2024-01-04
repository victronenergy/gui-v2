/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string gateway: "can0"

	function _percentage(count, total) {
		if (!total) {
			return ""
		}
		let perc = count / total * 100
		return " (" + perc.toFixed(2) + "%)"
	}

	VeQuickItem {
		id: canStats
		uid: Global.venusPlatform.serviceUid + "/CanBus/Interface/" + gateway + "/Statistics"
		onValueChanged: {
			if (value === undefined) {
				return
			}
			let json
			try {
				json = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse JSON:", value, "exception:", e)
				return
			}
			if (json.length < 1) {
				return
			}
			const stats = json[0]

			stateGroup.visible = stats.linkinfo !== undefined
			if (stats.linkinfo) {
				if (stats.linkinfo.info_data.berr_counter !== undefined) {
					stateGroup.textModel = [
						stats.linkinfo.info_data.state,
						"TEC: " + stats.linkinfo.info_data.berr_counter.tx,
						"REC: " + stats.linkinfo.info_data.berr_counter.rx,
					]
				} else {
					stateGroup.textModel = [
						stats.linkinfo.info_data.state,
						"TEC: N/A",
						"REC: N/A"
					]
				}

				busOffCounters.visible = stats.linkinfo.info_xstats !== undefined
				if (stats.linkinfo.info_xstats) {
					busOffCounters.textModel = [
						"Bus off: " + stats.linkinfo.info_xstats.bus_off,
						"Err passive: " + stats.linkinfo.info_xstats.error_passive,
						"Bus warn: " + stats.linkinfo.info_xstats.error_warning,
					]
				}
			}

			rxGroup.textModel = [
				"packets: " + stats.stats64.rx.packets,
				"dropped: " + stats.stats64.rx.dropped + _percentage(stats.stats64.rx.dropped, stats.stats64.rx.packets)
			]
			rxErrorGroup.textModel = [
				"overruns: " + stats.stats64.rx.over_errors + _percentage(stats.stats64.rx.over_errors, stats.stats64.rx.packets),
				"errors: " + stats.stats64.rx.errors + _percentage(stats.stats64.rx.errors, stats.stats64.rx.packets)
			]

			txGroup.textModel = [
				"packets: " + stats.stats64.tx.packets,
				"dropped: " + stats.stats64.tx.dropped + _percentage(stats.stats64.tx.dropped, stats.stats64.tx.packets)
			]
			txErrorGroup.textModel = [
				"errors: " + stats.stats64.tx.errors + _percentage(stats.stats64.tx.errors, stats.stats64.tx.packets)
			]
		}
	}

	Timer {
		interval: 1000
		running: root.animationEnabled
		repeat: true
		triggeredOnStart: true

		onTriggered: canStats.getValue(true)
	}

	GradientListView {
		model: ObjectModel {
			ListTextGroup {
				id: stateGroup

				//% "State"
				text: qsTrId("settings_state")
				bottomContent.children: ListTextGroup {
					id: busOffCounters
				}
			}

			ListTextGroup {
				id: rxGroup

				text: "RX"
				bottomContent.children: ListTextGroup {
					id: rxErrorGroup
				}
			}

			ListTextGroup {
				id: txGroup

				text: "TX"
				bottomContent.children: ListTextGroup {
					id: txErrorGroup
				}
			}
		}
	}
}
