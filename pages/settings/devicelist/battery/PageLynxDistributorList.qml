/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: 8 // Up to 8 (A-H)
		delegate: ListNavigationItem {
			id: distributorDelegate

			readonly property string distributor: String.fromCharCode(65 + model.index)
			readonly property string bindPrefix: root.bindPrefix + "/Distributor/" + distributor
			readonly property var connected: status.isValid && status.value === 1
			readonly property list<FuseInfo> fuseInfoList: [
				// Current distributor has 4 fuses
				FuseInfo { fuseNumber: 0; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 1; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 2; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 3; bindPrefix: distributorDelegate.bindPrefix },

				// Add support for future models up to 8 fuses
				FuseInfo { fuseNumber: 4; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 5; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 6; bindPrefix: distributorDelegate.bindPrefix },
				FuseInfo { fuseNumber: 7; bindPrefix: distributorDelegate.bindPrefix }
			]

			//% "Distributor %1"
			text: qsTrId("batterylynxdistibutor_distributor").arg(distributor)
			visible: status.isValid && status.value !== 0
			secondaryText: {
				if (!status.isValid) {
					return "--"
				} else if (status.value === 0) {
					return CommonWords.not_available
				} else if (status.value === 2) {
					//% "No power on busbar"
					return qsTrId("lynxdistributor_no_power_on_busbar")
				} else if (status.value === 3) {
					//% "Connection lost"
					return qsTrId("lynxdistributor_connection_lost")
				}
				let blown = 0
				for (let i = 0; i < fuseInfoList.length; i++) {
					if (fuseInfoList[i].blown) {
						blown++
					}
				}
				if (blown > 0) {
					return blown > 1
						  //: %n = number of fuses that have blown
						  //% "%n fuse(s) blown"
						? qsTrId("lynxdistributor_count_fuses_blown", blown)
						  //% "Fuse blown"
						: qsTrId("lynxdistributor_fuse_blown")
				}
				return CommonWords.ok
			}

			onClicked: {
				Global.pageManager.pushPage(distributorPageComponent, { "title": text })
			}

			VeQuickItem {
				id: status
				uid: root.bindPrefix + "/Distributor/" + distributorDelegate.distributor + "/Status"
			}

			Component {
				id: distributorPageComponent

				Page {
					GradientListView {
						header: ListLabel {
							//% "No information available, see previous page for Distributor status."
							text: qsTrId("lynxdistributor_no_information_available")
							visible: !distributorDelegate.connected
						}
						model: distributorDelegate.connected ? distributorDelegate.fuseInfoList : 0
						delegate: ListTextItem {
							//: %1 = name of this fuse
							//% "Fuse %1"
							text: modelData.fuseName || qsTrId("lynxdistributor_fuse_name").arg(modelData.fuseNumber + 1)
							secondaryText: {
								if (modelData.fuseStatus === 0) {
									return CommonWords.not_available
								} else if (modelData.fuseStatus === 1) {
									//% "Not used"
									return qsTrId("lynxdistributor_not_used")
								} else if (modelData.fuseStatus === 2) {
									return CommonWords.ok
								} else if (modelData.fuseStatus === 3) {
									//% "Blown"
									return qsTrId("lynxdistributor_blown")
								} else {
									return ""
								}
							}
							// First 4 fuses are always visible; last 4 only shown if status is valid.
							visible: model.index < 4 ? defaultVisible : defaultVisible && fuseStatus >= 0
						}
					}
				}
			}
		}
	}
}
