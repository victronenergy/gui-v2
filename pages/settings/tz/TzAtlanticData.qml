/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("Greenwich Standard Time"); city: "Atlantic/Reykjavik"; caption: "(GMT) Monrovia, Reykjavik" }
	ListElement { display: QT_TR_NOOP("Azores Standard Time"); city: "Atlantic/Azores"; caption: "(GMT -01:00) Azores" }
	ListElement { display: QT_TR_NOOP("Cape Verde Standard Time"); city: "Atlantic/Cape_Verde"; caption: "(GMT -01:00) Cape Verde Is." }
	ListElement { display: QT_TR_NOOP("Mid-Atlantic Standard Time"); city: "GMT+2"; caption: "(GMT -02:00) Mid-Atlantic" }
}
