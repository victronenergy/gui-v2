#ifndef _VELIB_QT_BMS_ERROR_HPP_
#define _VELIB_QT_BMS_ERROR_HPP_

#include <QObject>
#include <QString>

class BmsError : public QObject
{
	Q_OBJECT

public:
	Q_INVOKABLE QString description(int error) { return BmsError::getDescription(error); }

	BmsError() {}
	static QString getDescription(int errorNumber);
};

#endif
