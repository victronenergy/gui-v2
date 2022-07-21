#ifndef VEQITEMDISKLOADER_HPP
#define VEQITEMDISKLOADER_HPP

#include <QObject>

#include <velib/qt/ve_qitem.hpp>

/**
 * @brief The VeQitemLoader class is previewing multiple VeQItems, which the user
 * can view before choosing to commit or discard them. This allows e.g. loading a
 * settings file in VictronConnect and then presenting the pending changes, which
 * the user can commit or discard.
 */
class VE_QITEM_EXPORT VeQItemLoader : public QObject
{
	Q_OBJECT

public:
	explicit VeQItemLoader(VeQItem *root, QObject *parent = 0);

	bool addItem(VeQItem *item, QVariant value);
	bool addItem(const QString &uid, QVariant value);

	void discard();
	void commit();

	bool hasPendingItems() { return mPendingItems.size() > 0; }

signals:
	void commitFinished();
	void errorCommittingItem(VeQItem *item, VeQItem::State state);

private slots:
	void onItemStateChange(VeQItem *item);

private:
	VeQItem *mRoot;
	QList<VeQItem *> mPendingItems;
};

#endif
