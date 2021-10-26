/*
** Copyright (C) 2021 Victron Energy B.V.
*/

pragma Singleton

import QtQuick

Item {
	property alias normal: normal

	FontLoader {
		id: normal

		source: "qrc:/fonts/MuseoSans-500.otf"
	}
}
