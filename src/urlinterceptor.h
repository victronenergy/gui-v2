#ifndef URLINTERCEPTOR_H
#define URLINTERCEPTOR_H

#include <QObject>
#include <QQmlAbstractUrlInterceptor>

class QUrl;

class UrlInterceptor : public QQmlAbstractUrlInterceptor
{
	QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) override;
};

#endif // URLINTERCEPTOR_H
