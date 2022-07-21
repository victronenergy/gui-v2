#include <QDebug>

#include <velib/qt/ve_qitem.hpp>
#include <velib/qt/ve_qitem_table_model.hpp>

VeQItemTableModel::VeQItemTableModel(Flags flags, QObject *parent) :
	QAbstractItemModel(parent),
	mFlags(flags),
	mCompleted(false)
{
	setFlagsNoSignal(flags);

	// qt 5 has roleNames as virtual and setRoleNames is removed
#if QT_VERSION < QT_VERSION_CHECK(5, 0, 0)
	setRoleNames(roleNames());
#endif
}

void VeQItemTableModel::addItem(VeQItem *item)
{
	if (!item)
		return;

	if (mHash.contains(item->uniqueId())) {
		qWarning() << item << " " << item->uniqueId() << " was already added";
		return;
	}

	if (mFlags & AddAllChildren) {
		// Add this, all children and their children
		if ((mFlags & DontAddItem) == 0) {
			setupValueChanges(item, AddAllChildren);
		} else {
			this->connect(item, SIGNAL(childAdded(VeQItem *)), SLOT(onRecursiveChildAdded(VeQItem *)));
			this->connect(item, SIGNAL(childAboutToBeRemoved(VeQItem*)), SLOT(onItemAboutToBeRemoved(VeQItem*)));
		}
		foreach (VeQItem *child, item->findChildren<VeQItem*>())
			setupValueChanges(child, AddAllChildren);

	} else if (mFlags & AddChildren) {
		// Only add this and direct siblings
		if ((mFlags & DontAddItem) == 0) {
			setupValueChanges(item, AddChildren);
		} else {
			this->connect(item, SIGNAL(childAdded(VeQItem *)), SLOT(onChildAdded(VeQItem *)));
			this->connect(item, SIGNAL(childAboutToBeRemoved(VeQItem*)), SLOT(onItemAboutToBeRemoved(VeQItem*)));
		}
		foreach (VeQItem *child, item->itemChildren())
			setupValueChanges(child);

	} else {
		// only add this item
		setupValueChanges(item);
	}
}

int VeQItemTableModel::columnCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);

	return mColumns.count();
}

void VeQItemTableModel::cellChanged(VeQItem *item, QString column)
{
	int n = mVector.indexOf(item);
	int i = mColumns.indexOf(column);
	QModelIndex from = createIndex(n, i, item);
	QModelIndex till = createIndex(n, i, item);
	emit dataChanged(from, till);
}

void VeQItemTableModel::onValueChanged(VeQItem *item)
{
	cellChanged(item, "value");
}

void VeQItemTableModel::onStateChanged(VeQItem *item)
{
	cellChanged(item, "state");
}

void VeQItemTableModel::onTextChanged(VeQItem *item)
{
	cellChanged(item, "text");
}

void VeQItemTableModel::onTextStateChanged(VeQItem *item)
{
	cellChanged(item, "textState");
}

void VeQItemTableModel::onDynamicPropertyChanged(VeQItem *item, const char *name)
{
	cellChanged(item, name);
}

void VeQItemTableModel::setupValueChanges(VeQItem *item, Flags options, int row)
{
	if (options == AddAllChildren)
		this->connect(item, SIGNAL(childAdded(VeQItem *)), SLOT(onRecursiveChildAdded(VeQItem *)));
	else if (options == AddChildren)
		this->connect(item, SIGNAL(childAdded(VeQItem *)), SLOT(onChildAdded(VeQItem *)));

	this->connect(item, SIGNAL(childAboutToBeRemoved(VeQItem*)), SLOT(onItemAboutToBeRemoved(VeQItem*)));

	// flatten the tree for the table view, only interested in the leafs..
	if (!item->isLeaf() && (mFlags & AddNonLeaves) == 0)
		return;

	// Use getValueAndChanges instead of connect, so values are requested after a disconnect.
	// Don't call the signal directly, since that would lead to a cellChanged signal.
	item->getValueAndChanges(this, SLOT(onValueChanged(VeQItem*)), false);
	this->connect(item, SIGNAL(stateChanged(VeQItem*,State)), SLOT(onStateChanged(VeQItem*)));
	this->connect(item, SIGNAL(textChanged(VeQItem*,QString)), SLOT(onTextChanged(VeQItem*)));
	this->connect(item, SIGNAL(textStateChanged(VeQItem*,State)), SLOT(onTextStateChanged(VeQItem*)));
	this->connect(item, SIGNAL(dynamicPropertyChanged(VeQItem*,const char*,QVariant)), SLOT(onDynamicPropertyChanged(VeQItem*,const char*)));

	appendItem(item, row);
}

void VeQItemTableModel::doInsertItem(VeQItem *item, int row)
{
	QString key(item->uniqueId());
	mHash.insert(key, item);
	mVector.insert(row, item);
}

void VeQItemTableModel::appendItem(VeQItem *item, int row)
{
	if (row == -1)
		row = mVector.count();

	beginInsertRows(QModelIndex(), row, row);
	doInsertItem(item, row);
	endInsertRows();
}

void VeQItemTableModel::setFlagsNoSignal(VeQItemTableModel::Flags flags)
{
	mFlags = flags;
	mColumns.clear();
	mColumns << "id";
	mColumns << "value" << "state";
	if (mFlags & WithText)
		mColumns << "text" << "textState";
	if (mFlags & WithSettingInfo)
		mColumns << "min" << "max" << "defaultValue";
}

