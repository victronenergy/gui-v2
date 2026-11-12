/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

// Instantiation fails, so the nav wrapper reports contentFailed and removes
// the page. Cache generation is skipped; the failure is at load time.
Item {
	DoesNotExist {}
}
