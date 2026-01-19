/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QMetaObject>
#include <QMetaMethod>
#include <QMouseEvent>
#include <QCoreApplication>
#include <QTimer>

#include <QQmlComponent>
#include <QQmlEngine>

#include "uitestcase.h"
#include "uitest.h"
#include "logging.h"

using namespace Victron::VenusOS;

namespace {

bool itemMatchesProperties(QObject *item, const QVariantMap &params)
{
	if (!item) {
		return false;
	}
	for (auto it = params.constBegin(); it != params.constEnd(); ++it) {
		const QMetaObject *mo = item->metaObject();
		const int propertyIndex = mo->indexOfProperty(it.key().toUtf8());
		if (propertyIndex < 0) {
			return false;
		}
		QMetaProperty property = mo->property(propertyIndex);
		if (!property.isValid()) {
			return false;
		}
		if (property.read(item) != it.value()) {
			return false;
		}
	}
	return true;
}

bool itemMatchesType(QObject *item, const QString &typeName)
{
	if (!item || typeName.isEmpty()) {
		return true;
	}
	// Match statically-registered types, e.g. QQuickRepeater, QQuickRow
	const QMetaType metaType = item->metaObject()->metaType();
	if (metaType.name() == typeName) {
		return true;
	}
	// Search the parent hierarchy for a matching class name.
	const QMetaObject *metaObject = item->metaObject();
	while (metaObject) {
		// Match statically-registered types, e.g. QQuickRepeater, QQuickRow
		if (metaObject->metaType().name() == typeName) {
			return true;
		}
		// Match QML-declared types.
		const QString className = QString::fromUtf8(metaObject->className());
		if (className == typeName
				|| className.startsWith(QStringLiteral("%1_QMLTYPE_").arg(typeName))) {
			return true;
		}
		metaObject = metaObject->superClass();
	}
	return false;
}

bool itemMatchesPropertiesAndType(QObject *item, const QVariantMap &params, const QString &typeName)
{
	return item && itemMatchesType(item, typeName) && itemMatchesProperties(item, params);
}

bool isClickableItem(QQuickItem *item)
{
	if (!item) {
		return false;
	}
	if (itemMatchesType(item, QStringLiteral("QQuickMouseArea"))
			|| itemMatchesType(item, QStringLiteral("QQuickAbstractButton"))
			|| itemMatchesType(item, QStringLiteral("PressArea"))) {
		return true;
	}

	// Some
	// As a fallback, looked for a clicked() signal
	// TODO should this look for meta object clicked() signal as a fallback?
	return false;
}
}

UiTestCase::UiTestCase(QQuickItem *parent)
	: QQuickItem(parent)
{
}

QString UiTestCase::name() const
{
	return m_name;
}

void UiTestCase::setName(const QString &name)
{
	if (name != m_name) {
		m_name = name;
		emit nameChanged();
	}
}

QQuickWindow* UiTestCase::window() const
{
	return m_window;
}

void UiTestCase::setWindow(QQuickWindow* window)
{
	if (m_window != window) {
		m_window = window;
		emit windowChanged();
	}
}

