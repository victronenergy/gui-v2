/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SOLARINPUTMODEL_H
#define VICTRON_GUIV2_SOLARINPUTMODEL_H

#include <QAbstractListModel>
#include <qqmlintegration.h>
#include <QSortFilterProxyModel>

namespace Victron {
namespace VenusOS {

class Device;
class SolarInput;

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
		ServiceTypeRole,
		GroupRole,
		EnabledRole,
		NameRole,
		TodaysYieldRole,
		PowerRole,
		CurrentRole,
		VoltageRole,
	};
	Q_ENUM(Role)

	explicit SolarInputModel(QObject *parent = nullptr);

	int count() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	void maybeAddDevice(Device *device);
	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void clearInputs();
	void addAvailableInputs();
	void initializeInput(SolarInput *input);
	void inputEnabledChanged();
	void emitInputValueChanged(SolarInput *input, Role role);

	QVector<SolarInput *> m_enabledInputs;
	QVector<SolarInput *> m_disabledInputs;
};

/*
	Provides a sorted SolarInputModel.

	Inputs are sorted by their group and name.
*/
class SortedSolarInputModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedSolarInputModel(QObject *parent = nullptr);

protected:
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SOLARINPUTMODEL_H
