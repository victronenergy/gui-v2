#include <velib/qt/ve_qitem_loader.hpp>

VeQItemLoader::VeQItemLoader(VeQItem *root, QObject *parent) : QObject(parent),
	mRoot(root)
{
}

bool VeQItemLoader::addItem(VeQItem *item, QVariant value)
{
	// Only allow synchronized items. It does protect against all kind of weirdness,
	// like adding offline items, or adding them twice (since the state has changed)
	if (item->getState() != VeQItem::Synchronized)
		return false;

	// There is nothing to do if the value is already the intended one.
	if (item->getValue() == value)
		return true;

	item->produceValue(value, VeQItem::Preview);
	connect(item, SIGNAL(stateChanged(VeQItem*,State)), this, SLOT(onItemStateChange(VeQItem*)));
	mPendingItems.append(item);

	return true;
}

bool VeQItemLoader::addItem(const QString &uid, QVariant value)
{
	VeQItem *item = mRoot->itemGet(uid);
	if (item)
		return this->addItem(item, value);

	return false;
}

void VeQItemLoader::discard()
{
	foreach (VeQItem *item, mPendingItems)
		item->discardPreview();

	mPendingItems.clear();
}

void VeQItemLoader::commit()
{
	foreach (VeQItem *item, mPendingItems)
		item->commitPreview();
}

void VeQItemLoader::onItemStateChange(VeQItem *item)
{
	if (!mPendingItems.contains(item))
		return;

	VeQItem::State state = item->getState();
	bool removed = false;

	if (state == VeQItem::Synchronized) {
		removed = mPendingItems.removeOne(item);
	} else if (state != VeQItem::Storing) {
		removed = mPendingItems.removeOne(item);
		emit errorCommittingItem(item, state);
	}

	if (removed) {
		item->disconnect(this);

		if (mPendingItems.isEmpty())
			emit commitFinished();
	}
}
