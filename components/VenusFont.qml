/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQuick

QtObject {
	property FontLoader normal: FontLoader {
		source: "qrc:/fonts/MuseoSans-500.otf"
	}
}
