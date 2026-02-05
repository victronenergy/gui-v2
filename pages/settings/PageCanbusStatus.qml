/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

Page {
	id: root

	property string gateway: "can0"
	property bool _showStateGroup

	function _percentage(count, total) {
		if (!total) {
			return ""
		}
		let perc = count / total * 100
		return " (" + Units.formatNumber(perc, 2) + "%)"
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

			root._showStateGroup = stats.linkinfo !== undefined
			if (stats.linkinfo) {
				stateData.state = stats.linkinfo.info_data.state
				if (stats.linkinfo.info_data.berr_counter !== undefined) {
					stateData.tec = "TEC: " + stats.linkinfo.info_data.berr_counter.tx
					stateData.rec = "REC: " + stats.linkinfo.info_data.berr_counter.rx
				} else {
					stateData.tec = "TEC: N/A"
					stateData.rec = "REC: N/A"
				}

				busOffCountersData.hasData = stats.linkinfo.info_xstats !== undefined
				if (stats.linkinfo.info_xstats) {
					busOffCountersData.busOff = "Bus off: " + stats.linkinfo.info_xstats.bus_off
					busOffCountersData.errPassive = "Err passive: " + stats.linkinfo.info_xstats.error_passive
					busOffCountersData.busWarn = "Bus warn: " + stats.linkinfo.info_xstats.error_warning
				}
			}

			rxGroupData.packets = "packets: " + stats.stats64.rx.packets
			rxGroupData.dropped = "dropped: " + stats.stats64.rx.dropped + _percentage(stats.stats64.rx.dropped, stats.stats64.rx.packets)
			rxGroupData.overruns = "overruns: " + stats.stats64.rx.over_errors + _percentage(stats.stats64.rx.over_errors, stats.stats64.rx.packets),
			rxGroupData.errors = "errors: " + stats.stats64.rx.errors + _percentage(stats.stats64.rx.errors, stats.stats64.rx.packets)

			txGroupData.packets = "packets: " + stats.stats64.tx.packets
			txGroupData.dropped = "dropped: " + stats.stats64.tx.dropped + _percentage(stats.stats64.tx.dropped, stats.stats64.tx.packets)
			txGroupData.errors = "errors: " + stats.stats64.tx.errors + _percentage(stats.stats64.tx.errors, stats.stats64.tx.packets)
		}
	}

	Timer {
		interval: 1000
		running: root.animationEnabled
		repeat: true
		triggeredOnStart: true

		onTriggered: canStats.getValue(true)
	}

	QtObject {
		id: stateData
		property string state
		property string tec
		property string rec
	}

	QtObject {
		id: busOffCountersData
		property bool hasData
		property string busOff
		property string errPassive
		property string busWarn
	}

	QtObject {
		id: rxGroupData
		property string packets
		property string dropped
		property string overruns
		property string errors
	}

	QtObject {
		id: txGroupData
		property string packets
		property string dropped
		property string errors
	}

	GradientListView {
		model: VisibleItemModel {
			ListItemControl {
				id: stateGroup

				preferredVisible: root._showStateGroup
				contentItem: GridLayout {
					columns: 2
					rowSpacing: Theme.geometry_listItem_content_verticalSpacing
					columnSpacing: Theme.geometry_listItem_content_spacing

					Label {
						text: CommonWords.state
						font: stateGroup.font

						Layout.alignment: Qt.AlignTop
						Layout.rowSpan: 2
					}
					QuantityRow {
						model: QuantityObjectModel {
							QuantityObject { object: stateData; key: "state" }
							QuantityObject { object: stateData; key: "tec" }
							QuantityObject { object: stateData; key: "rec" }
						}
						Layout.alignment: Qt.AlignRight
					}
					QuantityRow {
						visible: busOffCountersData.hasData
						model: QuantityObjectModel {
							QuantityObject { object: busOffCountersData; key: "busOff" }
							QuantityObject { object: busOffCountersData; key: "errPassive" }
							QuantityObject { object: busOffCountersData; key: "busWarn" }
						}
						Layout.alignment: Qt.AlignRight
					}
				}
			}

			ListQuantityGroup {
				id: rxGroup

				contentItem: GridLayout {
					columns: 2
					rowSpacing: Theme.geometry_listItem_content_verticalSpacing
					columnSpacing: Theme.geometry_listItem_content_spacing

					Label {
						text: "RX"
						font: rxGroup.font

						Layout.alignment: Qt.AlignTop
						Layout.rowSpan: 2
					}
					QuantityRow {
						model: QuantityObjectModel {
							QuantityObject { object: rxGroupData; key: "packets" }
							QuantityObject { object: rxGroupData; key: "dropped" }
						}
						Layout.alignment: Qt.AlignRight
					}
					QuantityRow {
						model: QuantityObjectModel {
							QuantityObject { object: rxGroupData; key: "overruns" }
							QuantityObject { object: rxGroupData; key: "errors" }
						}
						Layout.alignment: Qt.AlignRight
					}
				}
			}

			ListQuantityGroup {
				id: txGroup

				contentItem: GridLayout {
					columns: 2
					rowSpacing: Theme.geometry_listItem_content_verticalSpacing
					columnSpacing: Theme.geometry_listItem_content_spacing

					Label {
						text: "TX"
						font: txGroup.font

						Layout.alignment: Qt.AlignTop
						Layout.rowSpan: 2
					}
					QuantityRow {
						model: QuantityObjectModel {
							QuantityObject { object: txGroupData; key: "packets" }
							QuantityObject { object: txGroupData; key: "dropped" }
						}
						Layout.alignment: Qt.AlignRight
					}
					QuantityRow {
						model: QuantityObjectModel {
							QuantityObject { object: txGroupData; key: "errors" }
						}
						Layout.alignment: Qt.AlignRight
					}
				}
			}
		}
	}
}
