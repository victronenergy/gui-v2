#include <QGuiApplication>
#include <QtDebug>

#include "themeparser.h"

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
	Victron::VenusOS::ThemeParser parser;
	const QString themesDir = QString(VENUSOS_THEMES_DIR);
	const QString themeobjectsh = QString(VENUSOS_THEMEOBJECTS_H);
	qInfo() << "Generating" << themeobjectsh << "from" << themesDir;
	if (!parser.generateThemeCode(themesDir, themeobjectsh)) {
		qWarning() << "Error occurred while generating theme objects.";
		return 1;
	}
	return 0;
}
