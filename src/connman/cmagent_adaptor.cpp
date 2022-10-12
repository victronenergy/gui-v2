#include "cmagent_adaptor.h"

CmAgentAdaptor::CmAgentAdaptor(QObject *parent) :
	QDBusAbstractAdaptor(parent)
{
}

void CmAgentAdaptor::Release()
{
	QMetaObject::invokeMethod(parent(), "release");
}

void CmAgentAdaptor::ReportError(const QDBusObjectPath &path, const QString &error)
{
	QMetaObject::invokeMethod(parent(), "reportError", Q_ARG(QDBusObjectPath, path), Q_ARG(QString, error));
}

void CmAgentAdaptor::RequestBrowser(const QDBusObjectPath &path, const QString &url)
{
	QMetaObject::invokeMethod(parent(), "requestBrowser", Q_ARG(QDBusObjectPath, path), Q_ARG(QString, url));
}

QVariantMap CmAgentAdaptor::RequestInput(const QDBusObjectPath &path, const QVariantMap &fields)
{
	QVariantMap value;
	QMetaObject::invokeMethod(parent(), "requestInput", Q_RETURN_ARG(QVariantMap, value), Q_ARG(QDBusObjectPath, path), Q_ARG(QVariantMap, fields));
	return value;
}

void CmAgentAdaptor::Cancel()
{
	QMetaObject::invokeMethod(parent(), "cancel");
}

