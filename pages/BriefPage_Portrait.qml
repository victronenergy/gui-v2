/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	// This is not required in Portrait layout, but is required by StartPageLoader for landscape
	// layout.
	property bool showSidePanel

	navButtonText: CommonWords.brief_page
	navButtonIcon: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	GaugeModel {
		id: gaugeModel
	}

	Flickable {
		id: briefFlickable
		anchors.fill: parent
		contentHeight: detailPanel.y + detailPanel.height

		Rectangle {
			id: mainGaugeBackground

			x: Theme.geometry_page_content_horizontalMargin
			width: root.width - (2 * Theme.geometry_page_content_horizontalMargin)
			height: mainGauge.height + (2 * Theme.geometry_mainGauge_padding)
			color: Theme.color_background_secondary
			radius: Theme.geometry_button_radius

			Loader {
				id: mainGauge

				anchors.centerIn: parent
				width: Theme.geometry_mainGauge_size
				height: Theme.geometry_mainGauge_size
				sourceComponent: gaugeModel.count === 0 ? singleGauge : multiGauge
				onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
			}
		}

		Loader {
			id: detailPanel

			x: Theme.geometry_page_content_horizontalMargin
			y: mainGaugeBackground.y + mainGaugeBackground.height + Theme.geometry_sidePanel_spacing
			sourceComponent: sidePanelActiveComponent

			CpuInfo {
				enabled: root.isCurrentPage && detailPanel.sourceComponent === sidePanelActiveComponent
				upperLimit: 90
				lowerLimit: 50
				onOverLimitChanged: {
					if (overLimit) {
						//% "System load high, hiding graphs to reduce CPU load"
						Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("brief_close_graphs_high_cpu"))
						detailPanel.sourceComponent = sidePanelInactiveComponent
					}
				}
			}

			Component {
				id: sidePanelActiveComponent

				BriefSidePanel {
					width: root.width - (2 * Theme.geometry_page_content_horizontalMargin)
					animationEnabled: root.animationEnabled
				}
			}

			Component {
				id: sidePanelInactiveComponent

				Rectangle {
					width: root.width - (2 * Theme.geometry_page_content_horizontalMargin)
					height: panelAutoCloseColumn.height
					color: Theme.color_background_secondary
					radius: Theme.geometry_button_radius

					Column {
						id: panelAutoCloseColumn

						width: parent.width
						topPadding: Theme.geometry_sidePanel_sideWidget_verticalMargin
						bottomPadding: Theme.geometry_sidePanel_sideWidget_verticalMargin
						spacing: Theme.geometry_sidePanel_sideWidget_verticalMargin

						Label {
							width: parent.width
							leftPadding: Theme.geometry_sidePanel_sideWidget_horizontalMargin
							rightPadding: Theme.geometry_sidePanel_sideWidget_horizontalMargin
							horizontalAlignment: Text.AlignHCenter
							wrapMode: Text.Wrap
							//% "Graphs and additional details have been hidden to reduce the CPU load."
							text: qsTrId("brief_graphs_hidden")
							font.pixelSize: Theme.font_size_caption
						}

						ListItemButton {
							anchors.horizontalCenter: parent.horizontalCenter
							//% "Show graphs"
							text: qsTrId("brief_graphs_show")
							onClicked: detailPanel.sourceComponent = sidePanelActiveComponent
						}
					}
				}
			}
		}
	}

	ViewGradient {
		anchors.bottom: briefFlickable.bottom
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			id: circularMultiGauge
			model: gaugeModel
			animationEnabled: root.animationEnabled
			shortCaptionWidth: (mainGaugeBackground.width / 2) - Theme.geometry_page_content_horizontalMargin
			longCaptionWidth: shortCaptionWidth

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width - (gaugeModel.count * circularMultiGauge._stepSize) + Theme.geometry_circularMultiGauge_spacing
				showFullDetails: gaugeModel.count === 1
			}
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.system.battery

			value: visible && !isNaN(battery.stateOfCharge) ? battery.stateOfCharge : 0
			status: Theme.getValueStatus(value, properties.valueType)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled

			BriefCenterDisplay {
				anchors.centerIn: parent
				width: parent.width
				showFullDetails: true
			}
		}
	}
}
