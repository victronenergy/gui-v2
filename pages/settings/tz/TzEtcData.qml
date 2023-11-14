/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("GMT +12"); city: "GMT-12"; caption: "(GMT +12:00) Coordinated Universal Time+12" }
	ListElement { display: QT_TR_NOOP("GMT "); city: "GMT"; caption: "(GMT) Coordinated Universal Time" }
	ListElement { display: QT_TR_NOOP("Mid-Atlantic Standard Time"); city: "GMT+2"; caption: "(GMT -02:00) Mid-Atlantic" }
	ListElement { display: QT_TR_NOOP("GMT -02"); city: "GMT+2"; caption: "(GMT -02:00) Coordinated Universal Time-02" }
	ListElement { display: QT_TR_NOOP("GMT -11"); city: "GMT+11"; caption: "(GMT -11:00) Coordinated Universal Time-11" }
	ListElement { display: QT_TR_NOOP("Dateline Standard Time"); city: "GMT+12"; caption: "(GMT -12:00) International Date Line West" }
}
