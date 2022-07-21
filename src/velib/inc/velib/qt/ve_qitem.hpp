#ifndef _VELIB_QT_VE_QITEM_HPP_
#define _VELIB_QT_VE_QITEM_HPP_

#include <functional>

#include <QtCore/QtGlobal>
#include <QDebug>
#include <QList>
#include <QObject>
#include <QString>
#include <QVariant>

#ifdef CFG_VE_QITEM_EXPORT
# if CFG_VE_QITEM_EXPORT
#  define VE_QITEM_EXPORT Q_DECL_EXPORT
# else
#  define VE_QITEM_EXPORT Q_DECL_IMPORT
# endif
#else
# define VE_QITEM_EXPORT
#endif

class VeQItem;
class VeQItemProducer;

/*
 * Just a helper to invoke a slots as callback functions.
 * Should actually be hidden, but needs to be in some header file
 * for moc to see it, so it lives here for now.
 */
class VE_QITEM_EXPORT VeQItemForeach : public QObject {
	Q_OBJECT

public:
	// note: member is SLOT(xyz) in obj to be invoke from handleItem.
	VeQItemForeach(QObject *obj, const char *member, void *ctx) :
		mCtx(ctx)
	{
		if (member)
			obj->connect(this, SIGNAL(doHandleItem(VeQItem*,void*)), member, Qt::DirectConnection);
	}

	virtual void handleItem(VeQItem *item)
	{
		emit doHandleItem(item, mCtx);
	}

signals:
	void doHandleItem(VeQItem *item, void *ctx);

protected:
	void *mCtx;
};

/**
 * Base class for an item. An item can hold any information about a
 * device / system or also settings. It can be associated with a local device,
 * bus or something at the other end of the world with many interfaces in
 * between. We don't care here, it is left to the producer to take care of that.
 * The root of the tree is special in that sense, it is the only item which is not
 * produced (and hence producer of the root is 0), see VeQItems.
 */
class VE_QITEM_EXPORT VeQItem : public QObject
{
	Q_OBJECT
	Q_ENUMS(State)
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged WRITE setValue)
	Q_PROPERTY(QVariant text READ getText NOTIFY valueChanged)
	Q_PROPERTY(bool seen READ getSeen NOTIFY seenChanged)
	Q_PROPERTY(QString uid READ uniqueId CONSTANT)
	Q_PROPERTY(QString id READ id CONSTANT)
	Q_PROPERTY(QStringList childIds READ getChildIds NOTIFY childIdsChanged)

