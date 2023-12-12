#ifndef CMTECHNOLOGY_H
#define CMTECHNOLOGY_H

#include <QObject>
#include <QDBusVariant>
#include <QVariantMap>
#include <qqmlintegration.h>

#include "cmtechnology_interface.h"

class CmTechnology : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString name READ name NOTIFY nameChanged)
	Q_PROPERTY(QString type READ type NOTIFY typeChanged)
	Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
	Q_PROPERTY(bool powered READ powered WRITE powered NOTIFY poweredChanged)
	Q_PROPERTY(bool tethering READ tethering NOTIFY tetheringChanged)

public:
	CmTechnology(QObject* parent=0);
	CmTechnology(const QString &path, const QVariantMap &properties, QObject* parent=0);
	~CmTechnology();

	Q_INVOKABLE void scan();

	const QString name() const { return mProperties[Name].toString(); }
	const QString type() const { return mProperties[Type].toString(); }
	bool connected() const { return mProperties[Connected].toBool(); }
	bool powered() const { return mProperties[Powered].toBool(); }
	void powered(const bool powered) { mTechnology.SetProperty(Powered,QDBusVariant(QVariant(powered))); }
	bool tethering() const { return mProperties[Tethering].toBool(); }
	const QString path() const { return mPath; }

signals:
	void poweredChanged();
	void connectedChanged();
	void nameChanged();
	void typeChanged();
	void tetheringChanged();

private slots:
	void propertyChanged(const QString& name, const QDBusVariant &value);
	void dbusReply(QDBusPendingCallWatcher *call);

private:

	static const QString Powered;
	static const QString Connected;
	static const QString Name;
	static const QString Type;
	static const QString Tethering;

	QString mPath;
	QVariantMap mProperties;
	CmTechnologyInterface mTechnology;
};

#endif // CMTECHNOLOGY_H
