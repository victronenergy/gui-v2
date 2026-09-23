/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// CheapBarGauge is cheaper to render than BarGauge, as the
// corner radii never change. The end of the progress highlight
// area is always rounded, instead being straight-edged until the
// value approaches the total.
//
// CheapBarGauge should be used on the OverviewPage and BriefPage
// on GX devices (or any future view with performance concerns).

BarGauge {
	endRadius: clampedRadius
}
