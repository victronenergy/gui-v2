/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQuick

/*
  TODO: this will connect to C++ models 'GeneratorsModel', 'InvertersModel', and 'ESSModel', and dynamically append
  elements as appropriate. For now, this just has 3 hard-coded control cards.
*/
ListModel {
	id: cards

	property var inverterModeStrings: [
		//% "On"
		QT_TRID_NOOP('inverter_card_on'),
		//% "Charger only"
		QT_TRID_NOOP('inverter_card_charger_only'),
		//% "Inverter only"
		QT_TRID_NOOP('inverter_card_inverter_only'),
		//% "Off"
		QT_TRID_NOOP('inverter_card_off'),
	]

	property var essModeStrings: [
		//% "Keep batteries charged"
		QT_TRID_NOOP('ess_card_keep_batteries_charged'),
		//% "Optimized with battery life"
		QT_TRID_NOOP('ess_card_optimized_with_battery_life'),
		//% "Optimized without battery life"
		QT_TRID_NOOP('ess_card_optimized_without_battery_life')
	]

	property int inputCurrentLimit: 10700 // (mA) TODO - hook this up to the real value

	ListElement {
		url: "qrc:/controlcards/GeneratorCard.qml"
	}
	ListElement {
		url: "qrc:/controlcards/InverterCard.qml"
	}
	ListElement {
		url: "qrc:/controlcards/ESSCard.qml"
	}
	ListElement {
		url: "qrc:/controlcards/SwitchesCard.qml"
	}
}

