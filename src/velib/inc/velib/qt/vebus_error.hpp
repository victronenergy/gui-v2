#ifndef _VELIB_QT_VEBUS_ERROR_HPP_
#define _VELIB_QT_VEBUS_ERROR_HPP_

#include <QObject>
#include <QString>

class VebusError : public QObject
{
	Q_OBJECT

public:
	Q_INVOKABLE static QString getDescription(int errorNumber);
};

#endif
