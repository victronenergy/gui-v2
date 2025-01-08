/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef ALLOWEDITEMMODEL_H
#define ALLOWEDITEMMODEL_H

#include <private/qqmlobjectmodel_p.h>
#include <qqmlintegration.h>

class AllowedItemModelPrivate;

namespace Victron {
namespace VenusOS {

class AllowedItemModel : public QQmlInstanceModel
{
	Q_OBJECT
	Q_DECLARE_PRIVATE(AllowedItemModel)

	Q_PROPERTY(QQmlListProperty<QObject> sourceModel READ sourceModel NOTIFY sourceModelChanged DESIGNABLE false)
	Q_CLASSINFO("DefaultProperty", "sourceModel")
	QML_ELEMENT

public:
	explicit AllowedItemModel(QObject *parent = nullptr);

	Q_INVOKABLE QObject* get(int index);

	int count() const override;
	bool isValid() const override;
	QObject *object(int index, QQmlIncubator::IncubationMode incubationMode = QQmlIncubator::AsynchronousIfNested) override;
	ReleaseFlags release(QObject *object, ReusableFlag reusable = NotReusable) override;
	QVariant variantValue(int index, const QString &role) override;
	void setWatchedRoles(const QList<QByteArray> &) override {}
	QQmlIncubator::Status incubationStatus(int index) override;

	int indexOf(QObject *object, QObject *context) const override;

	QQmlListProperty<QObject> sourceModel();

Q_SIGNALS:
	void sourceModelChanged();

private:
	Q_DISABLE_COPY(AllowedItemModel)

	Q_INVOKABLE void allowedChanged();
};

} /* VenusOS */
} /* Victron */

#endif // ALLOWEDITEMMODEL_H
