#include <QDebug>

#include <velib/qt/ve_qitem.hpp>
#include <velib/qt/ve_qitem_tree_model.hpp>

/*
 * [ row = 0 ]
 *       |-----[ row = 0 ]
 *       |-----[ row = 1 ]
 * [ row = 1 ]
 *       |-----[ row = 0 ]
 *
 * Every item can contain several columns, in our case e.g.
 * id, text, value, min, max etc.
 */

VeQItemTreeModel::VeQItemTreeModel(VeQItem *root, QObject *parent) :
	QAbstractItemModel(parent),
	mItemRoot(root)
{
	mColumns << "id" << "value";
	setItems(root);
}

void VeQItemTreeModel::setItems(VeQItem *root)
{
	mItemRoot = root;
	if (!root)
		return;
	root->foreachChildFirst(this, SLOT(setupValueChanges(VeQItem*)));
}

int VeQItemTreeModel::columnCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);

	return mColumns.count();
}

void VeQItemTreeModel::onValueChanged(VeQItem *item, QVariant value)
{
	Q_UNUSED(value);

	QModelIndex index = createIndex(item->index(), 1, item);
	emit dataChanged(index, index);
}

void VeQItemTreeModel::setupValueChanges(VeQItem *item)
{
	// qDebug() << "connect" << item->uniqueId();
	this->connect(item, SIGNAL(valueChanged(VeQItem*,QVariant)), SLOT(onValueChanged(VeQItem*,QVariant)));
	this->connect(item, SIGNAL(childAboutToBeAdded(VeQItem*)), SLOT(onChildAboutTobeAdded(VeQItem*)));
	this->connect(item, SIGNAL(childAdded(VeQItem *)), SLOT(onChildAdded(VeQItem *)));
	this->connect(item, SIGNAL(childAboutToBeRemoved(VeQItem*)), SLOT(onItemAboutToBeRemoved(VeQItem*)));
	this->connect(item, SIGNAL(childRemoved(VeQItem*)), SLOT(onItemRemoved(VeQItem*)));
}

void VeQItemTreeModel::onChildAboutTobeAdded(VeQItem *item)
{
	VeQItem *parent = qobject_cast<VeQItem *>(item->parent());

	// mItemRoot itself is not in the TreeView, so there is no signal to
	// notify its rows changed.
	if (parent == mItemRoot)
		return;

	// figure out where it will be added
	VeQItem::Children childs(parent->itemChildren());
	childs.insert(item->id(), item);
	int n = childs.keys().indexOf(item->id());

	if (item->children().count())
		item->foreachParentFirst(this, SLOT(setupValueChanges(VeQItem*)));

	// prepare for change..
	QModelIndex index = createIndex(parent->index(), 0, parent->parent());
	beginInsertRows(index, n, n);
}

void VeQItemTreeModel::onChildAdded(VeQItem *item)
{
	setupValueChanges(item);

	VeQItem *parent = qobject_cast<VeQItem *>(item->parent());
	if (parent == mItemRoot) {
		emit layoutChanged();
		return;
	}
	emit layoutChanged();

	endInsertRows();
}

void VeQItemTreeModel::onItemAboutToBeRemoved(VeQItem *item)
{
	qDebug() << "destroy" << item->uniqueId();

	// mItemRoot itself is not in the TreeView, so there is no signal to
	// notify its rows changed.
	VeQItem *parent = qobject_cast<VeQItem *>(item->parent());
	if (!parent || parent == mItemRoot)
		return;

	// prepare for change..
	int n = item->index();
	QModelIndex index = createIndex(parent->index(), 0, parent->parent());
	beginRemoveRows(index, n, n);
}

void VeQItemTreeModel::onItemRemoved(VeQItem *item)
{
	qDebug() << "removed" << item->id();

	VeQItem *parent = qobject_cast<VeQItem *>(item->parent());
	if (!parent || parent == mItemRoot) {
		emit layoutChanged();
		return;
	}

	endRemoveRows();
}

// return the actual data to be displayed for index
QVariant VeQItemTreeModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || role != Qt::DisplayRole)
		return QVariant();

	VeQItem *item = static_cast<VeQItem*>(index.internalPointer());
	QString column = mColumns[index.column()];
	if (column == "id")
		return item->id();
	if (column == "value" && item->itemChildren().count() == 0)
		return item->getValue();

	return QVariant();
}

Qt::ItemFlags VeQItemTreeModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::ItemFlags();

	return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QVariant VeQItemTreeModel::headerData(int section, Qt::Orientation orientation,
							   int role) const
{
	if (orientation == Qt::Horizontal && role == Qt::DisplayRole)
		return mColumns[section];

	return QVariant();
}

/*
 * Create a model index. Note the index can hold arbitrary pointer
 * available as internalPointer().
 */
QModelIndex VeQItemTreeModel::index(int row, int column, const QModelIndex &parent) const
{
	if (!hasIndex(row, column, parent))
		return QModelIndex();

	VeQItem *parentItem;

	if (!parent.isValid())
		parentItem = mItemRoot;
	else
		parentItem = static_cast<VeQItem*>(parent.internalPointer());

	VeQItem *childItem = parentItem->itemChild(row);
	if (!childItem)
		return QModelIndex();

	QModelIndex ret = createIndex(row, column, childItem);
	//qDebug() << "get index" << row << column << parent << "=" << ret << childItem->uniqueId();
	return ret;
}

// Return the parent given an valid index.
QModelIndex VeQItemTreeModel::parent(const QModelIndex &index) const
{
	if (!index.isValid())
		return QModelIndex();

	VeQItem *childItem = static_cast<VeQItem*>(index.internalPointer());
	//qDebug() << "child" << childItem->id();
	VeQItem *parentItem = static_cast<VeQItem *>(childItem->parent());

	if (!parentItem || parentItem == mItemRoot)
		return QModelIndex();

	return createIndex(parentItem->index(), 0, parentItem);
}

// returns the number of rows (child count) of index
int VeQItemTreeModel::rowCount(const QModelIndex &index) const
{
	VeQItem *item;

	if (index.column() > 0)
		return 0;

	if (!index.isValid())
		item = mItemRoot;
	else
		item = static_cast<VeQItem*>(index.internalPointer());

	int count = item->itemChildren().count();
	return count;
}
