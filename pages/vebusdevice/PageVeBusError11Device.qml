/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: code

		property string text: isValid ? "0x" + value.toString(16) : "--"

		uid: root.bindPrefix + "/ExtendStatus/GridRelayReport/Code"
	}

	VeQuickItem {
		id: counter

		uid: root.bindPrefix + "/ExtendStatus/GridRelayReport/Count"
	}

	GradientListView {
		model: VisibleItemModel {

			ListText {
				//% "Last VE.Bus Error 11 report #%1"
				text: qsTrId("vebus_device_last_vebus_error_11_report").arg(counter.value)
				secondaryText: code.text
			}

			ListText {
				text: CommonWords.error_colon
				//% "BF safety test in progress"
				secondaryText: qsTrId("vebus_device_bf_safety_test_in_progress")
				preferredVisible: code.isValid && (code.value & 0x01) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "BF safety test OK"
				secondaryText: qsTrId("vebus_device_bf_safety_test_ok")
				preferredVisible: code.isValid && (code.value & 0x02) != 0
			}

			/*	Removed "Error occurred" (bit 3) since it is a status flag which is
				always set when any of the bold errors in the error matrix on
				https://wiki.victronenergy.com/rend/ccgx/specs/mk2-dbus/vebus-error-11
				is set */

			ListText {
				text: CommonWords.error_colon
				//% "AC0 /AC1 mismatch"
				secondaryText: qsTrId("vebus_device_ac0_ac1_mismatch")
				preferredVisible: code.isValid && (code.value & 0x08) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Communication error"
				secondaryText: qsTrId("vebus_device_communication_error")
				preferredVisible: code.isValid && (code.value & 0x10) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "GND Relay Error"
				secondaryText: qsTrId("vebus_device_ground_relay_error")
				preferredVisible: code.isValid && (code.value & 0x20) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "UMains mismatch"
				secondaryText: qsTrId("vebus_device_umains_mismatch")
				preferredVisible: code.isValid && (code.value & 0x1000) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Period Time mismatch"
				secondaryText: qsTrId("vebus_device_period_time_mismatch")
				preferredVisible: code.isValid && (code.value & 0x2000) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Drive of BF relay mismatch"
				secondaryText: qsTrId("vebus_device_drive_of_bf_relay_mismatch")
				preferredVisible: code.isValid && (code.value & 0x4000) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Error: PE2 open"
				secondaryText: qsTrId("vebus_device_error_pe2_open")
				preferredVisible: code.isValid && (code.value & 0x10000) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Error: PE2 closed"
				secondaryText: qsTrId("vebus_device_error_pe2_closed")
				preferredVisible: code.isValid && (code.value & 0x20000) != 0
			}

			ListText {
				text: CommonWords.error_colon
				//% "Failing step: %1"
				secondaryText: qsTrId("vebus_device_failing_step").arg(code.isValid ? (code.value & 0xF00) >> 8 : "--")
				preferredVisible: code.isValid && code.value > 0
			}
		}
	}
}
