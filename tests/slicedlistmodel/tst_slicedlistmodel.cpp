/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QAbstractItemModelTester>
#include <QQmlContext>
#include <QQmlEngine>

#include "testutils.h"

class SlicedListModelTestHelper : public QObject
{
	Q_OBJECT

public:
	// Fails the current test if the model reports a change that does not match its rows.
	Q_INVOKABLE void checkModel(QAbstractItemModel *model)
	{
		new QAbstractItemModelTester(model, QAbstractItemModelTester::FailureReportingMode::QtTest, model);
	}

	// Returns the number of the role with the given name, or -1 if the model has no such role.
	Q_INVOKABLE int roleNumber(QAbstractItemModel *model, const QString &roleName) const
	{
		return model->roleNames().key(roleName.toUtf8(), -1);
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		engine->rootContext()->setContextProperty(QStringLiteral("SlicedListModelTestHelper"), this);
	}
};

int main(int argc, char **argv)
{
	SlicedListModelTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_slicedlistmodel",
			resolveTestSourceDir("slicedlistmodel", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_slicedlistmodel.moc"
