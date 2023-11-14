/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	placeholderText: "80"
	textField.validator: RegularExpressionValidator { regularExpression: /[0-9]{1,5}/ }
	textField.inputMethodHints: Qt.ImhDigitsOnly
}
