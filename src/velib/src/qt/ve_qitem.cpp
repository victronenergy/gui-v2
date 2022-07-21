#include <QDebug>
#include <QMetaObject>
#include <QStringList>

#include <velib/qt/ve_qitem.hpp>

VeQItem::VeQItem(VeQItemProducer *producer, QObject *parent) :
	QObject(parent),
	mState(Idle),
	mStateWhilePreviewing(Idle),
	mTextState(Idle),
	mTextStateWhilePreviewing(Idle),
	mProducer(producer),
	mIsLeaf(false),
	mWatched(false),
	mSeen(false)
{
}

VeQItem::~VeQItem() {
	foreach (VeQItem *child, mChilds)
		itemDeleteChild(child);
}

void VeQItem::setParent(QObject *parent)
{
	QObject::setParent(parent);
	foreachParentFirst(this, SLOT(resetId(VeQItem *, void *)), 0);
}

void VeQItem::getValueAndChanges(QObject *obj, const char *member, bool fetch, bool queued)
{
	QString method(&member[1]);
	method = method.left(method.indexOf("("));
	connect(this, SIGNAL(valueChanged(VeQItem*,QVariant)), obj, member);
	updateWatched();
	if (fetch)
		QMetaObject::invokeMethod(obj, method.toLatin1(), queued ? Qt::QueuedConnection : Qt::AutoConnection,
									Q_ARG(VeQItem*, this), Q_ARG(QVariant, getValue()));

	// there is BUG in qt 4, see https://bugreports.qt.io/browse/QTBUG-4844
	// which causes disconnectNotify not to be called when the receiver is deleted.
	// Hence monitor such deletions and explicitly disconnect the receiver upon destruction.
	connect(obj, SIGNAL(destroyed(QObject*)), SLOT(receiverDestroyed(QObject*)));
}

void VeQItem::commitPreview()
{
	setValue(mValue);
}

void VeQItem::discardPreview()
{
	if (mState != Preview)
		return;

	mState = mStateWhilePreviewing;
	mValue = mValueWhilePreviewing;
	mTextState = mTextStateWhilePreviewing;
	mText = mTextWhilePreviewing;
	emit valueChanged(this, mValue);
	emit stateChanged(this, mState);
	emit textChanged(this, mText);
	emit textStateChanged(this, mTextState);
}

void VeQItem::updateWatched()
{
	bool watched = receivers(SIGNAL(valueChanged(VeQItem*,QVariant))) != 0;
	if (mWatched == watched)
		return;
	mWatched = watched;
	watchedChanged();
}

void VeQItem::receiverDestroyed(QObject *obj)
{
	disconnect(obj);
}

void VeQItem::disconnectNotify(const char *signal)
{
	Q_UNUSED(signal);
	updateWatched();
}

/**
 * The mWatched member keeps track if there is a receiver interested in value
 * changes at all. In such cases there is no need to refresh the value continuesly
 * since it will be ignored anyway. The watchedChanged can be overridden by a
 * producer.
 *
 * Warning: This function violates the object-oriented principle of modularity.
 * However, it might be useful when you need to perform expensive initialization
 * only if something is connected to a signal.
 */
void VeQItem::watchedChanged()
{
}

VeQItem *VeQItem::itemChild(int n)
{
	if (n >= mChilds.count())
		return 0;

	// check if this is expensive
	return mChilds[mChilds.keys()[n]];
}

void VeQItem::itemAddChild(QString id, VeQItem *item)
{
	item->setId(id);
	item->setParent(this);
	mIsLeaf = false;
	emit childAboutToBeAdded(item);
	mChilds[id] = item;
	emit childAdded(item);
	item->afterAdd();
	emit childIdsChanged();
}

void VeQItem::afterAdd()
{
}

void VeQItem::itemDeleteChild(VeQItem *child)
{
	emit childAboutToBeRemoved(child);
	mChilds.remove(child->mId);
	emit childRemoved(child);
	child->deleteLater();
	emit childIdsChanged();
}

// deletes the item and removes it from its parent
void VeQItem::itemDelete()
{
	itemParent()->itemDeleteChild(this);
}

QString VeQItem::getRelId(VeQItem *ancestor)
{
	Q_ASSERT(ancestor != 0);
	if (this == ancestor)
		return "/";
	VeQItem *parent = itemParent();
	if (parent == 0)
		return QString();
	QString p = parent->getRelId(ancestor);
	if (p.isEmpty())
		return p;
	if (!p.endsWith('/'))
		p += '/';
	p += id();
	return p;
}

VeQItem *VeQItem::createChild(QString id, QVariant var)
{
	VeQItem *item = createChild(id);
	item->produceValue(var);
	return item;
}

