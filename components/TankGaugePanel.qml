/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS
import Victron.Gauges

AbstractListItem {
	id: root

	required property bool isGroup
	required property Tank tank // null if isGroup=true
	required property TankModel tankModel
	required property bool animationEnabled

	readonly property var tankProperties: Gauges.tankProperties(tankModel?.type ?? tank?.type ?? -1)
	readonly property int tankStatus: isGroup ? VenusOS.Tank_Status_Ok : (tank?.status ?? VenusOS.Tank_Status_Unknown)
	readonly property real totalCapacity: isGroup ? tankModel.totalCapacity : tank?.capacity ?? NaN
	readonly property real totalRemaining: isGroup ? tankModel.totalRemaining : tank?.remaining ?? NaN
	readonly property color backgroundColor: tankStatus === VenusOS.Tank_Status_Ok
			? Theme.color_levelsPage_gauge_backgroundColor
			: Theme.color_levelsPage_panel_border_color

	implicitWidth: Math.max(
		implicitBackgroundWidth + leftInset + rightInset,
		implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(
		implicitBackgroundHeight + topInset + bottomInset,
		implicitContentHeight + topPadding + bottomPadding)

	leftInset: Theme.geometry_levelsPage_panel_horizontalInset
	rightInset: Theme.geometry_levelsPage_panel_horizontalInset
	leftPadding: leftInset + Theme.geometry_levelsGauge_horizontalPadding
	rightPadding: rightInset + Theme.geometry_levelsGauge_horizontalPadding
	topPadding: Theme.geometry_levelsPage_panel_header_height + Theme.geometry_levelsGauge_verticalPadding
	bottomPadding: Theme.geometry_levelsGauge_verticalPadding

	background: Item {
		implicitWidth: Theme.geometry_levelsPage_panel_background_width
		implicitHeight: Theme.geometry_levelsPage_panel_background_height

		// The colour indicator is on the top in landscape, and on the left in portrait.
		Rectangle {
			width: Theme.geometry_levelsPage_panel_header_width || parent.width
			height: Theme.geometry_levelsPage_panel_header_height ||  parent.height
			topLeftRadius: Theme.geometry_levelsPage_panel_radius
			topRightRadius: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_levelsPage_panel_radius
			bottomLeftRadius: Theme.screenSize === Theme.Portrait ? Theme.geometry_levelsPage_panel_radius : 0
			color: root.tankProperties.color

			// In landscape, show the tank name within the header.
			Label {
				anchors {
					left: parent.left
					right: parent.right
					bottom: parent.bottom
					margins: Theme.geometry_levelsPage_panel_background_title_padding
				}
				horizontalAlignment: Text.AlignHCenter
				elide: Text.ElideRight
				text: root.tank?.name ?? root.tankProperties?.name ?? ""
				color: Theme.color_levelsPage_tank_title
				visible: Theme.screenSize !== Theme.Portrait
			}
		}

		// Fill out the rest of the background with a background colour.
		// In portrait, the background overlaps slightly with the colour indicator, so that it
		// slightly clips the radius of the indicator.
		Rectangle {
			anchors {
				fill: parent
				leftMargin: Theme.geometry_levelsPage_panel_background_overlap
				topMargin: Theme.geometry_levelsPage_panel_header_height
			}
			color: root.backgroundColor
			topRightRadius: Theme.screenSize === Theme.Portrait ? Theme.geometry_levelsPage_panel_radius : 0
			bottomLeftRadius: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_levelsPage_panel_radius
			bottomRightRadius: Theme.geometry_levelsPage_panel_radius
		}
	}

	contentItem: Item {
		// Width is always sized to the parent.
		// Height is sized to the parent in landscape, and variable in portrait based on the number
		// of gauge bars.
		implicitHeight: Theme.screenSize === Theme.Portrait ? levelsGauge.height : 0

		LevelsGaugeOutline {
			id: levelsGauge

			width: parent.width
			height: Theme.screenSize === Theme.Portrait
					? implicitHeight + capacityLabel.height
					: parent.height - capacityLabel.height
			name: root.tank?.name ?? root.tankProperties?.name ?? ""
			iconSource: root.tankProperties?.icon ?? ""
			iconColor: root.tankStatus === VenusOS.Tank_Status_Ok ? Theme.color_levelsPage_tankIcon : Theme.color_warning
			value: root.isGroup ? root.tankModel.averageLevel : root.tank?.level ?? NaN
			unit: VenusOS.Units_Percentage
			gauge: root.isGroup ? gaugeGroupComponent : singleGaugeComponent
			gaugeHorizontalPadding: Theme.geometry_tankGaugePanel_gauge_horizontalPadding

			Component {
				id: singleGaugeComponent

				TankGauge {
					orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical
					expanded: !!Global.pageManager && Global.pageManager.expandLayout
					animationEnabled: root.animationEnabled
					valueType: root.tankProperties.valueType
					value: root.tank ? root.tank.level / 100 : NaN
					isGrouped: false
					surfaceColor: root.backgroundColor
				}
			}

			Component {
				id: gaugeGroupComponent

				Flow {
					spacing: Theme.geometry_levelsGauge_gauge_spacing

					Repeater {
						model: root.tankModel
						delegate: TankGauge {
							required property BaseTankDevice device

							width: Theme.screenSize === Theme.Portrait
								   ? parent.width
								   : Math.floor((parent.width - (parent.spacing * (root.tankModel.count - 1))) / root.tankModel.count)
							height: Theme.screenSize === Theme.Portrait
									? Theme.geometry_barGauge_horizontal_height
									: parent.height
							orientation: Theme.screenSize === Theme.Portrait ? Qt.Horizontal : Qt.Vertical
							expanded: !!Global.pageManager && Global.pageManager.expandLayout
							animationEnabled: root.animationEnabled
							valueType: root.tankProperties.valueType
							value: device.level / 100
							isGrouped: true
							surfaceColor: root.backgroundColor
						}
					}
				}
			}
		}

		Label {
			id: capacityLabel

			anchors {
				bottom: parent.bottom
				left: levelsGauge.left
				leftMargin: Theme.screenSize !== Theme.Portrait ? 0
					: Theme.geometry_icon_size_medium + Theme.geometry_levelsGauge_horizontalSpacing
				right: parent.right
			}
			topPadding: Theme.geometry_levelsGauge_capacity_topPadding
			height: opacity > 0 || Theme.screenSize !== Theme.Portrait ? implicitHeight : 0
			horizontalAlignment: Theme.screenSize === Theme.Portrait ? Text.AlignLeft : Text.AlignHCenter
			fontSizeMode: Text.HorizontalFit
			font.pixelSize: Theme.font_levelsGauge_secondary
			color: Theme.color_font_secondary
			opacity: isNaN(root.totalCapacity) && isNaN(root.totalRemaining) ? 0.0 : 1.0
			text: Units.getCapacityDisplayText(Global.systemSettings.volumeUnit, root.totalCapacity, root.totalRemaining)
		}
	}
}
