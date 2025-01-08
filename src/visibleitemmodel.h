/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_VISIBLEITEMMODEL_H
#define VICTRON_GUIV2_VISIBLEITEMMODEL_H

#include <private/qqmlobjectmodel_p.h>
#include <qqmlintegration.h>

class VisibleItemModelPrivate;

namespace Victron {
namespace VenusOS {

/*
	Provides an instance model that filters out non-visible items from the specified source model.

	If any item in the source model has effectiveVisible=false, then it is filtered out of the
	instance model, and thus will not be loaded in any view that uses the model.

	The sourceModel is the default property, so items can be declared directly as children,
	similarly to how ObjectModel is used.

	Below is an example. Since ListItem's 'effectiveVisible' value is conditional on its
	`preferredVisible` value, the preferredVisible can be set to false to allow VisibleItemModel to
	filter the item out of the view:

	ListView {
		// Make a VisibleItemModel with two source items
		model: VisibleItemModel {
			ListItem { preferredVisible: false } // this item will not be loaded by the view
			ListItem {} // this item will be loaded by the view
		}
	}

	(Note: the model cannot filter on the 'visible' property, as that value is affected by whether
	parent items are visible, and thus would cause constant model updates when pages are hidden or
	re-shown, so a separate property like 'effectiveVisible' must be used instead.)
*/
class VisibleItemModel : public QQmlInstanceModel
{
	Q_OBJECT
	Q_DECLARE_PRIVATE(VisibleItemModel)

	Q_PROPERTY(QQmlListProperty<QQuickItem> sourceModel READ sourceModel NOTIFY sourceModelChanged FINAL)
	Q_CLASSINFO("DefaultProperty", "sourceModel")
	QML_ELEMENT

public:
	explicit VisibleItemModel(QObject *parent = nullptr);

	Q_INVOKABLE QObject* get(int index);

	int count() const override;
	bool isValid() const override;
	QObject *object(int index, QQmlIncubator::IncubationMode incubationMode = QQmlIncubator::AsynchronousIfNested) override;
	ReleaseFlags release(QObject *object, ReusableFlag reusable = NotReusable) override;
	QVariant variantValue(int index, const QString &role) override;
	void setWatchedRoles(const QList<QByteArray> &) override {}
	QQmlIncubator::Status incubationStatus(int index) override;

	int indexOf(QObject *object, QObject *context) const override;

	QQmlListProperty<QQuickItem> sourceModel();

Q_SIGNALS:
	void sourceModelChanged();

private:
	Q_DISABLE_COPY(VisibleItemModel)

	Q_INVOKABLE void effectiveVisibleChanged();
};

} /* VenusOS */
} /* Victron */

#endif // VISIBLEITEMMODEL_H
