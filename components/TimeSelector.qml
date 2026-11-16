/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Displays spin boxes for selecting a time.

	Landscape layout:
	| Hour : Minute |

	Portrait layout:
	|  Hour  |
	| Minute |
*/
FocusScope {
	id: root

	property alias hour: hrSpinbox.value
	property alias minute: minSpinbox.value
	property alias second: secSpinbox.value

	property bool showMinuteSecondOnly: false

	property int maximumHour: 23
	property int maximumMinute: 59
	property int maximumSecond: 59

	implicitWidth: contentLayout.implicitWidth
	implicitHeight: contentLayout.implicitHeight

	GridLayout {
		id: contentLayout

		anchors.centerIn: parent
		columns: Theme.screenSize === Theme.Portrait ? 1 : 3
		columnSpacing: Theme.geometry_modalDialog_content_spacing
		rowSpacing: Theme.geometry_modalDialog_content_spacing

		SpinBox {
			id: hrSpinbox

			from: 0
			to: root.maximumHour
			//: Hours
			//% "hr"
			secondaryText: qsTrId("timeselector_hr")
			textFromValue: (value, locale) => Utils.pad(value, 2)

			// Use BeforeItem priority to override the default key Spinbox event handling, else
			// up/down keys will modify the number even when SpinBox is not in "edit" mode.
			focus: !root.showMinuteSecondOnly
			visible: !root.showMinuteSecondOnly
			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.right: minSpinbox
		}

		Label {
			text: ":"
			color: root.enabled ? Theme.color_font_secondary : Theme.color_background_disabled
			font.pixelSize: Theme.font_dialog_control_largeSize
			visible: !root.showMinuteSecondOnly && Theme.screenSize !== Theme.Portrait
			horizontalAlignment: Text.AlignHCenter
		}

		SpinBox {
			id: minSpinbox

			from: 0
			to: root.maximumMinute
			//: Minutes
			//% "min"
			secondaryText: qsTrId("timeselector_min")
			textFromValue: (value, locale) => Utils.pad(value, 2)

			focus: root.showMinuteSecondOnly
			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.left: hrSpinbox
		}

		Label {
			text: ":"
			color: root.enabled ? Theme.color_font_secondary : Theme.color_background_disabled
			font.pixelSize: Theme.font_dialog_control_largeSize
			visible: root.showMinuteSecondOnly && Theme.screenSize !== Theme.Portrait
			horizontalAlignment: Text.AlignHCenter
		}

		SpinBox {
			id: secSpinbox

			from: 0
			to: root.maximumSecond
			//: Seconds
			//% "sec"
			secondaryText: qsTrId("timeselector_sec")
			textFromValue: (value, locale) => Utils.pad(value, 2)
			visible: root.showMinuteSecondOnly

			KeyNavigation.priority: KeyNavigation.BeforeItem
			KeyNavigation.up: root.KeyNavigation.up
			KeyNavigation.down: root.KeyNavigation.down
			KeyNavigation.left: minSpinbox
		}
	}
}
