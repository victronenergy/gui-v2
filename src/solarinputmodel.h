/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef SOLARINPUTMODEL_H
#define SOLARINPUTMODEL_H

#include <QAbstractListModel>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

/*
  Provides a model for solar input data.

  Solar inputs include:
	- trackers from solarcharger, multi and inverter services
	- pvinverter services
*/
class SolarInputModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		ServiceUidRole = Qt::UserRole,
		GroupRole,
		NameRole,
		TodaysYieldRole,
		PowerRole,
		CurrentRole,
		VoltageRole,
		EnergyRole
	};
	Q_ENUM(Role)

	explicit SolarInputModel(QObject *parent = nullptr);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void addInput(const QString &serviceUid, const QVariantMap &values, int trackerIndex = 0);
	Q_INVOKABLE void setInputValue(const QString &serviceUid, Role role, const QVariant &value, int trackerIndex = 0);
	Q_INVOKABLE int indexOf(const QString &serviceUid, int trackerIndex = 0) const;
	Q_INVOKABLE void removeAt(int index);

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct Input {
		QString serviceUid;
		QString group;
		QString name;
		qreal todaysYield = qQNaN();
		qreal energy = qQNaN();
		qreal power = qQNaN();
		qreal current = qQNaN();
		qreal voltage = qQNaN();
		int trackerIndex = 0;
	};

	int insertionIndex(const Input &input) const;

	QHash<int, QByteArray> m_roleNames;
	QVector<Input> m_inputs;
};

} /* VenusOS */
} /* Victron */

#endif // SOLARINPUTMODEL_H
