/*
** Copyright (C) 2022 Victron Energy B.V.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	enum Access {
		AccessUser,
		AccessInstaller,
		AccessSuperUser,
		AccessService
	}
}
