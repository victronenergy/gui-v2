import QtQuick

ListModel {
	id: tzCity
	ListElement { display: QT_TR_NOOP("Tonga Standard Time"); city: "Tongatapu"; caption: "(GMT +13:00) Nuku'alofa" }
	ListElement { display: QT_TR_NOOP("Fiji Standard Time"); city: "Fiji"; caption: "(GMT +12:00) Fiji, Marshall Is." }
	ListElement { display: QT_TR_NOOP("New Zealand Standard Time"); city: "Auckland"; caption: "(GMT +12:00) Auckland, Wellington" }
	ListElement { display: QT_TR_NOOP("Central Pacific Standard Time"); city: "Guadalcanal"; caption: "(GMT +11:00) Solomon Is., New Caledonia" }
	ListElement { display: QT_TR_NOOP("West Pacific Standard Time"); city: "Port_Moresby"; caption: "(GMT +10:00) Guam, Port Moresby" }
	ListElement { display: QT_TR_NOOP("Samoa Standard Time"); city: "Apia"; caption: "(GMT -11:00) Samoa" }
	ListElement { display: QT_TR_NOOP("Hawaiian Standard Time"); city: "Honolulu"; caption: "(GMT -10:00) Hawaii" }
	ListElement { display: QT_TR_NOOP("Easter Island Standard Time"); city: "Easter"; caption: "(GMT -05:00) Easter Island" }
}
