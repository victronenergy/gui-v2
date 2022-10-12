#ifndef CONNMANDBUSTYPES_H
#define CONNMANDBUSTYPES_H

#include <QtCore/QMap>
#include <QtCore/QList>
#include <QtCore/QString>
#include <QtCore/QMetaType>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusObjectPath>

typedef QMap<QString, QString> StringMap;
Q_DECLARE_METATYPE ( StringMap );

struct ConnmanObject {
	QDBusObjectPath path;
	QVariantMap properties;
};

Q_DECLARE_METATYPE ( ConnmanObject );
QDBusArgument &operator<<(QDBusArgument &argument, const ConnmanObject &obj);
const QDBusArgument &operator>>(const QDBusArgument &argument, ConnmanObject &obj);

typedef QList<ConnmanObject> ConnmanObjectList;
Q_DECLARE_METATYPE ( ConnmanObjectList );

inline void registerConnmanDataTypes() {
	qDBusRegisterMetaType<StringMap>();
	qDBusRegisterMetaType<ConnmanObject>();
	qDBusRegisterMetaType<ConnmanObjectList>();
	qDBusRegisterMetaType<QList<QDBusObjectPath> >();
	qRegisterMetaType<ConnmanObjectList>("ConnmanObjectList");
}

#endif //CONNMANDBUSTYPES_H
