/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Button {
	id: root

	icon.width: Theme.iconSizeMedium
	icon.height: Theme.iconSizeMedium
	spacing: Theme.marginSmall
	display: C.AbstractButton.TextUnderIcon

	color: down || checked
		   ? (Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor)
		   : (Theme.displayMode == Theme.Dark ? Theme.secondaryFontColor : Theme.okSecondaryColor)
}