VeQItem *VeQItem::createChild(QString id, bool isLeaf, bool isTrusted)
{
	if (isTrusted)
		Q_ASSERT(producer());
	else if (!producer())
		return nullptr;

	VeQItem *item = producer()->createItem();
	item->mIsLeaf = isLeaf;
	itemAddChild(id, item);
	return item;
}

QStringList VeQItem::getChildIds() const
{
	QStringList rv;
	for (const auto &c : mChilds)
		rv.append(c->id());
	return rv;
}

void VeQItem::produceValue(QVariant variant, State state, bool forceChanged)
{
	// Stop updating the value from the other side as long as it's previewed.
	// Keep the actual values around though, for the case the preview is discarded.
	if (mState == VeQItem::Preview) {
		mValueWhilePreviewing = variant;
		mStateWhilePreviewing = state;
		return;
	}

	if (state == VeQItem::Preview) {
		// Only allow previews when online / in sync etc.
		if (mState != Synchronized)
			return;

		// Text is normally produced client-side, but when previewing, we have to fake it.
		produceText(variant.toString(), VeQItem::Preview);

		mValueWhilePreviewing = mValue;
		mStateWhilePreviewing = mState;
	}

	bool stateIsChanged = forceChanged || mState != state;
	bool valueIsChanged = forceChanged || mValue != variant;

	mState = state;
	mValue = variant;

	if (!mSeen && state == VeQItem::Synchronized) {
		mSeen = true;
		emit seenChanged();
	}

	// Temporary:
	if (valueIsChanged) {
		if (qEnvironmentVariableIntValue("DBUS_DEBUG") > 0) {
			qWarning() << "  --" << uniqueId() << "::" << mValue;
		}
	}

	if (stateIsChanged)
		emit stateChanged(this, state);
	if (valueIsChanged)
		emit valueChanged(this, variant);
}

void VeQItem::produceText(QString text, VeQItem::State state)
{
	// Stop updating the value from the other side as long as it's previewed.
	// Keep the actual values around though, for the case the preview is discarded.
	if (mTextState == VeQItem::Preview) {
		mTextWhilePreviewing = text;
		mTextStateWhilePreviewing = state;
		return;
	}

	if (state == VeQItem::Preview) {
		mTextWhilePreviewing = mText;
		mTextStateWhilePreviewing = mTextState;
	}

	bool stateIsChanged = mTextState != state;
	bool textIsChanged = mText != text;

	mTextState = state;
	mText = text;

	if (stateIsChanged)
		emit textStateChanged(this, state);
	if (textIsChanged)
		emit textChanged(this, text);
}

QString VeQItem::id()
{
	return mId;
}

void VeQItem::setId(QString id)
{
	Q_ASSERT(parent() == 0);

	mId = id;
	setObjectName(id);
}

QString VeQItem::uniqueId()
{
	if (!mUid.isNull())
		return mUid;

	QString ret;
	uniqueId(ret);
	return ret;
}

void VeQItem::uniqueId(QString &uid)
{
	VeQItem *theParent = qobject_cast<VeQItem *>(parent());
	if (theParent) {
		theParent->uniqueId(uid);
		uid += (uid == "" ? "" : "/") + mId;
	} else {
		uid = mId;
	}
}

void VeQItem::resetId(VeQItem *item, void *ctx)
{
	Q_UNUSED(ctx);
	QString str;
	item->uniqueId(str);
	item->mUid = str;
}

VeQItem *VeQItem::itemGet(QString uid)
{
	VeQItem *item = this;

	// tolerate ids starting with a slash
	if (uid.startsWith("/"))
		uid = uid.mid(1);

	if (uid.isEmpty())
		return this;

	QStringList parts = uid.split('/');
	for (QString const &part: parts) {
		item = item->itemChildren().value(part);
		if (item == 0)
			return 0;
	}
	return item;
}

/*
 * If you know what you are doing this function won't fail. Worse case it
 * will throw a out of memory exception. When doing bad things it will
 * assert / crash and you need to stop doing bad things.
 *
 * Unless isTrusted is set to false, e.g. when accepting string from qml.
 * Obviously you need to check the return value then since it might be a
 * nullptr.
 */
VeQItem *VeQItem::itemGetOrCreate(QString uid, bool isLeaf, bool isTrusted)
{
	VeQItem *item = this;

	// tolerate ids starting with a slash
	if (uid.startsWith("/"))
		uid = uid.mid(1);

	if (uid.isEmpty())
		return this;

	QStringList parts = uid.split('/');
	int n = 1;
	for (QString const &part: parts) {
		VeQItem *child = item->itemChildren().value(part);
		if (child == 0)
			child = item->createChild(part, isLeaf && n == parts.count(), isTrusted);
		item = child;
		n++;
	}
	return item;
}

