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

	property bool _runStartupAnimations: true

	title: CommonWords.brief_page
	iconSource: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.screenSize === Theme.Portrait ? Theme.color_page_background : Theme.color_briefPage_background
	fullScreenWhenIdle: true
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: pageLoader.item?.topRightButton ?? VenusOS.StatusBar_RightButton_None
	showTopGradient: pageLoader.sourceComponent === portraitComponent
			&& pageLoader.item && !pageLoader.item.atYBeginning
	showBottomGradient: pageLoader.sourceComponent === portraitComponent
			&& pageLoader.item && !pageLoader.item.atYEnd

	function toggleSidePanel() {
		root.showSidePanel = !root.showSidePanel
	}

	GaugeModel {
		id: centralGaugeModel
	}

	CpuInfo {
		enabled: root.isCurrentPage && (pageLoader.item?.graphsOpened ?? false)
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
		sourceComponent: Theme.screenSize === Theme.Portrait ? portraitComponent : landscapeComponent

		Component {
			id: landscapeComponent

			BriefPage_Landscape {
				property bool _readyToInit: state === "" && !UiConfig.splashScreenVisible && Global.allPagesLoaded
				on_ReadyToInitChanged: {
					if (_readyToInit) {
						_readyToInit = false    // break the binding
						initialize(root._runStartupAnimations && !showSidePanel)
						root._runStartupAnimations = false
					}
				}

				animationEnabled: root.animationEnabled
				showSidePanel: root.showSidePanel
				gaugeModel: centralGaugeModel

				Image {
					width: status === Image.Null ? 0 : Theme.geometry_screen_width
					fillMode: Image.PreserveAspectFit
					source: UiConfig.demoImageFileName
					onStatusChanged: {
						if (status === Image.Ready) {
							console.info("Loaded demo image:", source)
						}
					}
				}
			}
		}

		Component {
			id: portraitComponent

			Flickable {
				id: portraitFlickable

				contentHeight: portraitPage.implicitHeight
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.VerticalFlick

				Component.onCompleted: root._runStartupAnimations = false

				BriefPage_Portrait {
					id: portraitPage

					width: portraitFlickable.width
					height: portraitFlickable.height
					animationEnabled: root.animationEnabled
					gaugeModel: centralGaugeModel
				}
			}
		}
	}
}
