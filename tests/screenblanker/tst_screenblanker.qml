/*
 * Copyright (C) 2024 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtTest
import Victron.VenusOS

TestCase {
	name: "ScreenBlanker"

	ScreenBlanker {
		id: blanker
		displayOffTime: 100
	}

	SignalSpy {
		id: spy
		target: blanker
		signalName: "clicked"
	}

	function test_blanker() {
		compare(blanker.supported, true)
		compare(blanker.enabled, true)
		compare(blanker.displayOffTime, 100)

		// Reset display off timeout
		blanker.setDisplayOn()

		// Wait for the display off timeout to blank the screen
		let startTime = new Date()
		wait(90)
		tryCompare(blanker, "blanked", false)

		// Wait a bit more
		tryCompare(blanker, "blanked", true)
		let endTime = new Date();

		// Check the timeout roughly follows the display off time
		fuzzyCompare(blanker.displayOffTime, endTime - startTime, 50)
		console.log("timeout", endTime - startTime)

		// Manually turn the display on
		blanker.setDisplayOn()
		compare(blanker.blanked, false)

		// Simulate input events happening every 10 milliseconds
		for (var i = 0; i < 20; i++) {
			// During the interaction the display should stay unblanked
			compare(blanker.blanked, false)
			blanker.setDisplayOn()
			wait(20)
		}

		// Turn the display off manually
		blanker.setDisplayOff()
		compare(blanker.blanked, true)

		// Disallow blanking (e.g. during alarms)
		blanker.enabled = false

		// Disallowing blanking should turn the display back on
		compare(blanker.blanked, false)

		// Display off timeout should no longer apply
		wait(200)
		compare(blanker.blanked, false)

		// Allow display off timeout again
		blanker.enabled = true
		compare(blanker.blanked, false)

		// This time try different display off time
		blanker.displayOffTime = 50
		wait(80)
		compare(blanker.blanked, true)

		// Check that the display off timer is disabled with 0 timeout
		blanker.setDisplayOn()
		compare(blanker.blanked, false)
		blanker.displayOffTime = 0
		wait(160)
		compare(blanker.blanked, false)
	}
}