VeQItem *VeQItem::itemGetOrCreateAndProduce(QString uid, QVariant value)
{
	VeQItem *item = itemGetOrCreate(uid);
	item->produceValue(value);
	return item;
}

VeQItem *VeQItem::itemRoot()
{
	VeQItem *ret = this;
	for (;;) {
		VeQItem *parent = ret->itemParent();
		if (!parent)
			return ret;
		ret = parent;
	}
}

VeQItem *VeQItem::itemParent()
{
	return qobject_cast<VeQItem *>(parent());
}

QVariant VeQItem::itemProperty(const char *name)
{
	if (mPropertyState[name] != Synchronized)
		mPropertyState[name] = Requested;
	return property(name);
}

void VeQItem::itemProduceProperty(const char *name, const QVariant &value, VeQItem::State state)
{
	bool changed = property(name) != value;
	mPropertyState[name] = state;
	setProperty(name, value);
	if (changed)
		emit dynamicPropertyChanged(this, name, value);
}

// returns the index in the parents it child ids.
int VeQItem::index()
{
	VeQItem *theParent = qobject_cast<VeQItem *>(parent());
	if (!theParent)
		return 0;

	return theParent->itemChildren().keys().indexOf(mId);
}

void VeQItem::foreachChildFirst(VeQItemForeach *each)
{
	foreach (VeQItem *child, mChilds)
		child->foreachChildFirst(each);
	each->handleItem(this);
}

void VeQItem::foreachChildFirst(QObject *obj, const char *member, void *ctx)
{
	VeQItemForeach each(obj, member, ctx);
	foreachChildFirst(&each);
}

void VeQItem::foreachChildFirst(std::function<void(VeQItem *)> const & f)
{
	foreach (VeQItem *child, mChilds)
		child->foreachChildFirst(f);
	f(this);
}

void VeQItem::foreachParentFirst(VeQItemForeach *each)
{
	each->handleItem(this);
	foreach (VeQItem *child, mChilds)
		child->foreachParentFirst(each);
}

void VeQItem::foreachParentFirst(QObject *obj, const char *member, void *ctx)
{
	VeQItemForeach each(obj, member, ctx);
	foreachParentFirst(&each);
}

void VeQItem::foreachParentFirst(std::function<void(VeQItem *)> const & f)
{
	f(this);
	foreach (VeQItem *child, mChilds)
		child->foreachParentFirst(f);
}

void VeQItem::setState(VeQItem::State state)
{
	if (mState == state)
		return;
	mState = state;
	emit stateChanged(this, state);
}

void VeQItem::setTextState(VeQItem::State state)
{
	if (mTextState == state)
		return;
	mTextState = state;
	emit textStateChanged(this, state);
}

/* QT Quick Part */

void VeQuickItem::setUid(QString uid)
{
	if (mItem) {
		// check it changed at all
		if (uid == mItem->uniqueId())
			return;

		if (mItem->uniqueId().isEmpty() && mItem->getValue().isValid())
			qDebug() << "Changing an uid of an item with valid value set is weird, ignoring value" <<
						mItem->getValue() << "for" << uid;
	}

	teardown();
	if (uid == "")
		mItem = new VeQItemLocal(0);
	else
		mItem = VeQItems::getRoot()->itemGetOrCreate(uid, true, false);
	if (mItem)
		setup();
	emit uidChanged();
}

/**
 * Handle changes of the value property.
 *
 * In qml it should be possible to set the value property of local items (the once
 * "produced"), but not the once being bound (the once "consumed"). In the latter
 * case the local value would otherwise be updated before it is even send to the remote
 * side (which might refuse the change, or not even be available at the moment etc). In
 * such a case the value property should be updated after the value was actually changed
 * and confirmed to us, which is exactly what setValue does and that should be used
 * instead in such cases (and will act exactly the same on local items).
 *
 * For example:
 *
 * VeQuickItem {
 *   value: "This should work fine!"
 * }
 *
 * VeQuickItem {
 *   value: "This should be refused"
 *   uid: "Some/Remote/Value"
 * }
 *
 * The latter should be changed to:
 *
 *  VeQuickItem {
 *   uid: "Some/Remote/Value"
 *
 *   Component.onCompleted: setValue("This should work as well")
 *   onValueChanged: console.log("the remote value changed to " + value)
 * }
 */
void VeQuickItem::setValueProperty(QVariant value)
{
	if (mItem->uniqueId() != "") {
		qDebug() << "ignoring request to set value on bound qml Item, please use setValue instead";
		return;
	}

	mItem->produceValue(value);
	mItem->produceText(value.toString());
}

VeQItem *VeQItems::getRoot()
{
	static VeQItem theRoot(0);
	return &theRoot;
}
