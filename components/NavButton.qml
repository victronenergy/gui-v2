/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	width: 112
	height: 67
	icon.width: Theme.iconSizeMedium
	icon.height: Theme.iconSizeMedium
	spacing: Theme.marginSmall

	color: down || checked
		   ? (Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor)
		   : (Theme.displayMode == Theme.Dark ? Theme.secondaryFontColor : Theme.okSecondaryColor)
}
