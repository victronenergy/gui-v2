/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("Tasmania Standard Time"); city: "Hobart"; caption: "(GMT +10:00) Hobart" }
	ListElement { display: QT_TR_NOOP("E. Australia Standard Time"); city: "Brisbane"; caption: "(GMT +10:00) Brisbane" }
	ListElement { display: QT_TR_NOOP("AUS Eastern Standard Time"); city: "Sydney"; caption: "(GMT +10:00) Canberra, Melbourne, Sydney" }
	ListElement { display: QT_TR_NOOP("Cen. Australia Standard Time"); city: "Adelaide"; caption: "(GMT +09:30) Adelaide" }
	ListElement { display: QT_TR_NOOP("AUS Central Standard Time"); city: "Darwin"; caption: "(GMT +09:30) Darwin" }
	ListElement { display: QT_TR_NOOP("W. Australia Standard Time"); city: "Perth"; caption: "(GMT +08:00) Perth" }
}