// note: internal use, it doesn't emit signals, so both layoutChanged, modelReset can use it.
void VeQItemTableModel::clear()
{
	for (VeQItem *item : mVector)
		item->disconnect(this);
	mVector.clear();
	mHash.clear();
}

void VeQItemTableModel::doRemove(int n)
{
	VeQItem *item = mVector[n];

	item->disconnect(this);
	mHash.remove(item->uniqueId());
	mVector.remove(n);
}

void VeQItemTableModel::remove(int n)
{
	beginRemoveRows(QModelIndex(), n, n);
	doRemove(n);
	endRemoveRows();
}

void VeQItemTableModel::endInsertRows()
{
	QAbstractItemModel::endInsertRows();
	emit rowCountChanged();
}

void VeQItemTableModel::endRemoveRows()
{
	QAbstractItemModel::endRemoveRows();
	emit rowCountChanged();
}

void VeQItemTableModel::addExistingChildren(VeQItem *item, void *ctx)
{
	Q_UNUSED(ctx);
	setupValueChanges(item, AddAllChildren);
}


void VeQItemTableModel::onRecursiveChildAdded(VeQItem *item)
{
	item->foreachParentFirst(this, SLOT(addExistingChildren(VeQItem *, void *)), 0);
}

void VeQItemTableModel::onChildAdded(VeQItem *item)
{
	setupValueChanges(item);
}

void VeQItemTableModel::onItemAboutToBeRemoved(VeQItem *item)
{
	// More items can be monitored then there included in the model, branches e.g.
	if (!mHash.contains(item->uniqueId()))
		return;

	int n = mVector.indexOf(item);
	remove(n);
}

// "properties" / custom roles when the model is used for Qt Quick
QHash<int, QByteArray> VeQItemTableModel::roleNames() const
{
	static QHash<int, QByteArray> roles;

	if (roles.isEmpty()) {
		roles[IdRole] = "id";
		roles[UniqueIdRole] = "uid";
		roles[ValueRole] = "value";
		roles[StateRole] = "state";
		roles[TextRole] = "text";
		roles[TextStateRole] = "textState";
		roles[ItemRole] = "item";
	}

	return roles;
}

QVariant VeQItemTableModel::getValue(int row, int column)
{
	return data(index(row, column), VeQItemTableRoles::ValueRole);
}

void VeQItemTableModel::updateModel()
{
	if (!mCompleted)
		return;

	for (QString &uid: mUids) {
		if (uid.isEmpty())
			continue;
		VeQItem *item = VeQItems::getRoot()->itemGetOrCreate(uid, true, false);
		if (item == nullptr) {
			qWarning() << uid << "is not a valid unique id";
			continue;
		}
		addItem(item);
	}
}

void VeQItemTableModel::setFlags(VeQItemTableModel::Flags flags)
{
	if (mFlags == flags)
		return;
	setFlagsNoSignal(flags);
	updateModel();
	emit flagsChanged();
}

void VeQItemTableModel::setUids(const QStringList &uids)
{
	if (mUids == uids)
		return;
	mUids = uids;
	updateModel();
	emit uidsChanged();
}

void VeQItemTableModel::componentComplete()
{
	mCompleted = true;
	updateModel();
}

// return the actual data to be displayed for index
QVariant VeQItemTableModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid())
		return QVariant();

	VeQItem *item = static_cast<VeQItem*>(index.internalPointer());
	if (role == Qt::DisplayRole) {
		QString column = mColumns[index.column()];
		if (column == "id")
			role = UniqueIdRole;
		else if (column == "value")
			role = ValueRole;
		else if (column == "state")
			role = StateRole;
		else if (column == "text")
			role = TextRole;
		else if (column == "textState")
			role = TextStateRole;
		else
			return item->property(column.toLatin1());
	}

	switch (role) {
	case IdRole:
		return item->id();
	case UniqueIdRole:
		return item->uniqueId();
	case ValueRole:
		return item->getLocalValue();
	case StateRole:
		return item->getState();
	case TextRole:
		return item->getText();
	case TextStateRole:
		return item->getTextState();
	case ItemRole:
		return QVariant::fromValue(item);
	}

	return QVariant();
}

Qt::ItemFlags VeQItemTableModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::ItemFlags();

	Qt::ItemFlags flags = Qt::ItemIsEnabled | Qt::ItemIsSelectable;

	if (index.column() == 1)
		flags |= Qt::ItemIsEditable;

	return flags;
}

bool VeQItemTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	if (!index.isValid())
		return false;

	if (role == Qt::EditRole) {
		VeQItem *item = static_cast<VeQItem*>(index.internalPointer());
		item->setValue(value);
	}

	return true;
}

QVariant VeQItemTableModel::headerData(int section, Qt::Orientation orientation,
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
QModelIndex VeQItemTableModel::index(int row, int column, const QModelIndex &parent) const
{
	Q_UNUSED(parent);

	if (row < 0 || row >= mVector.count())
		return QModelIndex();

	if (column < 0 || column >= mColumns.count())
		return QModelIndex();

	VeQItem *item = mVector[row];

	return createIndex(row, column, item);
}

// Return the parent given an valid index.
QModelIndex VeQItemTableModel::parent(const QModelIndex &index) const
{
	Q_UNUSED(index);

	return QModelIndex();
}

// returns the number of rows (child count) of index
int VeQItemTableModel::rowCount(const QModelIndex &index) const
{
	if (index.column() >= 0)
		return 0;

	int count = mVector.count();
	return count;
}