public:
	typedef QMap<QString, VeQItem *> Children;

	enum State {
		Idle,
		Offline,
		Requested,
		Storing,
		Synchronized,
		Preview ///< Used by GUIs to change the UI as if the values are already applied..
	};

	explicit VeQItem(VeQItemProducer *producer, QObject *parent = 0);
	~VeQItem();

	/**
	 * @brief request for the item its value.
	 */
	virtual QVariant getValue()
	{
		if (mState == Idle)
			setState(Requested);
		return mValue;
	}

	/**
	 * Returns the locally stored value without requesting it when not available.
	 * This is especially usefull in logging, where it is not desireable to change
	 * the state of the VeQItem.
	 */
	virtual QVariant getLocalValue()
	{
		return mValue;
	}

	/**
	 * Invokes the slot member with the current value, and future onChangeEvents.
	 */
	void getValueAndChanges(QObject *obj, const char *member, bool fetch = true, bool queued = false);

	/**
	 * Like getValue, but a human representable version.
	 */
	virtual QString getText()
	{
		return mText;
	}

	/**
	 * Like getValue, in general no assumption can be made about the time
	 * it takes to make a change.
	 *
	 * This implementation is expected to be overridden, where the base
	 * method must be called.
	 */
	virtual int setValue(QVariant const &value)
	{
		Q_UNUSED(value)

		// Setting a previewed item will get it out of preview mode.
		if (mState == VeQItem::Preview) {
			mValueWhilePreviewing.clear();
			mStateWhilePreviewing = Idle;
		}

		if (mTextState == VeQItem::Preview) {
			mTextWhilePreviewing.clear();
			mTextState = Idle;
		}

		return 0;
	}

	/**
	 * commits a value that is being previewed
	 *
	 * A value be previewed by calling produceValue with Preview as state.
	 * It will then no longer be updated from the remote side. CommitPending
	 * will set the Value and resume normal operation thereafter.
	 *
	 * NOTE: since previewing changes everything as if the value was already
	 * applied, this also means that anything else consuming these same items
	 * (e.g. loggers / forwarders etc.) will start using the value as if it comes
	 * from the end point itself. This might cause confusion!! But at the time of
	 * writing the scope of this feature is to just make it easy for VictronConnect
	 * to preview values before sending them, all is fine.
	 */
	void commitPreview();

	/**
	 * Discard the preview value and resume normal operation, @see commitPreview.
	 * The value / state will be set to what it would have been if the value was
	 * normally updated.
	 */
	void discardPreview();

	Children const &itemChildren() const { return mChilds; }
	State getState() { return mState; }
	State getTextState() { return mTextState; }
	bool isLeaf() { return mIsLeaf; }

	/**
	 * returns if the item ever got in a synchronized state.
	 *
	 * If the value was set to an undefined value, seen will be true, so it is
	 * known the item exists, but just has no valid value. Seen cannot be unset.
	 */
	bool getSeen() { return mSeen; }

	QStringList getChildIds() const;

	virtual void produceValue(QVariant value, State state = Synchronized, bool forceChanged = false);
	virtual void produceText(QString text, State state = Synchronized);

	virtual VeQItem *createChild(QString id, bool isLeaf = true, bool isTrusted = true);
	VeQItem *createChild(QString id, QVariant var);

	QString id();
	void setId(QString id);
	QString uniqueId();

	// note the Item prefixes are a bit verbose, but prevents name collision with QObjects
	// own child, parent member functions.
	VeQItem *itemChild(int n);
	Q_INVOKABLE VeQItem *itemGet(QString uid);
	Q_INVOKABLE VeQItem *itemGetOrCreate(QString uid, bool isLeaf = true, bool isTrusted = true);
	Q_INVOKABLE VeQItem *itemGetOrCreateAndProduce(QString uid, QVariant value);

	VeQItem *itemRoot();
	Q_INVOKABLE VeQItem *itemParent();

	/**
	 * Additional / optional properties, like min, max, defaultValue
	 * property("min") etc will return them or an invalid variant when non existing.
	 */
	virtual QVariant itemProperty(const char *name);
	virtual void itemProduceProperty(const char *name, const QVariant &value, State state = Synchronized);

	VeQItemProducer *producer() { return mProducer; }
	void setProducer(VeQItemProducer *producer) { mProducer = producer; }

	int index();

	void foreachChildFirst(QObject *obj, const char *member, void *ctx = 0);
	void foreachChildFirst(VeQItemForeach *each);
	void foreachChildFirst(std::function<void(VeQItem *)> const & f);

	void foreachParentFirst(QObject *obj, const char *member, void *ctx = 0);
	void foreachParentFirst(VeQItemForeach *each);
	void foreachParentFirst(std::function<void(VeQItem *)> const & f);

	void itemAddChild(QString id, VeQItem *item);
	void itemDeleteChild(VeQItem *child);
	void itemDelete();

	/// Returns the relative path from `ancestor` to `this`.
	/// @returns The relative path (for now, starting with a slash). If `ancestor`
	/// is not an ancestor of `this` an empty string will be returned.
	QString getRelId(VeQItem *ancestor);

signals:
	void dynamicPropertyChanged(VeQItem *item, char const *name, QVariant value);
	void valueChanged(VeQItem *item, QVariant var);
	void textChanged(VeQItem *item, QString text);
	void seenChanged();
	void childIdsChanged();

	/*
	 * Note the two signals below are half broken, they can succefully pass they
	 * state in the qt5 world, but not in the qt4 since it needs the full namespace
	 * there, iow VeQItem::State. However adding that would break all connects, and
	 * in the qt4 world that means at runtime. As a workaround, as long as qt4 is
	 * support, create a slot without the state parameter and get it with getState
	 * instead.
	 */
	void stateChanged(VeQItem *item, State state);
	void textStateChanged(VeQItem *item, State state);

	/*
	 * Note: if you want to connect to signals of the childs in a cross thread
	 * manner, a connection should be made with Qt::BlockingQueuedConnection.
	 * Perhaps such use should simply be prohibited.
	 */
	void childAboutToBeAdded(VeQItem *item);
	void childAdded(VeQItem *item);
	void childAboutToBeRemoved(VeQItem *item);
	void childRemoved(VeQItem *item);

protected:
	using QObject::disconnectNotify; // tell the compiler we want both, this one and QObject's
	virtual void disconnectNotify(const char *signal);
	virtual void watchedChanged();
	// by this time all signals can be assumed to be hooked up..
	virtual void afterAdd();
	void setState(State state);
	void setTextState(State state);
	// last point before the item is announced
	virtual void setParent(QObject *parent);

protected slots:
	void receiverDestroyed(QObject *obj);
	void resetId(VeQItem *item, void *ctx);

