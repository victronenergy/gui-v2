/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListTextField {
	id: root

	placeholderText: "000.000.000.000"
	textField.validator: RegularExpressionValidator { regularExpression: /[0-9\.]{1,15}/ }
	textField.inputMethodHints: Qt.ImhDigitsOnly
}
