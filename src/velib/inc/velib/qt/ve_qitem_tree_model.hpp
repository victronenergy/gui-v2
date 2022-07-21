#ifndef _VELIB_QT_VE_QITEM_TREE_MODEL_HPP_
#define _VELIB_QT_VE_QITEM_TREE_MODEL_HPP_

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>

#include <velib/qt/ve_qitem.hpp>

class VeQItemTreeModel : public QAbstractItemModel
{
	Q_OBJECT

public:
	VeQItemTreeModel(VeQItem *root = 0, QObject *parent = 0);

	void setItems(VeQItem *root);
	QVariant data(const QModelIndex &index, int role) const;
	Qt::ItemFlags flags(const QModelIndex &index) const;
	QVariant headerData(int section, Qt::Orientation orientation,
						int role = Qt::DisplayRole) const;
	QModelIndex index(int row, int column,
					  const QModelIndex &parent = QModelIndex()) const;
	QModelIndex parent(const QModelIndex &index) const;
	int rowCount(const QModelIndex &parent = QModelIndex()) const;
	int columnCount(const QModelIndex &parent = QModelIndex()) const;

private slots:
	void onChildAboutTobeAdded(VeQItem *item);
	void onChildAdded(VeQItem *item);
	void onItemAboutToBeRemoved(VeQItem *item);
	void onItemRemoved(VeQItem *item);
	void onValueChanged(VeQItem *item, QVariant value);
	void setupValueChanges(VeQItem *item);

private:
	VeQItem *mItemRoot;
	QList<QString> mColumns;
};

#endif