private:
	void uniqueId(QString &uid);
	void updateWatched();

protected:
	QString mId;
	Children mChilds;
	QVariant mValue;
	QVariant mValueWhilePreviewing;
	State mState;
	State mStateWhilePreviewing;
	QString mText;
	QString mTextWhilePreviewing;
	State mTextState;
	State mTextStateWhilePreviewing;
	VeQItemProducer *mProducer;
	bool mIsLeaf;
	QString mUid;
	bool mWatched;
	bool mSeen;
	QHash<QString, State> mPropertyState;
};

Q_DECLARE_METATYPE(VeQItem *)

/* Singleton to get the root item */
class VE_QITEM_EXPORT VeQItems
{
public:
	static VeQItem *getRoot();
};

class VE_QITEM_EXPORT VeQuickItem : public QObject {
	Q_OBJECT
	Q_PROPERTY(QVariant defaultValue READ getDefault NOTIFY defaultChanged)
	Q_PROPERTY(QVariant min READ getMin NOTIFY minChanged)
	Q_PROPERTY(QVariant max READ getMax NOTIFY maxChanged)
	Q_PROPERTY(QVariant text READ getText NOTIFY textChanged)
	Q_PROPERTY(QString uid READ getUid NOTIFY uidChanged WRITE setUid)
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged WRITE setValueProperty)
	Q_PROPERTY(VeQItem::State state READ getState NOTIFY stateChanged)
	Q_PROPERTY(bool seen READ getSeen NOTIFY seenChanged)
	Q_PROPERTY(QStringList childIds READ getChildIds NOTIFY childIdsChanged)

public:
	VeQuickItem() : QObject(),
		mItem(0)
	{
		setUid("");
	}

	~VeQuickItem()
	{
		teardown();
	}

	QVariant getDefault() { return mItem->itemProperty("defaultValue"); }
	QVariant getMax() { return mItem->itemProperty("max"); }
	QVariant getMin() { return mItem->itemProperty("min"); }

	QString getText() { return mItem->getText(); }
	QString getUid() { return mItem->uniqueId(); }
	void setUid(QString uid);
	QVariant getValue() { return mItem->getValue(); }
	VeQItem::State getState() { return mItem->getState(); }
	bool getSeen() { return mItem->getSeen(); }
	QStringList getChildIds() { return mItem->getChildIds(); }

	Q_INVOKABLE int setValue(QVariant const &value) { return mItem->setValue(value); }
	void setValueProperty(QVariant value);

	Q_INVOKABLE QString childUId(const QString &id) { return getUid() + '/' + id; }

signals:
	void defaultChanged();
	void minChanged();
	void maxChanged();
	void seenChanged();
	void childIdsChanged();

	void textChanged(VeQItem *item, QString text);
	void uidChanged();
	void valueChanged(VeQItem *item, QVariant var);
	void stateChanged();

protected slots:
	virtual void onDynamicPropertyChanged(VeQItem *item, char const *name)
	{
		Q_UNUSED(item);

		if (QLatin1String(name) == "min")
			emit minChanged();
		else if (QLatin1String(name) == "max")
			emit maxChanged();
		else if (QLatin1String(name) == "defaultValue")
			emit defaultChanged();
	}

	void onItemDestroyed()
	{
		qWarning() << "item destroyed while used in QML" << sender()->objectName();
		teardown();
	}

protected:
	VeQItem *mItem;

private:
	void setup()
	{
		mItem->getValueAndChanges(this, SIGNAL(valueChanged(VeQItem*,QVariant)));

		connect(mItem, SIGNAL(stateChanged(VeQItem*,State)), SIGNAL(stateChanged()));
		emit stateChanged();

		connect(mItem, SIGNAL(textChanged(VeQItem*,QString)), SIGNAL(textChanged(VeQItem*,QString)));
		emit textChanged(mItem, mItem->getText());

		connect(mItem, SIGNAL(seenChanged()), SIGNAL(seenChanged()));
		emit seenChanged();

		connect(mItem, SIGNAL(childIdsChanged()), SIGNAL(childIdsChanged()));
		emit childIdsChanged();

		connect(mItem, SIGNAL(destroyed()), SLOT(onItemDestroyed()));

		connect(mItem, SIGNAL(dynamicPropertyChanged(VeQItem*,const char*,QVariant)), SLOT(onDynamicPropertyChanged(VeQItem*,char const *)));
		emit minChanged();
		emit maxChanged();
		emit defaultChanged();
	}

	void teardown()
	{
		if (mItem == 0)
			return;

		mItem->disconnect(this);
		if (mItem->uniqueId() == "")
			delete mItem;
		mItem = 0;
	}
};

