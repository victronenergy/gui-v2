/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property VeQuickItem _deviceOffReason: VeQuickItem {
		id: deviceOffReason
		uid: bindPrefix + "/DeviceOffReason"
	}

	property var _titles: [
		//% "#OR1: Insufficient PV Power",
		qsTrId("device_off_reason_1_title"),
		//% "#OR2: Settings being edited on external display",
		qsTrId("device_off_reason_2_title"),
		//% "#OR3: Disabled in Settings",
		qsTrId("device_off_reason_3_title"),
		//% "#OR4: Disabled by remote or BMS"
		qsTrId("device_off_reason_4_title")]

	property var _icons: ["qrc:/images/icon_info_32.svg", "qrc:/images/icon_switchdev_32.svg", "qrc:/images/icon_controls_on_32.svg", "qrc:/images/icon_vrm_32.svg"]

	property var _descriptions: [
		//% "The charger is off because there is no or not enough PV power.\nThis is the expected during night time and doesn't indicate any problem."
		qsTrId("device_off_reason_1_description"),
		//% "Charge is disable when using the MPPT\nControl external display to make configuration changes."
		qsTrId("device_off_reason_2_description"),
		//% "The charger has been disabled in the settings."
		qsTrId("device_off_reason_3_description"),
		//% "The charger has been switched off via either by its Remote on/off input or a special VE.Direct remote on/off cable.\nFor systems with Lithium batteries and a BMS, this is common and usually means that the BMS has disabled the charger because the batteries are fully charged. Charging will automatically resume when necessary."
		qsTrId("device_off_reason_4_description")]

	GradientListView {
		model: 4
		delegate: ListItem {
			preferredVisible: deviceOffReason.value & (1 << model.index)

			contentItem: GridLayout {
				columns: 2
				columnSpacing: 5

				CP.ColorImage {
					id: icon1
					source: root._icons[model.index]
					color: Theme.color_blue
				}
				Label {
					text: root._titles[model.index]
					color: Theme.color_font_primary
					font.pixelSize: Theme.font_size_body2
					wrapMode: Text.Wrap
					Layout.preferredWidth: Theme.geometry_listItem_width - icon1.width
				}
				Item {}
				Text {
					text: root._descriptions[model.index]
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_body1
					wrapMode: Text.Wrap
					Layout.preferredWidth: Theme.geometry_listItem_width - icon1.width
				}
			}
		}
	}
}
