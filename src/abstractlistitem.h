/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_ABSTRACTLISTITEM_H
#define VICTRON_GUIV2_ABSTRACTLISTITEM_H

#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <QtQuickTemplates2/private/qquickcontrol_p.h>

namespace Victron {
namespace VenusOS {
class DelegateComponent;
}
}

/*
	A base Control type for items in a list.
*/
class AbstractListItem : public QQuickControl
{
	Q_OBJECT
	QML_ELEMENT
	Q_MOC_INCLUDE("delegatecomponentmodel.h")
	Q_PROPERTY(bool preferredVisible READ preferredVisible WRITE setPreferredVisible NOTIFY preferredVisibleChanged FINAL)
	Q_PROPERTY(bool effectiveVisible READ effectiveVisible WRITE setEffectiveVisible NOTIFY effectiveVisibleChanged FINAL)
	Q_PROPERTY(Victron::VenusOS::DelegateComponent *delegateComponent READ delegateComponent WRITE setDelegateComponent NOTIFY delegateComponentChanged FINAL)

public:
	AbstractListItem(QQuickItem *parent = nullptr);

	// Set preferredVisible=false if it should be hidden (e.g. if it would display invalid data).
	bool preferredVisible() const;
	void setPreferredVisible(bool preferredVisible);

	// True if the item should be made visible. This is used by VisibleItemModel to filter out
	// non-valid items. (It must filter by 'effectiveVisible' instead of `visible', as the latter is
	// affected by the parent's visible value, causing the item to be unnecessarily filtered in and
	// out of a VisibleItemModel whenever a parent page is shown/hidden.)
	bool effectiveVisible() const;
	void setEffectiveVisible(bool effectiveVisible);

	// Set by DelegateComponentModel before completeCreate() so ListSetting can copy
	// showAccessLevel from the model entry. Null when the item is not created by that model.
	Victron::VenusOS::DelegateComponent *delegateComponent() const;
	void setDelegateComponent(Victron::VenusOS::DelegateComponent *delegateComponent);

Q_SIGNALS:
	void preferredVisibleChanged();
	void effectiveVisibleChanged();
	void delegateComponentChanged();

private:
	bool m_preferredVisible = true;
	bool m_effectiveVisible = true;
	// QPointer: DelegateComponentModel only deleteLater()s delegates, while the
	// inline DelegateComponent children are destroyed immediately with the model.
	QPointer<Victron::VenusOS::DelegateComponent> m_delegateComponent;
};

#endif // VICTRON_GUIV2_ABSTRACTLISTITEM_H
