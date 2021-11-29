/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQml

QtObject {
	function pushPage(page) {
		emitter.pagePushRequested(page)
	}

	function popPage() {
		emitter.pagePopRequested()
	}

	property QtObject emitter: QtObject {
		signal pagePushRequested(var page)
		signal pagePopRequested()
	}
}
