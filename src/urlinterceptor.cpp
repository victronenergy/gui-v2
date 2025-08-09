#include "urlinterceptor.h"
#include <QCoreApplication>
#include <QUrl>

QUrl UrlInterceptor::intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type)
{
	const QString exeDir = QCoreApplication::applicationDirPath();

	QString returnUrl(url.toString());

	if (returnUrl.endsWith(".qml") && returnUrl.indexOf("qrc:/qt/qml/") == 0)
	{
		returnUrl.replace("qrc:/qt/qml", exeDir);
	}

	return QUrl(returnUrl);
}
