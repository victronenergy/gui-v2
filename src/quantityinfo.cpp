#include "quantityinfo.h"
#include "units.h"

namespace Victron {
namespace Units {

QuantityInfo::QuantityInfo(QObject *parent)
	: QObject(parent)
{
	connect(this, &QuantityInfo::inputChanged, this, &QuantityInfo::update);
}

QuantityInfo::~QuantityInfo()
{
}

void QuantityInfo::update() {
	// Pass the previous value to allow hysteresis
	quantity = qobject_cast<Units>(Units::instance(nullptr, nullptr)).getDisplayTextWithHysteresis(unitType, value, quantity.scale, precision, unitMatchValue);
	emit updated();
}

}
}
