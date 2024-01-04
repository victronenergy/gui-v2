/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	function firmwareVersion(version, format) {

		if (version === undefined || version === null)
			return "";
		if (version === 0xFFFFFF)
			return "";

		// 0x00000A => v0.0A
		// 0x0000A0 => v0.A0
		// 0x000A00 => vA.00
		// 0x00A000 => vA0.00
		// 0x0A0000 => vA.00 (!!)
		// 0x0A0B0C => vA.0B.0C
		// 0xA00BC0 => vA0.0B.C0
		// 0xA00BFF => vA0.0B

		var hexString = version.toString(16).toUpperCase();

		if (format === "vebus")
			return "v" + hexString;

		// Add leading zeros to get a string at least 3 characters long
		if (version < 0x100)
			hexString = "00".concat(hexString).slice(-3)
		// Insert points and remove trailing zeros in 3 byte version
		hexString = hexString
		.replace(/(.{1,2})(?=(.{2})+$)/g, "$1.") // Insert points
		.replace(/(\..{2})\.(00|FF)$/, "$1") // Remove trailing "00" or "FF" in 3 byte version
		.replace(/(\..{2})\.(.{2})$/, format === "venus" ? "$1~$2" : "$1-beta-$2") // Add beta separator

		return "v" + hexString
	}

	text: CommonWords.firmware_version
	secondaryText: dataItem.value ? firmwareVersion(dataItem.value) : ""
}
