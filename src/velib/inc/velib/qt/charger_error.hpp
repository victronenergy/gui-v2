#ifndef _VELIB_QT_CHARGER_ERROR_HPP_
#define _VELIB_QT_CHARGER_ERROR_HPP_

#include <QObject>

typedef struct
{
	int errorId;
	const char *description;
} VeChargerError;

class ChargerError : public QObject
{
	Q_OBJECT
public:

	Q_INVOKABLE QString description(int error) { return ChargerError::getDescription(error); }

	ChargerError();

	static QString getDescription(int error);
	static bool isWarning(int error);

private:
	static const VeChargerError errors[];
};

#endif
