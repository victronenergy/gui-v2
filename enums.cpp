#include "enums.h"

namespace Victron {
namespace VenusOS {

QObject* Enums::instance(QQmlEngine *, QJSEngine *)
{
	return new Enums;
}

Enums::Enums(QObject *parent)
	: QObject(parent)
{
}

Enums::~Enums()
{
}

}
}
