/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The base type of a device sub-page.

	The app sets the three device properties when it opens the page. To read the device's values,
	set the uid of a PluginDataItem to serviceUid followed by a path, for example:

		PluginDataItem { uid: root.serviceUid + "/Dc/0/Voltage" }
*/
PluginPage {
	// The device's service, as the start of a data item uid.
	required property string serviceUid
	// The device's product id, such as 0x106.
	required property int productId
	// The device's name, as shown in the device list.
	required property string deviceName
}
