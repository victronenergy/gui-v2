import QtQuick

Item {
	property int display
	property int spacing
	property font font
	property color color
	property color iconColor
	property string text
	property var icon: Item {
		property color color
		property string source
	}

	property var image
	property var label
}
