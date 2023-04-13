/*
** Copyright (C) 2023 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_TIMEZONEMODEL_H
#define VICTRON_VENUSOS_GUI_V2_TIMEZONEMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QVector>
#include <QtCore/QByteArray>
#include <QtCore/QTimeZone>
#include <QtCore/QHash>
#include <QtCore/QDateTime>

#include <QtQml/QQmlParserStatus>

namespace Victron {

namespace VenusOS {

class TimezoneModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(QString prefix READ prefix WRITE setPrefix NOTIFY prefixChanged)
	Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
	enum RoleNames {
		DisplayNameRole = Qt::DisplayRole,
		CityRole = Qt::UserRole,
		CaptionRole
	};

	explicit TimezoneModel(QObject *parent = nullptr);
	void populateModel();

	QString prefix() const;
	void setPrefix(const QString &prefix);

	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
	int rowCount(const QModelIndex &parent = QModelIndex()) const override;

Q_SIGNALS:
	void prefixChanged();
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

	// QQmlParserStatus
	void classBegin() override;
	void componentComplete() override;

private:
	bool m_completed = true;
	QString m_prefix;
	QVector<QTimeZone> m_timezones;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_TIMEZONEMODEL_H


