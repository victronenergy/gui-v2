/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_COMBINEDLISTMODEL_H
#define VICTRON_GUIV2_COMBINEDLISTMODEL_H

#include <QAbstractListModel>
#include <QPersistentModelIndex>
#include <QPointer>
#include <qqmlintegration.h>

namespace Victron {
namespace VenusOS {

/*
	A list model with the rows of firstModel, followed by the rows of secondModel.

	Each row has the roles of the model that it comes from, with the same names. The roles of the
	other model are undefined for it. The fromSecondModel role is true for the rows of secondModel,
	so a delegate can tell which model a row comes from, even when both models have roles with the
	same names. Use the role names: the role numbers are not the same as in the two models.

	Only the top-level rows, and column 0, of each model are included.

	If firstModel and secondModel are the same model, its rows are only included once, as the rows
	of firstModel, and a warning is logged.

	Changes to the rows of either model are passed on, so the view keeps the delegates of the rows
	that have not changed. If a model is reset, its rows are removed and inserted again. If its role
	names have changed, the whole list is reset instead. A layout change that only sorts the rows of
	a model is passed on as a layout change. Any other layout change, which may also remove or
	insert rows, is passed on like a reset of that model.

	The roles of each model are read when it is set, and again when it is reset, or when it has
	rows inserted or changed, in case that adds new roles, as it does in a ListModel.

	Usage:

	ListView {
		model: CombinedListModel {
			firstModel: deviceModel
			secondModel: pluginModel
		}
		delegate: Loader {
			required property bool fromSecondModel
			required property var model
			...
		}
	}
*/
class CombinedListModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QAbstractItemModel *firstModel READ firstModel WRITE setFirstModel NOTIFY firstModelChanged FINAL)
	Q_PROPERTY(QAbstractItemModel *secondModel READ secondModel WRITE setSecondModel NOTIFY secondModelChanged FINAL)
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
	enum Role {
		FromSecondModelRole = Qt::UserRole
	};
	Q_ENUM(Role)

	explicit CombinedListModel(QObject *parent = nullptr);

	QAbstractItemModel *firstModel() const;
	void setFirstModel(QAbstractItemModel *model);

	QAbstractItemModel *secondModel() const;
	void setSecondModel(QAbstractItemModel *model);

	int count() const;

	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role) const override;
	QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
	void firstModelChanged();
	void secondModelChanged();
	void countChanged();

private:
	enum class LayoutChange {
		None,
		Sort,      // The rows are sorted, and the change is passed on as a layout change.
		Rebuild    // The rows are removed, then inserted again when the layout change ends.
	};

	struct Source {
		QPointer<QAbstractItemModel> model;
		QList<QMetaObject::Connection> connections;
		QHash<int, QByteArray> roleNames;   // The role names of the model, when they were last read.
		QHash<int, int> sourceRoles;        // This model's role number for each source role number.
		QHash<int, int> roles;              // The source role number for each of this model's roles.
		int rowCount = 0;                   // The number of rows of the model in this model.
		LayoutChange layoutChange = LayoutChange::None;
	};

	struct LayoutChangeIndex {
		QModelIndex index;
		QPersistentModelIndex sourceIndex;
		bool fromSecondModel = false;
	};

	void setModel(Source &source, QAbstractItemModel *model);
	bool modelsAreSame() const;
	void reconnectModel(Source &source);
	void connectModel(Source &source);
	void updateRoles();
	bool roleNamesChanged(const Source &source) const;
	void resetIfRoleNamesChanged(const Source &source);
	int rowOffset(const Source &source) const;
	void removeAllRows(Source &source);
	void insertAllRows(Source &source);

	void sourceRowsAboutToBeInserted(Source &source, const QModelIndex &parent, int first, int last);
	void sourceRowsInserted(Source &source, const QModelIndex &parent, int first, int last);
	void sourceRowsAboutToBeRemoved(Source &source, const QModelIndex &parent, int first, int last);
	void sourceRowsRemoved(Source &source, const QModelIndex &parent, int first, int last);
	void sourceRowsAboutToBeMoved(Source &source, const QModelIndex &sourceParent, int sourceStart,
			int sourceEnd, const QModelIndex &destinationParent, int destinationRow);
	void sourceRowsMoved(Source &source, const QModelIndex &sourceParent, int sourceStart, int sourceEnd,
			const QModelIndex &destinationParent, int destinationRow);
	void sourceDataChanged(Source &source, const QModelIndex &topLeft, const QModelIndex &bottomRight,
			const QList<int> &roles);
	void sourceLayoutAboutToBeChanged(Source &source, const QList<QPersistentModelIndex> &parents,
			QAbstractItemModel::LayoutChangeHint hint);
	void sourceLayoutChanged(Source &source);
	void sourceModelAboutToBeReset(Source &source);
	void sourceModelReset(Source &source);
	void sourceDestroyed(Source &source);

	Source m_first;
	Source m_second;
	QHash<int, QByteArray> m_roleNames;
	QList<LayoutChangeIndex> m_layoutChangeIndexes;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_COMBINEDLISTMODEL_H
