/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Boat as Boat

Item {
	id: root

	required property Gps gps
	required property MotorDrives motorDrives
	required property bool isBatteryCharging

	required property bool animationEnabled

	readonly property VeQuickItemsQuotient motorDriveDcConsumption: root.motorDrives.dcConsumption.quotient
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
		value: root.activeDataSource ? Math.abs(root.activeDataSource.percentage) : 0
		strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
		animationEnabled: root.animationEnabled
		progressColor: root.activeDataSource === root.motorDriveDcConsumption && root.motorDrives.isRegenerating ? Theme.color_boatPage_regenProgress : Theme.color_ok
		remainderColor: root.activeDataSource === root.motorDriveDcConsumption && root.motorDrives.isRegenerating ? Theme.color_boatPage_regenRemainder : Theme.color_darkOk
		objectName: "centerGauge"
		visible: root.activeDataSource === root.gps || root.activeDataSource === root.motorDriveDcConsumption

		layer.enabled: !UiConfig.msaaEnabled
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

	ProgressArc {
		id: batteryOuterGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_centerGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: 0
		width: Theme.geometry_boatPage_centerGauge_width
		height: width
		radius: width/2
		endAngle: 360
		value: Global.system.battery.stateOfCharge
		strokeWidth: Theme.geometry_boatPage_centerGauge_strokeWidth
		animationEnabled: root.animationEnabled
		progressColor: root.isBatteryCharging ? Theme.color_boatPage_regenProgress : Theme.color_ok
		remainderColor: root.isBatteryCharging ? Theme.color_boatPage_regenRemainder : Theme.color_darkOk
		objectName: "batteryCenterGauge"
		visible: root.activeDataSource === null && !isNaN(Global.system.battery.stateOfCharge)

		layer.enabled: !UiConfig.msaaEnabled
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true
	}

	// Gear indicators
	Item {
		anchors {
			top: outerGauge.top
			topMargin: Theme.geometry_boatPage_gearIndicator_topMargin
			horizontalCenter: outerGauge.horizontalCenter
		}

		Boat.Gear {
			anchors.horizontalCenter: parent.horizontalCenter
			motorDrive: motorDrives.singleMotorDrive
		}

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: Theme.geometry_boatPage_gearIndicator_spacing
			visible: motorDrives.left !== null && motorDrives.right !== null

			Boat.Gear {
				motorDrive: motorDrives.leftMotorDrive
			}

			Boat.Gear {
				motorDrive: motorDrives.rightMotorDrive
			}
		}
	}

	// GPS speed or DC consumption or battery details
	Column {
		anchors {
			verticalCenter: outerGauge.verticalCenter
			horizontalCenter: outerGauge.horizontalCenter
		}

		Label {
			id: gpsSpeed

			visible: root.activeDataSource === root.gps
			anchors.horizontalCenter: parent.horizontalCenter
			width: rpmGauge.width - rpmGauge.radius/2
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			color: Theme.color_font_primary
			font.pixelSize: Theme.font_boatPage_speed_pixelSize
			font.weight: Font.Medium
			text: Units.formatNumber(root.gps.numerator, Math.round(root.gps.numerator * 10) >= 100 ? 0 : 1)
			height: font.pixelSize
		}

		Label {
			visible: gpsSpeed.visible
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry_boatPage_speedUnits_topPadding
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_speedUnits_pixelSize
			color: Theme.color_font_secondary
			text: root.gps.units
		}

		ElectricalQuantityLabel {
			anchors.horizontalCenter: parent.horizontalCenter
			width: rpmGauge.width - rpmGauge.radius/2
			font.pixelSize: Theme.font_boatPage_centerGauge_consumption_pixelSize
			visible: root.activeDataSource === root.motorDriveDcConsumption
			sourceType: VenusOS.ElectricalQuantity_Source_Dc
			dataObject: motorDrives.dcConsumption.scalar
		}

		Row {
			visible: batteryOuterGauge.visible
			anchors.horizontalCenter: parent.horizontalCenter
			bottomPadding: Theme.geometry_boatPage_batteryCenterGauge_title_bottomPadding

			spacing: Theme.geometry_boatPage_batteryCenterGauge_title_spacing

			CP.ColorImage {
				anchors.verticalCenter: batteryLabel.verticalCenter
				height: Theme.geometry_boatPage_batteryCenterGauge_title_iconHeight
				width: height
				color: Theme.color_font_primary
				source: root.isBatteryCharging
					? "qrc:/images/icon_battery_charging_24.svg"
					: "qrc:/images/icon_battery_24.svg"
			}

			Label {
				id: batteryLabel

				verticalAlignment: Text.AlignVCenter
				height: font.pixelSize
				font.pixelSize: Theme.font_boatPage_batteryCenterGauge_title_pixelSize
				color: Theme.color_font_primary
				text: CommonWords.battery
			}
		}


		QuantityLabel {
			id: batteryStateOfCharge

			visible: batteryOuterGauge.visible
			anchors.horizontalCenter: parent.horizontalCenter
			width: rpmGauge.width - rpmGauge.radius/2
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_batteryCenterGauge_percentage_pixelSize
			font.weight: Font.Medium
			unit: VenusOS.Units_Percentage
			value: Global.system.battery.stateOfCharge
		}

		Row {
			visible: batteryOuterGauge.visible
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry_boatPage_batteryCenterGauge_detailsRow_topPadding

			spacing: Theme.geometry_boatPage_batteryCenterGauge_detailsRow_spacing

			QuantityLabel {
				value: Global.system.battery.voltage
				unit: VenusOS.Units_Volt_DC
				valueColor: Theme.color_font_secondary
				unitColor: Theme.color_font_secondary
				font.pixelSize: Theme.font_boatPage_batteryCenterGauge_detailsRow_pixelSize
				height: font.pixelSize
			}

			ElectricalQuantityLabel {
				sourceType: VenusOS.ElectricalQuantity_Source_Dc
				dataObject: Global.system.battery
				valueColor: Theme.color_font_secondary
				unitColor: Theme.color_font_secondary
				font.pixelSize: Theme.font_boatPage_batteryCenterGauge_detailsRow_pixelSize
				height: font.pixelSize
			}
		}

		Label {
			visible: batteryOuterGauge.visible
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry_boatPage_batteryCenterGauge_mode_topPadding
			opacity: root.isBatteryCharging ? 1 : 0
			text: VenusOS.battery_modeToText(Global.system.battery.mode)
			elide: Text.ElideRight
			color: Theme.color_boatPage_regenProgress
			font.pixelSize: Theme.font_boatPage_batteryCenterGauge_mode_pixelSize
			height: font.pixelSize
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
		value: root.motorDrives.singleMotorDrive.rpm.percentage
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: root.animationEnabled
		visible: root.motorDrives.singleMotorDrive.rpm.valid

		layer.enabled: !UiConfig.msaaEnabled
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true
	}

	ProgressArc {
		id: leftRpmGauge

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
		endAngle: outerGauge.startAngle + Theme.geometry_boatPage_dualRpmGauge_spanAngle
		value: root.motorDrives.leftMotorDrive.rpm.percentage
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: root.animationEnabled
		visible: root.motorDrives.leftMotorDrive.rpm.valid

		layer.enabled: !UiConfig.msaaEnabled
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true
	}

	ProgressArc {
		id: rightRpmGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_rpmGauge_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		rotation: outerGauge.rotation
		direction: PathArc.Counterclockwise
		width: Theme.geometry_boatPage_rpmGauge_width
		height: width
		radius: width/2
		startAngle: outerGauge.endAngle
		endAngle: outerGauge.endAngle - Theme.geometry_boatPage_dualRpmGauge_spanAngle
		value: root.motorDrives.rightMotorDrive.rpm.percentage
		strokeWidth: Theme.geometry_boatPage_rpmGauge_strokeWidth
		animationEnabled: root.animationEnabled
		visible: root.motorDrives.rightMotorDrive.rpm.valid

		layer.enabled: !UiConfig.msaaEnabled
		layer.textureSize: Qt.size(2*width, 2*height)
		layer.smooth: true
	}

	Column {
		id: singleRpmLabel

		anchors {
			horizontalCenter: rpmGauge.horizontalCenter
			bottom: rpmGauge.bottom
			bottomMargin: Theme.geometry_boatPage_singleRpmLabel_bottomMargin
		}
		width: 2 * rpmGauge.radius * Math.sin(((outerGauge.endAngle - outerGauge.startAngle) * Math.PI / 180) / 2)
		visible: rpmGauge.visible

		spacing: Theme.geometry_boatPage_singleRpmLabel_spacing

		Label {
			anchors.horizontalCenter: parent.horizontalCenter
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_rpm_value_pixelSize
			text: Units.formatNumber(Math.abs(root.motorDrives.singleMotorDrive.rpm._numerator.value))
		}

		Label {
			id: singleRpmUnitLabel

			anchors.horizontalCenter: parent.horizontalCenter
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_rpm_label_pixelSize
			color: Theme.color_font_secondary
			//% "RPM"
			text: qsTrId("boat_page_rpm")
		}
	}

	Item {
		id: dualRpmLabels

		anchors {
			horizontalCenter: leftRpmGauge.horizontalCenter
			bottom: leftRpmGauge.bottom
			bottomMargin: Theme.geometry_boatPage_dualRpmLabels_bottomMargin
		}
		width: 2 * leftRpmGauge.radius * Math.sin(((outerGauge.endAngle - outerGauge.startAngle) * Math.PI / 180) / 2)
		implicitHeight: leftRpmLabel.height
		visible: leftRpmGauge.visible && rightRpmGauge.visible

		Label {
			id: leftRpmLabel

			anchors {
				right: parent.horizontalCenter
				rightMargin: Theme.geometry_boatPage_dualRpmLabel_margin
			}
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_rpm_value_pixelSize
			text: Units.formatNumber(Math.abs(root.motorDrives.leftMotorDrive.rpm._numerator.value))
		}

		Label {
			id: dualRpmLabel

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: leftRpmLabel.bottom
			}

			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_rpm_label_pixelSize
			color: Theme.color_font_secondary
			text: singleRpmUnitLabel.text
			visible: leftRpmGauge.visible && rightRpmGauge.visible
		}

		Label {
			id: rightRpmLabel

			anchors {
				left: parent.horizontalCenter
				leftMargin: Theme.geometry_boatPage_dualRpmLabel_margin
			}
			verticalAlignment: Text.AlignVCenter
			height: font.pixelSize
			font.pixelSize: Theme.font_boatPage_rpm_value_pixelSize
			text: Units.formatNumber(Math.abs(root.motorDrives.rightMotorDrive.rpm._numerator.value))
		}
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
		decimals: 0
	}
}
