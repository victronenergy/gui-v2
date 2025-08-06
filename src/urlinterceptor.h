/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUIV2_URLINTERCEPTOR_H
#define VICTRON_VENUSOS_GUIV2_URLINTERCEPTOR_H

#include <QObject>
#include <QQmlAbstractUrlInterceptor>

class QUrl;

namespace Victron {
namespace VenusOS {

class UrlInterceptor : public QQmlAbstractUrlInterceptor
{
	QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) override;
};

}
}

#endif // VICTRON_VENUSOS_GUIV2_URLINTERCEPTOR_H