void UiTestCase::start()
{
	qCInfo(venusGuiTest) << qPrintable(QStringLiteral("********* Start testing of %1 *********").arg(name()));

	m_functions.clear();
	m_totals.elapsed.start();

	const QMetaObject *mo = metaObject();
	const int initTestCaseIndex = mo->indexOfMethod("initTestCase()");
	const int cleanupTestCaseIndex = mo->indexOfMethod("cleanupTestCase()");
	const int initIndex = mo->indexOfMethod("init()");
	const int cleanupIndex = mo->indexOfMethod("cleanup()");

	// Add initTestCase() before any test functions.
	if (initTestCaseIndex >= 0) {
		m_functions.append(TestFunction(initTestCaseIndex));
	}

	// Find each test_* function (that is not a test data function with a *_data suffix) and add it
	// to the function list.
	for (int functionIndex = m_currentFunctionIndex; functionIndex < mo->methodCount(); ++functionIndex) {
		if (functionIndex == initTestCaseIndex
				|| functionIndex == cleanupTestCaseIndex
				|| functionIndex == initIndex
				|| functionIndex == cleanupIndex) {
			continue;
		}
		const QMetaMethod method = mo->method(functionIndex);
		const QString methodName = QString::fromUtf8(method.name());
		if (!methodName.startsWith(QStringLiteral("test_"))
				|| methodName.endsWith(QStringLiteral("_data"))) {
			continue;
		}

		const QMetaMethod dataMethod = mo->method(mo->indexOfMethod(QString("%1_data()").arg(methodName).toUtf8()));
		if (dataMethod.isValid()) {
			// This test function has an associated _data() function. Call it to get the function
			// args; for each argument, add the test function and arg to the function list. If
			// init() and/or cleanup() functions are defined, add them before and after the function.
			QVariant dataValue;
			if (!dataMethod.invoke(this, Qt::DirectConnection, qReturnArg(dataValue))) {
				qCFatal(venusGuiTest) << "Unable to invoke data function:" << dataMethod.name();
			}
			const QVariantList dataArgs = dataValue.toList();
			for (int argIndex = 0; argIndex < dataArgs.count(); ++argIndex) {
				const QVariant dataArg = dataArgs.at(argIndex);
				const QString dataTag = dataArg.toMap().value(QStringLiteral("tag")).toString();
				if (initIndex >= 0) {
					m_functions.append(TestFunction(initIndex));
				}
				m_functions.append(TestFunction(functionIndex, dataArg, dataTag));
				if (cleanupIndex >= 0) {
					m_functions.append(TestFunction(cleanupIndex));
				}
			}
		} else {
			// There is no associated data function. Just add the test function, wrapped by init()
			// and cleanup() (if defined).
			if (initIndex >= 0) {
				m_functions.append(TestFunction(initIndex));
			}
			m_functions.append(TestFunction(functionIndex));
			if (cleanupIndex >= 0) {
				m_functions.append(TestFunction(cleanupIndex));
			}
		}
	}

	// Add cleanupTestCase() to the end.
	if (cleanupTestCaseIndex >= 0) {
		m_functions.append(TestFunction(cleanupTestCaseIndex));
	}

	m_currentFunctionIndex = -1;
	goToNextTestFunction();
}

void UiTestCase::goToNextTestFunction()
{
	if (m_currentFunctionIndex > m_functions.count()) {
		qCWarning(venusGuiTest) << qPrintable(QStringLiteral("No more test functions to run, %1 has already finished!").arg(name()));
		return;
	}

	m_currentFunctionIndex++;
	if (m_currentFunctionIndex < m_functions.count()) {
		const TestFunction &testFunc = m_functions.at(m_currentFunctionIndex);
		const QMetaMethod method = metaObject()->method(testFunc.index);
		qCInfo(venusGuiTest) << method.name()
				<< qPrintable(testFunc.dataTag.isEmpty() ? QString() : QStringLiteral("(%1)").arg(testFunc.dataTag));
		if (testFunc.dataArg.isValid()) {
			if (!method.invoke(this, testFunc.dataArg)) {
				qCFatal(venusGuiTest) << QStringLiteral("Failed to invoke %1::%2() with data arg %3")
						.arg(name())
						.arg(QString::fromUtf8(method.name()))
						.arg(testFunc.dataArg.toString());
			}
		} else {
			if (!method.invoke(this)) {
				qCFatal(venusGuiTest) << QStringLiteral("Failed to invoke %1::%2()")
						.arg(name())
						.arg(QString::fromUtf8(method.name()));
			}
		}
	} else {
		qCInfo(venusGuiTest) << qPrintable(QStringLiteral("Totals: %1 steps passed, %2 steps failed, %3 ms")
				.arg(m_totals.passed)
				.arg(m_totals.failed)
				.arg(m_totals.elapsed.elapsed()));
		qCInfo(venusGuiTest) << qPrintable(QStringLiteral("********* Finished testing of %1 *********").arg(name()));
		m_totals.elapsed.invalidate();
		emit finished();
	}
}

void UiTestCase::addStep(UiTestStep::Type type, const QVariantMap &params)
{
	if (!m_stepGroup) {
		m_stepGroup = new UiTestStepGroup(this);
		connect(m_stepGroup, &UiTestStepGroup::finished, this, &UiTestCase::stepGroupFinished);
	}

	UiTestStep *step = nullptr;
	switch (type) {
	case UiTestStep::Abort:
		step = AbortStep::create(this, params);
		break;
	case UiTestStep::CaptureAndCompare:
		step = CaptureAndCompareStep::create(this, m_window, name(), params);
		break;
	case UiTestStep::Invoke:
		step = InvokeStep::create(this, params);
		break;
	case UiTestStep::Wait:
		step = WaitStep::create(this, params);
		break;
	case UiTestStep::WaitUntil:
		step = WaitUntilStep::create(this, params);
		break;
	default:
		qCFatal(venusGuiTest) << "Unsupported step type:" << QDebug::toString(type);
	}
	if (step) {
		m_stepGroup->addStep(step);
	} else {
		qFatal(venusGuiTest) << "Unsupported step configuration for type:" << QDebug::toString(type);
	}
}

