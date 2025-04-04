/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property VeQuickItemsQuotient gps
	required property VeQuickItemsQuotient systemDcLoad
	required property MotorDrive motorDrive

	property bool animationEnabled: false

	readonly property VeQuickItemsQuotient motorDriveDcConsumption: motorDrive ? motorDrive.dcConsumption : null
	readonly property VeQuickItemsQuotient activeDataSource: gps.valid
															 ? gps
															 : motorDriveDcConsumption.valid
															   ? motorDriveDcConsumption
															   : systemDcLoad.valid
																 ? systemDcLoad
																 : null

	anchors.fill: parent
	objectName: "LargeCenterGauge"
	onActiveDataSourceChanged: console.log(objectName, "dataSource:", activeDataSource ? activeDataSource.objectName : "null")

	ProgressArc {
		id: centerGauge

		readonly property real _angularRange: endAngle - startAngle

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_centerGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: Theme.geometry_boatPage_centerGauge_rotation
		width: Theme.geometry_boatPage_centerGauge_width
		height: width
		radius: width/2
		startAngle: Theme.geometry_boatPage_centerGauge_startAngle
		endAngle: Theme.geometry_boatPage_centerGauge_endAngle
		value: activeDataSource ? activeDataSource.percentage : 0
		strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
		animationEnabled: root.animationEnabled
		objectName: "centerGauge"
		visible: activeDataSource === gps

		Rectangle {
			id: needle
			anchors {
				bottom: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}

			width: centerGauge.strokeWidth
			height: Theme.geometry_boatPage_centerGauge_needleHeight - radius / 2
			radius: width / 2
			color: Theme.color_boatPage_background
			transformOrigin: Item.Bottom
			rotation: parent.progressAnimatedEndAngle

			Rectangle {
				anchors {
					top: parent.top
					topMargin: radius
					horizontalCenter: parent.horizontalCenter
				}
				width: Theme.geometry_boatPage_centerGauge_innerNeedleWidth
				height: Theme.geometry_boatPage_centerGauge_innerNeedleHeight
				radius: width / 2
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: Theme.color_boatPage_needle
					}
					GradientStop {
						position: 0.4
						color: Theme.color_boatPage_needle
					}
					GradientStop {
						position: 0.6
						color: "transparent"
					}
					GradientStop {
						position: 1
						color: "transparent"
					}
				}
			}
		}
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_primary
		font.pixelSize: Theme.font_boatPage_speed_pixelSize
		font.weight: Font.Medium
		visible: activeDataSource === gps
		text: Math.round(gps.speed)
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedUnitsLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		visible: activeDataSource === gps
		text: gps.units
	}

	ProgressArc {
		id: rpmGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: centerGauge.rotation
		width: Theme.geometry_boatPage_rpmGauge_width
		height: width
		radius: width/2
		startAngle: centerGauge.startAngle
		endAngle: centerGauge.endAngle
		value: motorDrive ? motorDrive.rpm.percentage : 0
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: root.animationEnabled
		visible: motorDrive.rpm.valid
	}

	Label {
		id: minRpm

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_minmax_topMargin
			left: centerGauge.left
			leftMargin: Theme.geometry_boatPage_rpmGauge_minmax_leftMargin
		}

		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_boatPage_rpm_min_max_pixelSize
		text: "0"
		visible: rpmGauge.visible
	}

	Label {
		id: maxRpm

		anchors {
			top: minRpm.top
			right: centerGauge.right
			rightMargin: Theme.geometry_boatPage_rpmGauge_minmax_rightMargin
		}

		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_boatPage_rpm_min_max_pixelSize
		text: motorDrive ? motorDrive.rpm.denominator : ""
		visible: rpmGauge.visible
	}

	Label {
		id: rpmLabel

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_motorDrive_temperatures_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: rpmGauge.visible
		verticalAlignment: Text.AlignVCenter
		topPadding: Theme.geometry_boatPage_rpmLabel_topPadding
		font.pixelSize: Theme.font_size_h1
		text: Math.abs(motorDrive.rpm.numerator)
	}

	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmText_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: rpmLabel.visible
		verticalAlignment: Text.AlignVCenter
		font.pixelSize: Theme.font_size_body2
		color: Theme.color_font_secondary
		//% "RPM"
		text: qsTrId("boat_page_rpm")
	}
}
