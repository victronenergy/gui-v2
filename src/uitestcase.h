/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTCASE_H
#define VICTRON_GUIV2_UITESTCASE_H

#include <qqmlintegration.h>
#include <QQuickItem>
#include <QQuickWindow>
#include <QJSValue>

#include "uiteststep.h"

namespace Victron {
namespace VenusOS {

class UiTestStep;
class UiTestStepGroup;

/*
	Defines a UI test case.

	Each test case has one or more test functions. A test function is one of these specially named
	functions:
	- any function with a "test_" prefix
	- init(), to be called before each test_* function
	- cleanup(), to be called after each test_* function
	- initTestCase(), to be called before first, before any other test functions
	- cleanupTestCase(), to be called before last, after all other test functions

	Within any test function, you can:
	- add test steps (e.g. to trigger a mouse click or capture/compare an image) with addStep()
	- then run the steps asynchronously with runSteps().
*/
class UiTestCase : public QQuickItem
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
	Q_PROPERTY(QQuickWindow* window READ window WRITE setWindow NOTIFY windowChanged FINAL REQUIRED)

public:
	explicit UiTestCase(QQuickItem *parent = nullptr);

	QString name() const;
	void setName(const QString &name);

	QQuickWindow* window() const;
	void setWindow(QQuickWindow* window);

	// Starts running the test functions in this test case. If initTestCase() has been defined, it
	// will be called first.
	Q_INVOKABLE void start();

	// Adds a test step to the queue.
	Q_INVOKABLE void addStep(UiTestStep::Type type, const QVariantMap &params);

	// Runs all queued test steps asynchronously. By default, goToNextTestFunction() is called when
	// the steps have finished, but if a callback is provided, it is called instead; that callback
	// must call runSteps() or goToNextTestFunction() to continue the test sequence.
	// NOTE: the steps are run asynchronously, so any code in the test function after the run() call
	// will be executed immediately, before any steps are run!
	Q_INVOKABLE void runSteps(
			const QJSValue &callback = QJSValue(),
			const QList<QJSValue> &callbackArgs = QList<QJSValue>());

	// Runs the next test function defined in this test case. This may be a function with a "test_"
	// prefix, or an init() or cleanUp() function.
	Q_INVOKABLE void goToNextTestFunction();

	// Looks in the object tree of the given sourceObject, and returns the first child object (or
	// the given object, if it matches) with the specified property values, and the given typeName
	// (if specified).
	Q_INVOKABLE QObject *findObject(
			QObject *sourceObject,
			const QVariantMap &params,
			const QString &typeName = QString()) const;

	// Same as findObject() but returns a QQuickItem instead of a QObject.
	Q_INVOKABLE QQuickItem *findItem(
			QQuickItem *sourceItem,
			const QVariantMap &params,
			const QString &typeName = QString()) const;

	// Looks in the object tree of the given sourceItem, and returns the first child item (or
	// the given item, if it matches) that appears to be clickable - for example, if it inherits
	// from the QML MouseArea or Button types.
	Q_INVOKABLE QQuickItem *findClickableChild(QQuickItem *sourceItem) const;

	// Same as findClickableChild(), but searches up the parent hierarchy instead.
	Q_INVOKABLE QQuickItem *findClickableParent(QQuickItem *sourceItem) const;

	// Triggers a mouse press and mouse release event on the centre of the given item.
	Q_INVOKABLE bool mouseClick(QQuickItem *item);

	// TODO add keyPress(QQuickItem *item);

Q_SIGNALS:
	void nameChanged();
	void windowChanged();
	void finished();

private:
	struct TestFunction {
		TestFunction() {}
		TestFunction(int i) : index(i) {}
		TestFunction(int i, const QVariant &arg, const QString &tag)
			: index(i), dataArg(arg), dataTag(tag) {}
		int index = -1;
		QVariant dataArg;
		QString dataTag;
	};

	struct Totals {
		int passed = 0;
		int failed = 0;
		QElapsedTimer elapsed;
	} m_totals;

	QObject *doFindObject(QObject *fromItem, const QVariantMap &params, const QString &typeName, int loggingIndent) const;
	QQuickItem *doFindClickableChild(QQuickItem *fromItem, int loggingIndent) const;
	void stepGroupFinished(int passedCount, int failedCount);

	QList<TestFunction> m_functions;
	QString m_name;
	QJSValue m_stepsCallback;
	QList<QJSValue> m_stepsCallbackArgs;
	QQuickWindow *m_window = nullptr;
	UiTestStepGroup *m_stepGroup = nullptr;
	int m_currentFunctionIndex = 0;
};

}
}

#endif // VICTRON_GUIV2_UITESTCASE_H
