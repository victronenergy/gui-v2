/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QAbstractItemModelTester>
#include <QPersistentModelIndex>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include "testutils.h"

class CombinedListModelTestHelper : public QObject
{
	Q_OBJECT

public:
	// Fails the current test if the model reports a change that does not match its rows.
	Q_INVOKABLE void checkModel(QAbstractItemModel *model)
	{
		new QAbstractItemModelTester(model, QAbstractItemModelTester::FailureReportingMode::QtTest, model);
	}

	// Returns a model that sorts and filters the rows of another model. QML owns it.
	Q_INVOKABLE QSortFilterProxyModel *createSortFilterModel()
	{
		QSortFilterProxyModel *model = new QSortFilterProxyModel;
		// Sort and filter only when asked to, so that a test decides when the layout changes.
		model->setDynamicSortFilter(false);
		return model;
	}

	// Returns the number of the role with the given name, or -1 if the model has no such role.
	Q_INVOKABLE int roleNumber(QAbstractItemModel *model, const QString &roleName) const
	{
		return model->roleNames().key(roleName.toUtf8(), -1);
	}

	// Keeps a persistent index to each row of the model.
	Q_INVOKABLE void keepIndexes(QAbstractItemModel *model)
	{
		m_keptIndexes.clear();
		for (int row = 0; row < model->rowCount(); ++row) {
			m_keptIndexes.append(QPersistentModelIndex(model->index(row, 0)));
		}
	}

	// Returns the current row of each kept index, or -1 if the index is no longer valid.
	Q_INVOKABLE QVariantList keptRows() const
	{
		QVariantList rows;
		for (const QPersistentModelIndex &index : m_keptIndexes) {
			rows.append(index.isValid() ? index.row() : -1);
		}
		return rows;
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		engine->rootContext()->setContextProperty(QStringLiteral("CombinedListModelTestHelper"), this);
	}

private:
	QList<QPersistentModelIndex> m_keptIndexes;
};

int main(int argc, char **argv)
{
	CombinedListModelTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_combinedlistmodel",
			resolveTestSourceDir("combinedlistmodel", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_combinedlistmodel.moc"
