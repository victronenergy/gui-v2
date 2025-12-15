/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITESTSTEP_H
#define VICTRON_GUIV2_UITESTSTEP_H

#include <QVariantMap>
#include <QJSValue>
#include <QImage>
#include <qqmlintegration.h>

class QQuickWindow;

namespace Victron {
namespace VenusOS {

/*
	A single test step, created by UiTestCase::addStep().

	Each step is only run once, and must emit finished() when finished.
*/
class UiTestStep : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("")
public:
	enum Type {
		Abort,
		CaptureAndCompare,
		Invoke,
		Wait,
		WaitUntil,
	};
	Q_ENUM(Type);

	enum Result {
		Unknown = 0,
		Passed,
		Failed,
	};
	Q_ENUM(Result);

	UiTestStep(QObject *parent, Type type, const QString &message);

	Type type() const { return m_type; }
	QString message() const { return m_message; }
	Result result() const { return m_result; }
	virtual QString summary() const;
	virtual void start() = 0;

Q_SIGNALS:
	void finished(bool passed, const QString &errorText);

protected:
	// Sets the result and emits finished().
	void finish(bool passed, const QString &errorText = QString());

	// Returns a setting specific to this step type.
	QVariant settingValue(const QString &key, const QVariant &defaultValue = QVariant()) const;

	// Returns a step setting.
	static QVariant settingValue(Type type, const QString &key, const QVariant &defaultValue = QVariant());

	// Returns the "message" value from the map.
	static QString messageText(const QVariantMap &params);

	const QString m_message;
	Result m_result = Unknown;
	const Type m_type;
};


/*
	Runs a series of test steps.
*/
class UiTestStepGroup : public QObject
{
	Q_OBJECT
public:
	UiTestStepGroup(QObject *parent);
	void addStep(UiTestStep *step);
	void run();

signals:
	void finished(int m_passedCount, int failedCount);

private:
	void runNextStep();
	void stepFinished(bool passed, const QString &errorText);
	void allStepsFinished();

	QList<UiTestStep *> m_steps;
	int m_initialCount = 0;
	int m_active = false;
	int m_passedCount = 0;
	int m_failedCount = 0;
};


/*
	Aborts the current sequence of steps that have been triggered with UiTestCase::runSteps().

	Parameters:
	- passed (bool): if true, the steps are considered to have succeeded, otherwise a test failure
	  is reported.
	- message (string): optional message to be shown when running the step.
*/
class AbortStep : public UiTestStep
{
	Q_OBJECT
public:
	AbortStep(QObject *parent, bool passed, const QString &message);

	void start() override;
	static AbortStep *create(QObject *parent, const QVariantMap &params);

private:
	bool m_passed = false;
};

/*
	Performs a screen capture of the current UI, and compares it with the specified saved image.

	If the specified image name is not found, the capture is saved as the reference image instead,
	so that a comparison can be performed the next time the tests are run.

	If a comparison is done and it fails, the capture is saved.

	Parameters:
	- imageName (string): an image name (without a file extension) to be used for saving/comparing.
	- message (string): optional message to be shown when running the step.
*/
class CaptureAndCompareStep : public UiTestStep
{
	Q_OBJECT
public:
	CaptureAndCompareStep(QObject *parent, QQuickWindow *window, const QString &filePrefix, const QString &message);

	QString summary() const override;
	void start() override;
	static CaptureAndCompareStep *create(QObject *parent, QQuickWindow *window, const QString &imagePrefix, const QVariantMap &params);

protected:
	void timerEvent(QTimerEvent *event) override;

private:
	void capture();
	void finalize();
	QString absoluteImagePath(const QString &fileName) const;
	int maxStabilizationAttempts() const;

	QQuickWindow *m_window;
	QImage m_lastCapture;
	QString m_filePrefix;
	int m_stabilizationTimerId = 0;
	int m_stabilizationAttempts = 0;
	const qreal m_failureThreshold;
};

/*
	Invokes the specified callable.

	Parameters:
	- callable (JavaScript function): the function to be called. If it does not return a value (i.e.
	  returns undefined) then the test succeeds. Otherwise, the return value is coerced to a bool,
	  and if the result is true, then the test succeeds, otherwise a test failure is reported.
	- message (string): optional message to be shown when running the step.
*/
class InvokeStep : public UiTestStep
{
	Q_OBJECT
public:
	InvokeStep(QObject *parent, const QJSValue &callable, const QString &message);

	void start() override;
	static InvokeStep *create(QObject *parent, const QVariantMap &params);

private:
	QJSValue m_callable;
};

/*
	Waits for a specified duration before the next test step.

	Parameters:
	- timeout (int): the time (in milliseconds) to wait.
	- message (string): optional message to be shown when running the step.
*/
class WaitStep : public UiTestStep
{
	Q_OBJECT
public:
	WaitStep(QObject *parent, int timeout, const QString &message);

	void start() override;
	QString summary() const override;
	static WaitStep *create(QObject *parent, const QVariantMap &params);

protected:
	void timerEvent(QTimerEvent *event) override;

private:
	int m_timeout = 0;
	int m_timerId = 0;
};

/*
	Waits until the specified callable returns true.

	Parameters:
	- callable (JavaScript function): the function to be called. The return value is coerced to a
	  bool, and if the result is true, then the test succeeds, otherwise a test failure is reported.
	- timeout (int): the maximum time (in milliseconds) to wait for the callable to return true.
	  If the timeout is triggered, the step ends and a test failure is reported.
	- message (string): optional message to be shown when running the step.
*/
class WaitUntilStep : public UiTestStep
{
	Q_OBJECT
public:
	WaitUntilStep(QObject *parent, const QJSValue &callable, int timeout, const QString &message);

	void start() override;
	static WaitUntilStep *create(QObject *parent, const QVariantMap &params);

protected:
	void timerEvent(QTimerEvent *event) override;

private:
	void tryCallable();

	QJSValue m_callable;
	int m_timeout = 0;
	int m_timerId = 0;
};

}
}

#endif // VICTRON_GUIV2_UITESTSTEP_H
