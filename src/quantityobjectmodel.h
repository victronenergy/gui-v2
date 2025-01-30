/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_QUANTITYOBJECTMODEL_H
#define VICTRON_GUIV2_QUANTITYOBJECTMODEL_H

#include <QAbstractListModel>
#include <qqmlintegration.h>

#include "quantityobject.h"

namespace Victron {
namespace VenusOS {

/*
	Provides a model of QuantityObject values, based on the specified objects list.

	If the filter is HasValue, the model will filter out any QuantityObject with hasValue=false.

	Example usage:

	QtObject {
		id: dataObject
		property real voltage: 0.14
		property real power: NaN
	}

	ListView {
		model: QuantityObjectModel {
			filterType: QuantityObjectModel.HasValue

			// Since voltage=0.14, the value is valid, and the object will appear in the view.
			QuantityObject { object: dataObject; key: "voltage"; unit: VenusOS.Units_Volt_DC }

			// Since power=NaN, the QuantityObject 'hasValue' will be false, and the object will not
			// appear in the view.
			QuantityObject { object: dataObject; key: "power"; unit: VenusOS.Units_Watt }
		}

		delegate: QuantityLabel {
			required property QuantityObject quantityObject
			value: quantityObject.numberValue
		}
	}
*/
class QuantityObjectModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)
	Q_PROPERTY(FilterType filterType READ filterType WRITE setFilterType NOTIFY filterTypeChanged)
	Q_PROPERTY(QQmlListProperty<QuantityObject> objects READ objects NOTIFY objectsChanged FINAL)
	Q_CLASSINFO("DefaultProperty", "objects")

public:
	enum Role {
		QuantityObjectRole = Qt::UserRole
	};
	Q_ENUM(Role)

	enum FilterType {
		NoFilter,
		HasValue,
	};
	Q_ENUM(FilterType)

	explicit QuantityObjectModel(QObject *parent = nullptr);

	int count() const;
	QQmlListProperty<QuantityObject> objects();

	FilterType filterType() const;
	void setFilterType(FilterType filterType);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

Q_SIGNALS:
	void countChanged();
	void objectsChanged();
	void filterTypeChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	void objectHasValueChanged();
	void checkObjectHasValue(QuantityObject *object);
	int validObjectsInsertionIndex(QuantityObject *object) const;
	void clearValidObjects();

	static void objects_append(QQmlListProperty<QuantityObject> *prop, QuantityObject *object);
	static qsizetype objects_count(QQmlListProperty<QuantityObject> *prop);
	static QuantityObject *objects_at(QQmlListProperty<QuantityObject> *prop, qsizetype index);
	static void objects_clear(QQmlListProperty<QuantityObject> *prop);
	static void objects_removeLast(QQmlListProperty<QuantityObject> *prop);

	QVector<QPointer<QuantityObject> > m_allObjects;
	QVector<QPointer<QuantityObject> > m_validObjects;
	FilterType m_filterType = NoFilter;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_QUANTITYOBJECTMODEL_H
