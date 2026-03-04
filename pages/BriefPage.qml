/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	// Used by StartPageConfiguration when this is the start page.
	property bool showSidePanel

	title: CommonWords.brief_page
	iconSource: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.screenSize === Theme.Portrait ? Theme.color_page_background : Theme.color_briefPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: pageLoader.item?.topRightButton ?? VenusOS.StatusBar_RightButton_None

	function toggleSidePanel() {
		root.showSidePanel = !root.showSidePanel
	}

	GaugeModel {
		id: centralGaugeModel
	}

	CpuInfo {
		enabled: root.isCurrentPage && pageLoader.item?.graphsOpened
		upperLimit: 90
		lowerLimit: 50
		onOverLimitChanged: {
			if (overLimit) {
				//% "System load high, hiding graphs to reduce CPU load"
				Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("brief_close_graphs_high_cpu"))
				pageLoader.item.closeGraphs()
			}
		}
	}

	Loader {
		id: pageLoader
		anchors.fill: parent
		sourceComponent: Theme.screenSize === Theme.Portrait ? briefPagePortrait : briefPageLandscape

		Component {
			id: briefPageLandscape

			BriefPage_Landscape {
				animationEnabled: root.animationEnabled
				showSidePanel: root.showSidePanel
				gaugeModel: centralGaugeModel

				Image {
					width: status === Image.Null ? 0 : Theme.geometry_screen_width
					fillMode: Image.PreserveAspectFit
					source: BackendConnection.demoImageFileName
					onStatusChanged: {
						if (status === Image.Ready) {
							console.info("Loaded demo image:", source)
						}
					}
				}
			}
		}

		Component {
			id: briefPagePortrait

			BriefPage_Portrait {
				animationEnabled: root.animationEnabled
				gaugeModel: centralGaugeModel
			}
		}
	}
}
