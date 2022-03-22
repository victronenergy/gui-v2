import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	enum Size {
		Compact,
		Expanded
	}

	property alias title: titleLabel.text
	property real temperature: NaN
	property real humidity: NaN
	property int horizontalSize: EnvironmentGaugePanel.Size.Expanded
	property int verticalSize: EnvironmentGaugePanel.Size.Expanded

	readonly property int compactWidth: _twoGauges
		? Theme.geometry.levelsPage.environment.gaugePanel.twoGauge.compact.width
		: Theme.geometry.levelsPage.environment.gaugePanel.oneGauge.compact.width
	readonly property int compactHeight: Theme.geometry.levelsPage.environment.gaugePanel.compact.height
	readonly property int expandedWidth: _twoGauges
		? Theme.geometry.levelsPage.environment.gaugePanel.twoGauge.expanded.width
		: Theme.geometry.levelsPage.environment.gaugePanel.oneGauge.expanded.width
	readonly property int expandedHeight: Theme.geometry.levelsPage.environment.gaugePanel.expanded.height

	readonly property int _twoGauges: !isNaN(temperature) && !isNaN(humidity)

	width: horizontalSize === EnvironmentGaugePanel.Size.Expanded ? expandedWidth : compactWidth
	height: verticalSize === EnvironmentGaugePanel.Size.Expanded ? expandedHeight : compactHeight

	color: Theme.color.background.disabled
	radius: Theme.geometry.levelsPage.environment.gaugePanel.radius

	Behavior on height {
		NumberAnimation { duration: Theme.animation.page.idleResize.duration; easing.type: Easing.InOutQuad }
	}

	Rectangle {
		anchors {
			top: parent.top
			topMargin: Theme.geometry.levelsPage.environment.gaugePanel.title.height
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			bottom: parent.bottom
			bottomMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
		}
		radius: Theme.geometry.levelsPage.environment.gaugePanel.radius
		color: Theme.color.background.secondary
	}

	Label {
		id: titleLabel

		width: parent.width
		height: Theme.geometry.levelsPage.environment.gaugePanel.title.height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		leftPadding: Theme.geometry.levelsPage.environment.gaugePanel.border.width
		rightPadding: Theme.geometry.levelsPage.environment.gaugePanel.border.width

		font.pixelSize: Theme.font.size.xs
		color: Theme.color.font.primary
		elide: Text.ElideRight
	}

	EnvironmentGauge {
		id: tempGauge

		anchors {
			top: titleLabel.bottom
			left: parent.left
			leftMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			bottom: parent.bottom
		}

		icon.source: "qrc:/images/icon_temp_32.svg"
		//: Abbreviation of "Celsius"
		//% "C"
		text: qsTrId("environment_gauge_celsius")
		physicalQuantity: Units.Temperature
		value: Math.round(root.temperature)
		zeroMarkerVisible: true
		reduceFontSize: root._twoGauges && root.horizontalSize === EnvironmentGaugePanel.Size.Compact
		minimumValue: Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue
		maximumValue: Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue

		gradient: Gradient {
			GradientStop {
				position: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.position1
				color: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.color1
			}
			GradientStop {
				position: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.position2
				color: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.color2
			}
			GradientStop {
				position: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.position3
				color: Theme.geometry.levelsPage.environment.temperatureGauge.gradient.color3
			}
		}
	}

	Loader {
		anchors {
			top: titleLabel.bottom
			right: parent.right
			rightMargin: Theme.geometry.levelsPage.environment.gaugePanel.border.width
			bottom: parent.bottom
		}

		active: !isNaN(root.humidity)
		sourceComponent: EnvironmentGauge {
			id: humidityGauge

			icon.source: "qrc:/images/icon_humidity_32.svg"
			//: Abbreviation of "Room Humidity"
			//% "RH"
			text: qsTrId("environment_gauge_humidity")
			physicalQuantity: Units.Percentage
			value: Math.round(root.humidity)
			zeroMarkerVisible: false
			reduceFontSize: root._twoGauges && root.horizontalSize === EnvironmentGaugePanel.Size.Compact
			minimumValue: Theme.geometry.levelsPage.environment.humidityGauge.minimumValue
			maximumValue: Theme.geometry.levelsPage.environment.humidityGauge.maximumValue

			gradient: Gradient {
				GradientStop {
					position: Theme.geometry.levelsPage.environment.humidityGauge.gradient.position1
					color: Theme.geometry.levelsPage.environment.humidityGauge.gradient.color1
				}
				GradientStop {
					position: Theme.geometry.levelsPage.environment.humidityGauge.gradient.position2
					color: Theme.geometry.levelsPage.environment.humidityGauge.gradient.color2
				}
				GradientStop {
					position: Theme.geometry.levelsPage.environment.humidityGauge.gradient.position3
					color: Theme.geometry.levelsPage.environment.humidityGauge.gradient.color3
				}
			}
		}
	}

}
