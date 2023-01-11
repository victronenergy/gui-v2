/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListTextField {
	id: root

	placeholderText: "80"
	textField.validator: RegularExpressionValidator { regularExpression: /[0-9]{1,5}/ }
	textField.inputMethodHints: Qt.ImhDigitsOnly
}
