/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		header: DvccCommonSettings {
			width: parent.width
		}

		// TODO implement device instance list
	}
}
