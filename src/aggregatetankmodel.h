/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_AGGREGATETANKMODEL_H
#define VICTRON_GUIV2_AGGREGATETANKMODEL_H

#include <QObject>
#include <QAbstractListModel>

#include "basetankdevice.h"
#include "basetankdevicemodel.h"

namespace Victron {
namespace VenusOS {

class AggregateDeviceModel;

/*
	Combines tanks of different types into a single model.

	Tanks of the same type may be combined into a single list entry, depending on the merge
	threshold.
*/
class AggregateTankModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(QVariantList tankModels READ tankModels WRITE setTankModels NOTIFY tankModelsChanged)
	Q_PROPERTY(int mergeThreshold READ mergeThreshold WRITE setMergeThreshold NOTIFY mergeThresholdChanged)

public:
	enum Role {
		IsGroupRole = Qt::UserRole,
		TankRole,
		TankModelRole
	};
	Q_ENUM(Role)

	explicit AggregateTankModel(QObject *parent = nullptr);
	~AggregateTankModel();

	QVariantList tankModels() const;
	void setTankModels(const QVariantList &models);

	int count() const;

	// If mergeThreshold >= the total number of tanks, any tanks of the same type are merged into a
	// single group. Groups are created until the model count is below the threshold.
	// If mergeThreshold = 0, no merging is done.
	int mergeThreshold() const;
	void setMergeThreshold(int mergeThreshold);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE BaseTankDevice *tankAt(int index) const;
	Q_INVOKABLE BaseTankDeviceModel *tankModelAt(int index) const;

signals:
	void countChanged();
	void tankModelsChanged();
	void mergeThresholdChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	class Entry
	{
	public:
		QPointer<BaseTankDevice> tank;
		QPointer<BaseTankDeviceModel> tankModel;
		bool isGroup = false;
	};

	void reload();
	int insertionIndex(const Entry &entry) const;
	bool lessThan(const Entry &a, const Entry &b) const;
	int indexOfTankOrGroup(BaseTankDevice *tank, BaseTankDeviceModel *tankModel) const;
	int indexOfLastConsecutiveTankType(int fromIndex) const;
	void convertToGroup(int index);
	void convertToNonGroup(int index, BaseTankDevice *tank);

	void modelRowsInserted(const QModelIndex &parent, int first, int last);
	void modelTankAdded(BaseTankDevice *tank, BaseTankDeviceModel *tankModel);
	void modelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void modelAboutToRemoveTank(BaseTankDevice *tank, BaseTankDeviceModel *tankModel);
	void modelRowsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destinationParent, int destinationRow);

	QHash<int, QByteArray> m_roleNames;
	QList<Entry> m_entries;
	AggregateDeviceModel *m_model = nullptr;
	int m_mergeThreshold = 0;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_AGGREGATETANKMODEL_H