void UiTestCase::runSteps(const QJSValue &callback, const QList<QJSValue> &callbackArgs)
{
	if (!m_stepGroup) {
		m_stepGroup = new UiTestStepGroup(this);
		connect(m_stepGroup, &UiTestStepGroup::finished, this, &UiTestCase::stepGroupFinished);
	}

	m_stepsCallback = callback;
	m_stepsCallbackArgs = callbackArgs;
	m_stepGroup->run();
}

void UiTestCase::stepGroupFinished(int passedCount, int failedCount)
{
	Q_ASSERT(m_stepGroup == sender());

	m_totals.passed += passedCount;
	m_totals.failed += failedCount;
	m_stepGroup->deleteLater();
	m_stepGroup = nullptr;

	if (failedCount == 0 && m_stepsCallback.isCallable()) {
		const QJSValue result = m_stepsCallback.call(m_stepsCallbackArgs);
		if (!result.isError()) {
			return;
		}
		qCFatal(venusGuiTest) << qPrintable(QStringLiteral("\trunSteps() callback triggered uncaught exception at line %1: %2")
				.arg(result.property("lineNumber").toInt())
				.arg(result.toString()));
	}

	QTimer::singleShot(0, this, &UiTestCase::goToNextTestFunction);
}

bool UiTestCase::mouseClick(QQuickItem *item)
{
	if (!item) {
		qCWarning(venusGuiTest) << "mouseClick(): invalid item!";
		return false;
	}

	QPoint localPos(item->width() / 2, item->height() / 2);
	QMouseEvent *pressEvent = new QMouseEvent(
				QEvent::MouseButtonPress,
				localPos,
				item->mapToGlobal(localPos),
				Qt::LeftButton,
				Qt::LeftButton,
				Qt::NoModifier);
	QMouseEvent *releaseEvent = new QMouseEvent(
				QEvent::MouseButtonRelease,
				localPos,
				item->mapToGlobal(localPos),
				Qt::LeftButton,
				Qt::LeftButton,
				Qt::NoModifier);

	QCoreApplication::postEvent(item, pressEvent);
	QCoreApplication::postEvent(item, releaseEvent);
	return true;
}

QObject *UiTestCase::findObject(QObject *sourceObject, const QVariantMap &params, const QString &typeName) const
{
	QObject *result = doFindObject(sourceObject, params, typeName, -1);
	if (!result) {
		qCDebug(venusGuiTest) << QStringLiteral("findObject() failed for sourceObject=%1 params=%2 typeName='%3'")
				 .arg(QDebug::toString(sourceObject)).arg(QDebug::toString(params)).arg(typeName);
		qCDebug(venusGuiTest) << "See logging:" << doFindObject(sourceObject, params, typeName, 4);
	}
	return result;
}

QQuickItem *UiTestCase::findItem(QQuickItem *sourceItem, const QVariantMap &params, const QString &typeName) const
{
	return qobject_cast<QQuickItem *>(findObject(sourceItem, params, typeName));
}

QQuickItem *UiTestCase::findClickableChild(QQuickItem *sourceItem) const
{
	// Return this item if it is clickable, otherwise find a clickable child.
	QQuickItem *clickableItem = doFindClickableChild(sourceItem, -1);
	if (!clickableItem) {
		qCDebug(venusGuiTest) << QStringLiteral("findClickable() cannot find clickable item, see logging:");
		qCDebug(venusGuiTest) << doFindClickableChild(sourceItem, 4);
		return nullptr;
	}

	return clickableItem;
}

QQuickItem *UiTestCase::findClickableParent(QQuickItem *sourceItem) const
{
	if (!sourceItem) {
		return nullptr;
	}
	if (isClickableItem(sourceItem)) {
		return sourceItem;
	}

	QQuickItem *parent = sourceItem->parentItem();
	while (parent && !isClickableItem(parent)) {
		parent = parent->parentItem();
	}

	if (isClickableItem(parent)) {
		return parent;
	}
	return nullptr;
}