/*
 * Typically VeQItemProducers provide access to remote variable/settings by some
 * kind of communication protocol and create items of a Producer specific type,
 * see VeQItemProducer::createItem. The VeQItemLocal is a VeQItem which doesn't
 * have a remote backend, but all values set to it are immediate applied. A none
 * overloaded VeQItemProducer uses such Items, so it can be used to easily create
 * fake remote devices / settings etc, as for example used by Victron Connect.
 * Any ItemProducer with a remote backend is expected to overload VeQItemProducer
 * and overload createItem and return a VeQItem or derived class and not a
 * VeQItemLocal one.
 */
class VE_QITEM_EXPORT VeQItemLocal : public VeQItem
{
	Q_OBJECT

public:

	explicit VeQItemLocal(VeQItemProducer *producer, QObject *parent = 0) :
		VeQItem(producer, parent)
	{}

	virtual int setValue(QVariant const &value)
	{
		VeQItem::setValue(value);
		produceValue(value);

		return 0;
	}
};

/*
 * Base class for a provider of items. This is almost the same as
 * a dbus service, but a ItemProvider can contain more then one dbus
 * service. E.g. a remote CCGX connection allowing accesses to the dbus
 * provides all dbus services of the remote side at once.
 */
class VE_QITEM_EXPORT VeQItemProducer : public QObject
{
	Q_OBJECT

public:

	/* Note: the root item must exists for the live time of the item producers */
	VeQItemProducer(VeQItem *root, QString id, QObject *parent = 0) :
		QObject(parent),
		mProducerRoot(createItem())
	{
		root->itemAddChild(id, mProducerRoot);
	}

	/*
	 * Typically producers have some open call with a producer specific arguments
	 * what to open. There used to be a dummy virtual open here to illustrate
	 * that likely you need an open, however that bites producers which have an
	 * open call with default arguments, since the compiler doesn't which one to
	 * call. So change it to comment instead, producer likely need
	 *
	 * bool open(args) { .... }
	 *
	 * to set up a connection, where arguments depends on the producer in question.
	 */

	// factory function for items
	virtual VeQItem *createItem() { return new VeQItemLocal(this); }

	/*
	 * Get item where services are added.
	 * by default services register in the root item of its producer ..
	 */
	virtual VeQItem *services() { return mProducerRoot; }

protected:
	VeQItem *mProducerRoot;
};

/** Info about a setting, it won't create it */
class VeQItemSettingInfo
{
public:
	VeQItemSettingInfo() {}
	VeQItemSettingInfo(QString path, QVariant defaultValue,
					   QVariant min = QVariant(), QVariant max = QVariant(),
					   bool silent = false) :
		mPath(path),
		mDefaultValue(defaultValue),
		mMin(min),
		mMax(max),
		mSilent(silent)
	{
	}

protected:
	QString mPath;
	QVariant mDefaultValue;
	QVariant mMin;
	QVariant mMax;
	bool mSilent;

	friend class VeQItemSettings;
	friend class VeQItemDbusSettings;
};

/** Info about multiple settings, it won't create them */
class VeQItemSettingsInfo
{
public:
	VeQItemSettingsInfo() {}
	virtual ~VeQItemSettingsInfo() {}

	void add(QString path, QVariant defaultValue,
					 QVariant min = QVariant(), QVariant max = QVariant(),
					 bool silent = false)
	{
		mInfo.append(VeQItemSettingInfo(path, defaultValue, min, max, silent));
	}

	QVector<VeQItemSettingInfo> const &info() const
	{
		return mInfo;
	}

private:
	QVector<VeQItemSettingInfo> mInfo;
};

/** The class creating / accessing the settings */
class VeQItemSettings
{
public:
	VeQItemSettings(VeQItem *parent, QString id)
	{
		mRoot = parent->itemGetOrCreate(id, false);
	}
	virtual ~VeQItemSettings() {}

	VeQItem* root() { return mRoot; }
	virtual bool addSettings(VeQItemSettingsInfo const &info)
	{
		for (VeQItemSettingInfo const &setting: info.info())
			root()->itemGetOrCreateAndProduce("Settings/" + setting.mPath, setting.mDefaultValue);
		return true;
	}

	virtual VeQItem *add(QString path, QVariant defaultValue,
						 QVariant min = QVariant(), QVariant max = QVariant(),
						 bool silent = false)
	{
		VeQItemSettingsInfo info = VeQItemSettingsInfo();
		info.add(path, defaultValue, min, max, silent);
		if (!addSettings(info))
			return nullptr;
		return root()->itemGetOrCreate("Settings/" + path);
	}

protected:
	VeQItem *mRoot;
};

#endif
