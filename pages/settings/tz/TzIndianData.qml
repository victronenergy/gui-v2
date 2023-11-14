/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("Mauritius Standard Time"); city: "Mauritius"; caption: "(GMT +04:00) Port Louis" }
	ListElement { display: QT_TR_NOOP("Christmas Island Standard Time"); city: "Christmas"; caption: "(GMT +07:00) Christmas Island" }
}
