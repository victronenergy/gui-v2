/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	required property VeQuickItemsQuotient gps
	required property MotorDrive motorDrive

	property bool animationEnabled: false

	readonly property VeQuickItemsQuotient motorDriveDcConsumption: root.motorDrive ? root.motorDrive.dcConsumption.quotient : null
	readonly property VeQuickItemsQuotient activeDataSource: root.gps.valid ? root.gps
			: root.motorDriveDcConsumption.valid ? root.motorDriveDcConsumption
			: null

	objectName: "LargeCenterGauge"

	ProgressArc {
		id: outerGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_centerGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: -Theme.geometry_boatPage_centerGauge_angularRange / 2
		width: Theme.geometry_boatPage_centerGauge_width
		height: width
		radius: width/2
		endAngle: Theme.geometry_boatPage_centerGauge_angularRange
		value: root.activeDataSource ? root.activeDataSource.percentage : 0
		strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
		animationEnabled: root.animationEnabled
		objectName: "centerGauge"
		visible: root.activeDataSource === root.gps || root.activeDataSource === root.motorDriveDcConsumption
		layer.enabled: true
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true

		Rectangle {
			id: needle
			anchors {
				bottom: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}

			width: outerGauge.strokeWidth
			height: Theme.geometry_boatPage_centerGauge_needleHeight - radius / 2
			radius: width / 2
			// https://github.com/victronenergy/gui-v2/issues/2158
			// The boat page has a different background color to other pages when in 'Light Mode'
			// If we set the needle color to Theme.color_boatPage_background (which is the same as the boat page background color)
			// it looks fine usually, but when we change pages to eg. SettingsPage, the background color changes to
			// SettingsPage.backgroundColor (slightly darker) for ~0.5 seconds while the boat page is still visible,
			// making this needle color 'pop' out of the background briefly.
			color: (Global.mainView && Global.mainView.currentPage) ? Global.mainView.currentPage.backgroundColor : "transparent"
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
				}
			}
		}
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_speedLabel_topMargin
			horizontalCenter: parent.horizontalCenter
		}

		Label {
			id: gpsSpeed

			anchors.horizontalCenter: parent.horizontalCenter
			width: rpmGauge.width - rpmGauge.radius/2
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: motorDriveGauges.visible || rpmLabel.visible
							? Theme.font_boatPage_speed_pixelSize
							: Theme.font_boatPage_speed_pixelSize_large
			font.weight: Font.Medium
			fontSizeMode: Text.HorizontalFit
			visible: root.activeDataSource === root.gps
			text: root.gps.numerator >= 10.0 ? Math.round(root.gps.numerator) : Units.formatNumber(root.gps.numerator, 1)
			height: font.pixelSize
		}

		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry_boatPage_speedUnits_topPadding
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_secondary
			visible: gpsSpeed.visible
			text: root.gps.units
		}

		MotorDriveGauges {
			id: motorDriveGauges

			topPadding: Theme.geometry_boatPage_motorDriveGauges_topPadding
			motorDrive: root.motorDrive
			showDcConsumption: !root.gps.valid
			visible: root.activeDataSource === root.motorDriveDcConsumption ||
					 (root.activeDataSource === null && root.motorDrive.rpm.valid)
		}

		Label {
			id: rpmLabel

			anchors.horizontalCenter: parent.horizontalCenter
			verticalAlignment: Text.AlignVCenter
			topPadding: Theme.geometry_boatPage_rpmLabel_topPadding
			font.pixelSize: Theme.font_size_h1
			text: Math.abs(root.motorDrive.rpm._numerator.value)
			visible: root.motorDrive && root.motorDrive.rpm.numeratorUid && !isNaN(root.motorDrive.rpm.numerator)
		}

		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry_boatPage_rpmTitle_topPadding
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_font_secondary
			//% "RPM"
			text: qsTrId("boat_page_rpm")
			visible: rpmLabel.visible
		}
	}

	ProgressArc {
		id: rpmGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: outerGauge.rotation
		width: Theme.geometry_boatPage_rpmGauge_width
		height: width
		radius: width/2
		startAngle: outerGauge.startAngle
		endAngle: outerGauge.endAngle
		value: root.motorDrive ? root.motorDrive.rpm.percentage : 0
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: root.animationEnabled
		visible: root.motorDrive.rpm.valid
		layer.enabled: true
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true
	}

	Label {
		id: outerGaugeMin

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_minmax_topMargin
			left: outerGauge.left
			leftMargin: Theme.geometry_boatPage_rpmGauge_minmax_leftMargin
		}

		verticalAlignment: Text.AlignVCenter
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_boatPage_rpm_min_max_pixelSize
		text: "0"
		visible: outerGaugeMax.visible
	}

	QuantityLabel {
		id: outerGaugeMax

		anchors {
			top: outerGaugeMin.top
			right: outerGauge.right
			rightMargin: Theme.geometry_boatPage_rpmGauge_minmax_rightMargin
		}
		valueColor: Theme.color_font_secondary
		font.pixelSize: Theme.font_boatPage_rpm_min_max_pixelSize
		visible: root.activeDataSource && root.activeDataSource.valid && outerGauge.visible
		value: root.activeDataSource ? root.activeDataSource.denominator : 0
		unit: root.activeDataSource ? root.activeDataSource.displayUnit : 0
		unitText: ""
		precision: 0
	}
}
