import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	id: root

	property bool readOnly: false

	optionModel: [
		{ display: CommonWords.no, value: 0, readOnly: root.readOnly },
		{ display: CommonWords.yes, value: 1, readOnly: root.readOnly }
	]
}
