/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("GMT Standard Time"); city: "London"; caption: "(GMT) Dublin, Edinburgh, Lisbon, London" }
	ListElement { display: QT_TR_NOOP("Central Europe Standard Time"); city: "Budapest"; caption: "(GMT +01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague" }
	ListElement { display: QT_TR_NOOP("Central European Standard Time"); city: "Warsaw"; caption: "(GMT +01:00) Sarajevo, Skopje, Warsaw, Zagreb" }
	ListElement { display: QT_TR_NOOP("Romance Standard Time"); city: "Paris"; caption: "(GMT +01:00) Brussels, Copenhagen, Madrid, Paris" }
	ListElement { display: QT_TR_NOOP("W. Europe Standard Time"); city: "Berlin"; caption: "(GMT +01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna" }
	ListElement { display: QT_TR_NOOP("E. Europe Standard Time"); city: "Chisinau"; caption: "(GMT +02:00) Chisinau" }
	ListElement { display: QT_TR_NOOP("FLE Standard Time"); city: "Kiev"; caption: "(GMT +02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius" }
	ListElement { display: QT_TR_NOOP("GTB Standard Time"); city: "Bucharest"; caption: "(GMT +02:00) Athens, Bucharest" }
	ListElement { display: QT_TR_NOOP("Belarus Standard Time"); city: "Minsk"; caption: "(GMT +03:00) Minsk" }
	ListElement { display: QT_TR_NOOP("Russian Standard Time"); city: "Moscow"; caption: "(GMT +03:00) Moscow, St. Petersburg, Volgograd" }
	ListElement { display: QT_TR_NOOP("Turkey Standard Time"); city: "Istanbul"; caption: "(GMT +03:00) Istanbul" }
}
