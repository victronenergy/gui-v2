/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	id: root

	textField.validator: RegularExpressionValidator { regularExpression: /\-?[0-9\.]+/ }
	textField.inputMethodHints: Qt.ImhDigitsOnly
}
