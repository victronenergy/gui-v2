/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

AcWidget {
	id: root

	readonly property AcInputSystemInfo inputInfo: input?.inputInfo ?? null
	readonly property bool inputOperational: input && input.operational

	rightPadding: Theme.geometry_overviewPage_widget_content_horizontalMargin
			+ (sideGaugeLoader.active ? sideGaugeLoader.width + Theme.geometry_overviewPage_widget_sideGauge_margins : 0)
	phaseCount: inputOperational ? input.phases.count : 0
	enabled: !!inputInfo

	contentItem: ColumnLayout {
		spacing: 0

		WidgetHeader {
			text: !!root.inputInfo ? Global.acInputs.sourceToText(root.inputInfo.source) : ""
			icon.source: !!root.inputInfo ? Global.acInputs.sourceIcon(root.inputInfo.source) : ""
			Layout.fillWidth: true
		}

		Loader {
			sourceComponent: root.inputOperational ? operationalComponent : nonOperationalComponent
			Layout.fillWidth: true
			Layout.fillHeight: true

			Component {
				id: operationalComponent

				ColumnLayout {
					spacing: 0

					OverviewAcElectricalQuantityLabel {
						widget: root
						dataObject: root.input
						sourceType: VenusOS.ElectricalQuantity_Source_AcInputOnly
						Layout.fillWidth: true
						Layout.fillHeight: true
					}

					ThreePhaseDisplay {
						model: root.phaseCount > 1 ? root.input.phases : null
						widgetSize: root.size
						inputMode: true
						Layout.fillWidth: true
					}
				}
			}

			Component {
				id: nonOperationalComponent

				Label {
					id: stateLabel

					topPadding: Theme.geometry_overviewPage_widget_content_topMargin
					elide: Text.ElideRight
					text: root.inputInfo && root.inputInfo.source === VenusOS.AcInputs_InputSource_Generator
							? CommonWords.stopped
							: CommonWords.disconnected
					font.pixelSize: Theme.font_overviewPage_secondary
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
	}

	onClicked: {
		const inputServiceUid = BackendConnection.serviceUidFromName(root.inputInfo.serviceName, root.inputInfo.deviceInstance)
		if (root.inputInfo.serviceType === "acsystem") {
			Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystem.qml",
					{ "bindPrefix": inputServiceUid })
		} else if (root.inputInfo.serviceType === "vebus") {
			Global.pageManager.pushPage( "/pages/vebusdevice/PageVeBus.qml", {
				"bindPrefix": inputServiceUid
			})
		} else if (root.inputInfo.serviceType === "genset") {
			Global.pageManager.pushPage( "/pages/settings/devicelist/PageGenset.qml", {
				"bindPrefix": inputServiceUid
			})
		} else {
			// Assume this is on a generic AC input
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
				"bindPrefix": inputServiceUid
			})
		}
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		active: root.inputOperational && root.size >= VenusOS.OverviewWidget_Size_M
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_NeutralPercentage
			phaseModel: root.input.phases
			minimumValue: root.inputInfo?.minimumCurrent ?? NaN
			maximumValue: root.inputInfo?.maximumCurrent ?? NaN
			inputMode: true
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}
}
