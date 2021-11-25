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
	ListElement {
		url: "qrc:/controlcards/GeneratorCard.qml"
	}
	ListElement {
		url: "qrc:/controlcards/InverterCard.qml"
	}
	ListElement {
		url: "qrc:/controlcards/ESSCard.qml"
	}
}

