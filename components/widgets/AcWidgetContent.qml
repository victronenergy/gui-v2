/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

GridLayout {
	id: root

	required property AcWidget widget
	required property string iconSource

	property string stateText // if widget.quantityDataObject=null, this is shown instead of QuantityLabel
	property int gaugeValueType: VenusOS.Gauges_ValueType_NeutralPercentage
	property int gaugeMaximumValue

	readonly property bool _effectiveStretchHorizontally: widget.stretchHorizontally && !!widget.quantityDataObject

	columnSpacing: 0
	rowSpacing: Theme.geometry_overviewPage_widget_content_spacing
	columns: root._effectiveStretchHorizontally ? 2 : 1
	rows: root._effectiveStretchHorizontally ? 2 : 3
	flow: GridLayout.TopToBottom

	WidgetHeader {
		text: root.widget.title
		icon.source: root.iconSource

		Layout.fillWidth: true
	}

	Loader {
		sourceComponent: !!root.widget.quantityDataObject
			// Show the quantity label if it is available and the widget size is > XS.
			// For size XS, we still want to show the quantity label if there are no phases.
			? (root.widget.size > VenusOS.OverviewWidget_Size_XS || (!!root.widget.quantityDataObject && !root.widget.phaseModel)
				? quantityLabelComponent
				: null)
			: stateLabelComponent
		visible: status !== Loader.Null

		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.preferredWidth: root._effectiveStretchHorizontally
				? (parent.width/2 + Theme.geometry_overviewPage_widget_spacing)  // push phases to the right
				: -1
		Layout.alignment: Qt.AlignTop

		Component {
			id: quantityLabelComponent

			ElectricalQuantityLabel {
				leftPadding: acInputDirectionIcon.visible ? (acInputDirectionIcon.width + Theme.geometry_acInputDirectionIcon_rightMargin) : 0
				alignment: Qt.AlignLeft
				sourceType: root.widget.quantitySourceType
				dataObject: root.widget.quantityDataObject
				font.pixelSize: root.widget.size === VenusOS.OverviewWidget_Size_XS ? Theme.font_overviewPage_widget_quantityLabel_small
					: root.widget.size === VenusOS.OverviewWidget_Size_S
						 ? root.widget.phaseModel?.count > 1
							? Theme.font_overviewPage_widget_quantityLabel_tiny // allow space for 3-phase metrics
							: Theme.font_overviewPage_widget_quantityLabel_large
					: root.widget.size === VenusOS.OverviewWidget_Size_M
						? root.widget.phaseModel?.count > 1
							? Theme.font_overviewPage_widget_quantityLabel_medium
							: Theme.font_overviewPage_widget_quantityLabel_large
					// Size L and XL
					: Theme.font_overviewPage_widget_quantityLabel_large

				AcInputDirectionIcon {
					id: acInputDirectionIcon
					y: parent.implicitHeight/2 - height/2 // vertically centre on the first line, not the stretched label height
					input: root.widget.input
				}
			}

		}

		Component {
			id: stateLabelComponent

			Label {
				id: stateLabel

				topPadding: Theme.geometry_overviewPage_widget_content_topMargin
				elide: Text.ElideRight
				text: root.stateText
				font.pixelSize: root.widget.secondaryFontSize
			}
		}
	}

	ThreePhaseDisplay {
		model: root.widget.phaseModel
		widgetSize: root.widget.size
		inputMode: !!root.widget.input
		valueType: root.gaugeValueType
		maximumValue: root.gaugeMaximumValue
		fontPixelSize: root.widget.tertiaryFontSize

		Layout.fillWidth: true
		Layout.rowSpan: root._effectiveStretchHorizontally ? parent.rows : 1
		Layout.alignment: Qt.AlignBottom
	}
}
