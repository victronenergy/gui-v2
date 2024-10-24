/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef PHASEMODEL_H
#define PHASEMODEL_H

#include <QAbstractListModel>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

class PhaseModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(int phaseCount READ phaseCount WRITE setPhaseCount NOTIFY phaseCountChanged)
	Q_PROPERTY(bool l2AndL1OutSummed READ l2AndL1OutSummed WRITE setL2AndL1OutSummed NOTIFY l2AndL1OutSummedChanged)

public:
	enum Role {
		NameRole = Qt::UserRole,
		PowerRole,
		CurrentRole
	};
	Q_ENUM(Role)

	explicit PhaseModel(QObject *parent = nullptr);

	int count() const;

	// The phaseCount is the number of phases reported on the system, which may be different from
	// the model count if l2AndL1OutSummed=true, so do not use the phase count as the model count.
	int phaseCount() const;
	void setPhaseCount(int phaseCount);

	bool l2AndL1OutSummed() const;
	void setL2AndL1OutSummed(bool l2AndL1OutSummed);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void setValue(int index, Role role, const qreal value);
	Q_INVOKABLE QVariantMap get(int index) const;

Q_SIGNALS:
	void countChanged();
	void phaseCountChanged();
	void l2AndL1OutSummedChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct Phase {
		qreal power = 0;
		qreal current = 0;
	};

	void resetModel();

	QHash<int, QByteArray> m_roleNames;
	QVector<Phase> m_phases;
	int m_phaseCount = 0;
	int m_modelCount = 0;
	bool m_l2AndL1OutSummed = false;
};

} /* VenusOS */
} /* Victron */

#endif // PHASEMODEL_H
