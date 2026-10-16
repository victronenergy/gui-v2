/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "IOChannelShowDetailsTest"

	readonly property string showUiUid: "mock/com.victronenergy.test.a/SwitchableOutput/1/Settings/ShowUIControl"

	ListIOChannelShowDetails {
		id: showDetails
		capabilitiesUid: ""
		showUiUid: root.showUiUid
	}

	function test_calculatedShowUiControlValue_data() {
		return [
			// Toggling a platform switch on.
			{
				tag: "Off, turn on Local",
				currentValue: VenusOS.IOChannel_ShowUI_Off,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Local,
			},
			{
				tag: "Off, turn on Remote",
				currentValue: VenusOS.IOChannel_ShowUI_Off,
				platformBit: VenusOS.IOChannel_ShowUI_Remote,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Remote,
			},
			{
				tag: "Off, turn on Watch",
				currentValue: VenusOS.IOChannel_ShowUI_Off,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Local, turn on Remote",
				currentValue: VenusOS.IOChannel_ShowUI_Local,
				platformBit: VenusOS.IOChannel_ShowUI_Remote,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Remote,
			},
			{
				tag: "Remote, turn on Watch",
				currentValue: VenusOS.IOChannel_ShowUI_Remote,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Remote | VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Local+Remote, turn on Watch -> Always",
				currentValue: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Remote,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Always,
			},
			{
				tag: "Local+Watch, turn on Remote -> Always",
				currentValue: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Watch,
				platformBit: VenusOS.IOChannel_ShowUI_Remote,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Always,
			},
			{
				tag: "Remote+Watch, turn on Local -> Always",
				currentValue: VenusOS.IOChannel_ShowUI_Remote | VenusOS.IOChannel_ShowUI_Watch,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: false,
				expected: VenusOS.IOChannel_ShowUI_Always,
			},

			// Toggling a platform switch off.
			{
				tag: "Always, turn off Local",
				currentValue: VenusOS.IOChannel_ShowUI_Always,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Remote | VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Always, turn off Remote",
				currentValue: VenusOS.IOChannel_ShowUI_Always,
				platformBit: VenusOS.IOChannel_ShowUI_Remote,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Always, turn off Watch",
				currentValue: VenusOS.IOChannel_ShowUI_Always,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Remote,
			},
			{
				tag: "AllPlatforms, turn off Local",
				currentValue: VenusOS.IOChannel_ShowUI_AllPlatforms,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Remote | VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Always+AllPlatforms, turn off Remote",
				currentValue: VenusOS.IOChannel_ShowUI_Always | VenusOS.IOChannel_ShowUI_AllPlatforms,
				platformBit: VenusOS.IOChannel_ShowUI_Remote,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Watch,
			},
			{
				tag: "Local+Remote, turn off Local",
				currentValue: VenusOS.IOChannel_ShowUI_Local | VenusOS.IOChannel_ShowUI_Remote,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Remote,
			},
			{
				tag: "Remote+Watch, turn off Watch",
				currentValue: VenusOS.IOChannel_ShowUI_Remote | VenusOS.IOChannel_ShowUI_Watch,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Remote,
			},
			{
				tag: "Local, turn off Local -> Off",
				currentValue: VenusOS.IOChannel_ShowUI_Local,
				platformBit: VenusOS.IOChannel_ShowUI_Local,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Off,
			},
			{
				tag: "Watch, turn off Watch -> Off",
				currentValue: VenusOS.IOChannel_ShowUI_Watch,
				platformBit: VenusOS.IOChannel_ShowUI_Watch,
				switchCurrentlyOn: true,
				expected: VenusOS.IOChannel_ShowUI_Off,
			},
		]
	}

	function test_calculatedShowUiControlValue(data) {
		MockManager.setValue(root.showUiUid, data.currentValue)
		compare(showDetails.calculatedShowUiControlValue(data.platformBit, data.switchCurrentlyOn), data.expected)
	}
}