/*
	Recursively searches sourceObject and its children for an item that matches the given
	parameters and type name.
*/
QObject *UiTestCase::doFindObject(QObject *sourceObject, const QVariantMap &params, const QString &typeName, int loggingIndent) const
{
	if (!sourceObject) {
		return nullptr;
	}

	if (itemMatchesPropertiesAndType(sourceObject, params, typeName)) {
		return sourceObject;
	}

	const QList<QObject *> children = sourceObject->findChildren<QObject *>();
	QString indentation;
	if (loggingIndent >= 0) {
		indentation.fill(' ', loggingIndent);
	}

	if (loggingIndent >= 0) {
		qCDebug(venusGuiTest) << qPrintable(QStringLiteral("%1 sourceObject=%2 %3")
			  .arg(indentation)
			  .arg(QDebug::toString(sourceObject))
			  .arg(children.count() > 0 ? QStringLiteral("(%3 children)").arg(children.count()) : QString()));
	}

	for (QObject *child : children) {
		if (loggingIndent >= 0) {
			qCDebug(venusGuiTest) << qPrintable(indentation) << "Child:" << child;
		}
		if (itemMatchesPropertiesAndType(child, params, typeName)) {
			return child;
		}
		const QMetaType metaType = child->metaObject()->metaType();
		QQuickItem *childItem = qobject_cast<QQuickItem*>(child);
		if (childItem && metaType.name() == QStringLiteral("QQuickRepeater") && childItem->parentItem()) {
			// Repeater items are not found by QObject::findChildren(). Instead, we need to look
			// through the QQuickItem::children() of the Repeater's parentItem, as the Repeater
			// items are parented to the Repeater's parent.
			if (loggingIndent >= 0) {
				qCDebug(venusGuiTest) << qPrintable(QStringLiteral("%1 Search children of Repeater: %2...")
									  .arg(indentation).arg(QDebug::toString(childItem->parentItem())));
			}
			const QList<QQuickItem *> repeaterChildren = childItem->parentItem()->childItems();
			for (QQuickItem *repeaterChild : repeaterChildren) {
				if (QObject *matchedChild = doFindObject(repeaterChild, params, typeName, loggingIndent >= 0 ? loggingIndent + 4 : -1)) {
					return matchedChild;
				}
			}
		} else if (QObject *matchedChild = doFindObject(child, params, typeName, loggingIndent >= 0 ? loggingIndent + 4 : -1)) {
			return matchedChild;
		}
	}

	return nullptr;
}

/*
	Recursively searches sourceItem and its child items for an item that matches the given
	parameters and type name.
*/
QQuickItem *UiTestCase::doFindClickableChild(QQuickItem *sourceItem, int loggingIndent) const
{
	if (!sourceItem) {
		return nullptr;
	}

	if (isClickableItem(sourceItem)) {
		return sourceItem;
	}

	const QList<QQuickItem *> childItems = sourceItem->findChildren<QQuickItem *>();
	QString indentation;
	if (loggingIndent >= 0) {
		indentation.fill(' ', loggingIndent);
	}

	if (loggingIndent >= 0) {
		qCDebug(venusGuiTest) << qPrintable(QStringLiteral("%1 sourceItem=%2 %3")
			  .arg(indentation)
			  .arg(QDebug::toString(sourceItem))
			  .arg(childItems.count() > 0 ? QStringLiteral("(%3 children)").arg(childItems.count()) : QString()));
	}

	for (QQuickItem *childItem : childItems) {
		if (loggingIndent >= 0) {
			qCDebug(venusGuiTest) << qPrintable(indentation) << "Child:" << childItem;
		}
		if (isClickableItem(childItem)) {
			return childItem;
		}
		const QMetaType metaType = childItem->metaObject()->metaType();
		if (metaType.name() == QStringLiteral("QQuickRepeater") && childItem->parentItem()) {
			// Repeater items are not found by QObject::findChildren(). Instead, we need to look
			// through the QQuickItem::children() of the Repeater's parentItem, as the Repeater
			// items are parented to the Repeater's parent.
			if (loggingIndent >= 0) {
				qCDebug(venusGuiTest) << qPrintable(indentation) << "Search children of Repeater:" << childItem->parentItem();
			}
			for (QQuickItem *repeaterChild : childItem->parentItem()->childItems()) {
				if (loggingIndent >= 0) {
					qCDebug(venusGuiTest) << qPrintable(indentation) << "Repeater child:" << repeaterChild;
				}
				if (QQuickItem *matchedChild = doFindClickableChild(repeaterChild,loggingIndent >= 0 ? loggingIndent + 4 : -1)) {
					return matchedChild;
				}
			}
		} else if (QQuickItem *matchedChild = doFindClickableChild(childItem, loggingIndent >= 0 ? loggingIndent + 4 : -1)) {
			return matchedChild;
		}
	}

	return nullptr;
}
