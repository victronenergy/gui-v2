import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("New Zealand Standard Time"); city: "McMurdo"; caption: "(GMT +12:00) McMurdo" }
	ListElement { display: QT_TR_NOOP("Central Pacific Standard Time"); city: "Macquarie"; caption: "(GMT +11:00) Macquarie" }
	ListElement { display: QT_TR_NOOP("West Pacific Standard Time"); city: "DumontDUrville"; caption: "(GMT +10:00) DumontDUrville" }
	ListElement { display: QT_TR_NOOP("W. Australia Standard Time"); city: "Casey"; caption: "(GMT +08:00) Casey" }
	ListElement { display: QT_TR_NOOP("SE Asia Standard Time"); city: "Davis"; caption: "(GMT +07:00) Davis" }
	ListElement { display: QT_TR_NOOP("Central Asia Standard Time"); city: "Vostok"; caption: "(GMT +06:00) Vostok" }
	ListElement { display: QT_TR_NOOP("West Asia Standard Time"); city: "Mawson"; caption: "(GMT +05:00) Mawson" }
	ListElement { display: QT_TR_NOOP("E. Africa Standard Time"); city: "Syowa"; caption: "(GMT +03:00) Syowa" }
	ListElement { display: QT_TR_NOOP("Pacific SA Standard Time"); city: "Palmer"; caption: "(GMT -04:00) Palmer" }
	ListElement { display: QT_TR_NOOP("SA Western Standard Time"); city: "Rothera"; caption: "(GMT -04:00) Rothera" }
}
