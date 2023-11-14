/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("Morocco Standard Time"); city: "Casablanca"; caption: "(GMT) Casablanca" }
	ListElement { display: QT_TR_NOOP("W. Central Africa Standard Time"); city: "Lagos"; caption: "(GMT +01:00) West Central Africa" }
	ListElement { display: QT_TR_NOOP("South Africa Standard Time"); city: "Johannesburg"; caption: "(GMT +02:00) Harare, Pretoria" }
	ListElement { display: QT_TR_NOOP("Namibia Standard Time"); city: "Windhoek"; caption: "(GMT +02:00) Windhoek" }
	ListElement { display: QT_TR_NOOP("Egypt Standard Time"); city: "Cairo"; caption: "(GMT +02:00) Cairo" }
	ListElement { display: QT_TR_NOOP("E. Africa Standard Time"); city: "Nairobi"; caption: "(GMT +03:00) Nairobi" }
}
