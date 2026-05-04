/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	required property int quantitySourceType
	required property var quantityDataObject

	// The phases to be shown in the 3-phase display.
	// Generally the 3-phase display should only be shown when there are multiple phases. However
	// for AC/Essential loads, the 3-phase display may be shown when there only one phase, if
	// L1 and L2 are summed.
	required property PhaseModel phaseModel

	// Only used for the AC-in case.
	property AcInput input

	// If true, show the phase measurements on the right rather than the bottom.
	property bool stretchHorizontally

	preferredSize: phaseModel?.count > 1 ? VenusOS.OverviewWidget_PreferredSize_PreferLarge : VenusOS.OverviewWidget_PreferredSize_Any
}
