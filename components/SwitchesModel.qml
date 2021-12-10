/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQuick

/*
  TODO: this will connect to C++ model and dynamically append
  elements as appropriate. For now, this just has 3 hard-coded switches.
*/
ListModel {
	ListElement {
		//% "Switch Name A"
		text: QT_TRID_NOOP('switch_a')
		on: false
	}
	ListElement {
		//% "Switch Name B"
		text: QT_TRID_NOOP('switch_b')
		on: true
	}
	ListElement {
		//% "Switch Name C"
		text: QT_TRID_NOOP('switch_c')
		on: false
	}
}

