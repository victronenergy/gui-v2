import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: "Customisation With Errors" // No translation, just as an example.

	InvalidCustomisation {
		this will not compile using QQmlComponent
		but it should not break gui-v2
	}
}
