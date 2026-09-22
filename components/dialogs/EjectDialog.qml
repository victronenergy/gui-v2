/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Storage Manager's Eject confirmation - shared by the Storage list page
	(New/Claimed/Foreign volumes) and a volume's own detail page (Adopted
	volumes), so both get the same real "who's actually using this"
	description instead of two hand-duplicated copies drifting apart.
	Self-contained: only volumePrefix/volumeName come from the caller,
	everything else (which services are using this volume) is read
	directly from Storage Manager's own /Allocations tree.
*/
ModalWarningDialog {
	id: root

	required property string volumePrefix
	required property string volumeName

	signal ejectStarted()

	VeQuickItem { id: ejectAction; uid: root.volumePrefix + "/Admin/Eject" }
	StorageVolumeConsumers { id: consumers; volumePrefix: root.volumePrefix }

	//% "Eject %1?"
	title: qsTrId("ejectdialog_title").arg(root.volumeName)
	description: {
		if (consumers.consumerNames.length === 0) {
			//% "No services are currently using this storage - it can be safely unmounted, but any data on it won't be accessible again until it's reconnected."
			return qsTrId("ejectdialog_description_none")
		}
		//% "%1 will be stopped before this storage is unmounted."
		return qsTrId("ejectdialog_description").arg(consumers.consumerNames.join(", "))
	}
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
	onAccepted: {
		// Arm the caller before the synchronous D-Bus write. SafeToRemove can
		// change while setValue() is still on the stack.
		root.ejectStarted()
		ejectAction.setValue(1)
	}
}
