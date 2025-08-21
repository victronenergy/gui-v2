/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "urlinterceptor.h"
#include <QCoreApplication>
#include <QUrl>

namespace Victron {
namespace VenusOS {

QUrl UrlInterceptor::intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type)
{
	/*
	 * Replaces almost every qrc-compiled qml file used by gui-v2 (eg. "qrc:/qt/qml/Victron/VenusOS/components/InputPanel.qml")
	 * with the filesystem-based equivalent (eg: "/data/home/root/install/bin/Victron/VenusOS/components/InputPanel.qml").
	 * This allows users to edit qml files on the cerbo, restart gui-v2, and run their modified code.
	 *
	 * This only affects Victron qml files. The following resources will still be loaded from qrc:
	 *		All images (svgs, pngs, gifs etc)
	 *		fonts
	 *		qmldir files
	 *		non-Victron qml code (eg. qrc:/qt-project.org/imports/QtQuick/Controls/Basic/ButtonGroup.qml)
	 *		dynamically loaded customisations (eg. Settings -> Integrations -> Customisations settings pages)
	 */
	const QString exeDir = QCoreApplication::applicationDirPath();

	QString returnUrl(url.toString());

	if (returnUrl.endsWith(".qml") && returnUrl.indexOf("qrc:/qt/qml/") == 0) {
		returnUrl.replace("qrc:/qt/qml", QString("file://%1").arg(exeDir));
	}

	return QUrl(returnUrl);
}

}
}
