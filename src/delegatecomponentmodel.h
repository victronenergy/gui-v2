/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_DELEGATECOMPONENTMODEL_H
#define VICTRON_GUIV2_DELEGATECOMPONENTMODEL_H

#include <private/qqmlobjectmodel_p.h>
#include <qqmlintegration.h>
#include <QQmlComponent>
#include <QQuickItem>
#include <veutil/qt/ve_quick_item.hpp>

namespace Victron {
namespace VenusOS {

class DelegateComponentModelPrivate;

/*
	A lightweight entry in a DelegateComponentModel.

	Each entry holds a QQmlComponent that will only be instantiated when the
	ListView needs the item (i.e. when it scrolls into or near the viewport).
	The preferredVisible property controls whether the entry appears in the
	model at all; set it to false to filter the entry out without ever
	constructing its delegate.

	The optional dataItem property provides a VeQuickItem whose properties
	(valid, value, seen, max, etc.) can be referenced in preferredVisible
	bindings without needing to instantiate the delegate:

	    DelegateComponent {
	        dataItem: VeQuickItem { uid: root.bindPrefix + "/Foo" }
	        preferredVisible: dataItem.valid
	        ListText { dataItem.uid: root.bindPrefix + "/Foo" }
	    }

	Note: the delegate's own dataItem.uid will create a second VeQuickItem
	bound to the same path. This duplication is intentional and cheap — the
	backend shares the actual subscription data, so a duplicate VeQuickItem
	is just a lightweight QObject wrapper with negligible overhead. The
	alternative (making the readonly dataItem alias in list item types
	writable so it could be pointed at the DelegateComponent's instance)
	would be highly invasive, error-prone, and save only a single QObject
	instantiation per visible delegate.
*/
class DelegateComponent : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged FINAL)
	Q_PROPERTY(VeQuickItem *dataItem READ dataItem WRITE setDataItem NOTIFY dataItemChanged FINAL)
	Q_PROPERTY(bool preferredVisible READ preferredVisible WRITE setPreferredVisible NOTIFY preferredVisibleChanged FINAL)
	Q_CLASSINFO("DefaultProperty", "delegate")

public:
	explicit DelegateComponent(QObject *parent = nullptr);

	QQmlComponent *delegate() const;
	void setDelegate(QQmlComponent *delegate);

	VeQuickItem *dataItem() const;
	void setDataItem(VeQuickItem *dataItem);

	bool preferredVisible() const;
	void setPreferredVisible(bool visible);

Q_SIGNALS:
	void delegateChanged();
	void dataItemChanged();
	void preferredVisibleChanged();

private:
	QQmlComponent *m_delegate = nullptr;
	VeQuickItem *m_dataItem = nullptr;
	bool m_preferredVisible = true;
};

/*
	A virtualized replacement for VisibleItemModel.

	Where VisibleItemModel eagerly constructs every child item at declaration
	time, DelegateComponentModel holds only lightweight DelegateComponent objects.
	The actual delegate component for each entry is instantiated on demand by
	the ListView (when the entry scrolls into or near the viewport) and
	destroyed when the ListView releases it (when it scrolls out).

	Usage:

	    GradientListView {
	        model: DelegateComponentModel {
	            DelegateComponent {
	                ListSwitch { text: "Enable X" }
	            }
	            DelegateComponent {
	                preferredVisible: someCondition
	                ListNavigation { text: "Advanced" }
	            }
	        }
	    }

	Entries with preferredVisible=false are excluded from the model entirely:
	no row, no delegate, no object.
*/
class DelegateComponentModel : public QQmlInstanceModel
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QQmlListProperty<Victron::VenusOS::DelegateComponent> entries READ entries NOTIFY entriesChanged FINAL)
	Q_CLASSINFO("DefaultProperty", "entries")

public:
	explicit DelegateComponentModel(QObject *parent = nullptr);
	~DelegateComponentModel() override;

	int count() const override;
	bool isValid() const override;
	QObject *object(int index, QQmlIncubator::IncubationMode incubationMode = QQmlIncubator::AsynchronousIfNested) override;
	ReleaseFlags release(QObject *object, ReusableFlag reusable = NotReusable) override;
	QVariant variantValue(int index, const QString &role) override;
	void setWatchedRoles(const QList<QByteArray> &) override {}
	QQmlIncubator::Status incubationStatus(int index) override;
	int indexOf(QObject *object, QObject *context) const override;

	QQmlListProperty<DelegateComponent> entries();

Q_SIGNALS:
	void entriesChanged();

private:
	static void entries_append(QQmlListProperty<DelegateComponent> *prop, DelegateComponent *entry);
	static qsizetype entries_count(QQmlListProperty<DelegateComponent> *prop);
	static DelegateComponent *entries_at(QQmlListProperty<DelegateComponent> *prop, qsizetype index);
	static void entries_clear(QQmlListProperty<DelegateComponent> *prop);
	static void entries_removeLast(QQmlListProperty<DelegateComponent> *prop);

	void entryVisibilityChanged(DelegateComponent *entry);

	Q_DECLARE_PRIVATE(DelegateComponentModel)
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_DELEGATECOMPONENTMODEL_H
