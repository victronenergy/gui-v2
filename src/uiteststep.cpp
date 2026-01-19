/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "uiteststep.h"
#include "uitest.h"
#include "logging.h"

#include <QTimer>
#include <QDir>
#include <QFile>
#include <QColorSpace>

#include <QQuickWindow>
#include <QQmlInfo>

using namespace Victron::VenusOS;

namespace {

bool identicalImages(const QImage &img1, const QImage &img2, qreal diffThreshold, const QString &failFileName)
{
	if (img1.width() != img2.width() || img1.format() != img2.format() || img1.colorSpace() != img2.colorSpace())  {
		qWarning() << "Image comparison failed: wrong size or format!";
		return false;
	}

	QImage diffImage(img1.width(), img1.height(), QImage::Format_ARGB32);
	quint64 totalDiff = 0;
	for (int y = 0; y < img1.height(); ++y) {
		for (int x = 0; x < img1.width(); ++x) {
			const QRgb rgb1 = img1.pixel(x, y);
			const QRgb rgb2 = img2.pixel(x, y);
			totalDiff += qAbs(qRed(rgb1) - qRed(rgb2))
					+ qAbs(qGreen(rgb1) - qGreen(rgb2))
					+ qAbs(qBlue(rgb1) - qBlue(rgb2))
					+ qAbs(qAlpha(rgb1) - qAlpha(rgb2));

			if (rgb1 == rgb2) {
				diffImage.setPixel(x, y, rgb1);
			} else {
				// Use full red to emphasize difference. Show green from new image, blue from old image.
				// TODO improve the generated image??
				diffImage.setPixel(x, y, qRgba(255, qGreen(rgb2), qBlue(rgb1), 255));
			}
		}
	}

	const float totalColourParts = img1.width() * img1.height() * 4;
	float diffPercent = (totalDiff / 255 / totalColourParts) * 100;
	if (diffPercent > diffThreshold) {
		// TODO remove this when we are viewing/generating diff images elsewhere.
		if (!failFileName.isEmpty() && !diffImage.save(failFileName)) {
			qWarning() << "Failed to save diff image to" << failFileName;
		}
		return false;
	}

	return true;
}
}

UiTestStep::UiTestStep(QObject *parent, Type type, const QString &message)
	: QObject(parent)
	, m_type(type)
	, m_message(message)
{
}

QString UiTestStep::summary() const
{
	const QString typeName = QDebug::toString(m_type);
	return typeName.mid(typeName.lastIndexOf("::") + 2); // remove namespace from type name
}

void UiTestStep::finish(bool passed, const QString &errorText)
{
	m_result = passed ? Passed : Failed;
	emit finished(passed, errorText);
}

QVariant UiTestStep::settingValue(const QString &key, const QVariant &defaultValue) const
{
	return settingValue(type(), key, defaultValue);
}

QVariant UiTestStep::settingValue(Type type, const QString &key, const QVariant &defaultValue)
{
	static const QMetaEnum typeEnum = staticMetaObject.enumerator(
			staticMetaObject.indexOfEnumerator("Type"));

	const QVariantMap stepsValues = UiTest::create()->settingValue(QStringLiteral("Steps")).toMap();
	const QVariantMap typeValues = stepsValues.value(typeEnum.valueToKey(type)).toMap();
	const QVariant result = typeValues.value(key);
	return result.isValid() ? result : defaultValue;
}

QString UiTestStep::messageText(const QVariantMap &params)
{
	return params.value(QStringLiteral("message")).toString();
}


UiTestStepGroup::UiTestStepGroup(QObject *parent)
	: QObject(parent)
{
}

void UiTestStepGroup::addStep(UiTestStep *step)
{
	if (m_active) {
		// Some code has called addStep() after a runStep(), but runSteps() is async so the newly
		// added steps will not be run. The new steps should be added in the callback to runSteps()
		// instead.
		qCFatal(venusGuiTest) << qPrintable(QStringLiteral("Detected a call to runSteps() while other steps are still running!"));
	}
	m_steps.append(step);
}

void UiTestStepGroup::run()
{
	Q_ASSERT(!m_active);

	qCDebug(venusGuiTest) << "UiTestStepGroup::run() with" << m_steps.count() << "steps";

	m_initialCount = m_steps.count();
	m_active = true;
	runNextStep();
}

void UiTestStepGroup::runNextStep()
{
	if (m_steps.isEmpty()) {
		QTimer::singleShot(0, this, [this]() { allStepsFinished(); });
	} else {
		UiTestStep *step = m_steps.takeFirst();
		connect(step, &UiTestStep::finished, this, &UiTestStepGroup::stepFinished);
		qCDebug(venusGuiTest) << "UiTestStepGroup: start step" << step->type();
		step->start();
	}
}

void UiTestStepGroup::stepFinished(bool passed, const QString &errorText)
{
	UiTestStep *step = qobject_cast<UiTestStep *>(sender());
	Q_ASSERT(step);

	qCDebug(venusGuiTest) << "UiTestStepGroup: finished step" << step->type();

	switch (step->result()) {
	case UiTestStep::Passed:
		m_passedCount++;
		break;
	case UiTestStep::Failed:
		m_failedCount++;
		break;
	case UiTestStep::Unknown:
		break;
	}

	qCInfo(venusGuiTest) << qPrintable(QStringLiteral("\t[%1: %2%3]")
		  .arg(m_initialCount - m_steps.count() + 1)
		  .arg(step->summary())
		  .arg(step->message().isEmpty() ? QString() : ": " + step->message()));
	step->disconnect(this);
	step->deleteLater();

	if (passed) {
		QTimer::singleShot(0, this, &UiTestStepGroup::runNextStep);
	} else {
		qCInfo(venusGuiTest) << qPrintable(QStringLiteral("FAIL!\t: %1").arg(errorText));
		QTimer::singleShot(0, this, [this]() { allStepsFinished(); });
	}
}

void UiTestStepGroup::allStepsFinished()
{
	m_active = false;
	emit finished(m_passedCount, m_failedCount);
}


AbortStep::AbortStep(QObject *parent, bool passed, const QString &message)
	: UiTestStep(parent, Abort, message)
	, m_passed(passed)
{
}

void AbortStep::start()
{
	finish(m_passed, QStringLiteral("Test aborted"));
}

AbortStep *AbortStep::create(QObject *parent, const QVariantMap &params)
{
	const bool passed = params.value(QStringLiteral("passed")).toBool();
	return new AbortStep(parent, passed, messageText(params));
}


CaptureAndCompareStep::CaptureAndCompareStep(QObject *parent, QQuickWindow *window, const QString &filePrefix, const QString &message)
	: UiTestStep(parent, CaptureAndCompare, message)
	, m_window(window)
	, m_filePrefix(filePrefix)
{
}

QString CaptureAndCompareStep::summary() const
{
	QString s = QStringLiteral("%1: %2").arg(UiTestStep::summary()).arg(m_filePrefix);
	if (m_stabilizationCaptures > maxStabilizationCaptures()) {
		s += QStringLiteral(" (image is unstable?)");
	} else if (m_stabilizationCaptures > 2) { // disregard initial capture verifications
		s += QStringLiteral(" (%1 captures to stabilize)").arg(m_stabilizationCaptures - 2);
	}
	if (m_comparisonResult == ComparisonFailed) {
		s += QStringLiteral(" - comparison failed! See %1-FAIL.png").arg(m_filePrefix);
	}
	return s;
}

void CaptureAndCompareStep::start()
{
	Q_ASSERT(m_window);
	Q_ASSERT(!m_filePrefix.isEmpty());

	// Do an initial capture, then wait briefly and check whether the image has changed, before
	// doing the image comparison. Otherwise, if the page is still being loaded (e.g. if a Repeater
	// has not created all of its items) then the test may fail unnecessarily.
	capture();
	const int interval = settingValue(QStringLiteral("StabilizationInterval"), 16).toInt();
	m_stabilizationTimerId = startTimer(interval);
}

void CaptureAndCompareStep::timerEvent(QTimerEvent *event)
{
	Q_UNUSED(event);

	const QImage prevCapture = m_lastCapture;
	capture();

	// The image has not changed in the last <X> ms and we assume the UI has now stabilized. Or,
	// we've made too many unsuccessful attempts. Either way, use this latest capture for comparison
	// testing.
	if (prevCapture == m_lastCapture || m_stabilizationCaptures + 1 > maxStabilizationCaptures()) {
		killTimer(m_stabilizationTimerId);
		finalize();
	} else {
		m_stabilizationCaptures++;
	}
}

void CaptureAndCompareStep::capture()
{
	m_lastCapture = m_window->grabWindow().convertToFormat(QImage::Format_ARGB32);
}

void CaptureAndCompareStep::finalize()
{
	QString filePath = m_filePrefix;

	const QString captureFileName = absoluteImagePath(filePath + ".png");
	if (captureFileName.isEmpty()) {
		finish(false, QStringLiteral("Image path '%1' is invalid!").arg(captureFileName));
		return;
	}

	if (QFile::exists(captureFileName)) {
		// There is a previous capture for this image.
		QImage previousCapture(captureFileName);
		if (previousCapture == m_lastCapture) {
			// No comparison or saving required as the new capture is the same as the previous one.
			finish(true);
			return;
		}

		// If comparison is required, compare it against the previous version.
		static const QVariant comparisonThreshold = settingValue(QStringLiteral("ComparisonThreshold"));
		if (comparisonThreshold.isValid()
				&& !identicalImages(previousCapture,
									m_lastCapture,
									comparisonThreshold.value<qreal>(),
									absoluteImagePath(filePath + "-DIFF.png"))) {
			const QString fileNameFailed = absoluteImagePath(filePath + "-FAIL.png");
			m_comparisonResult = ComparisonFailed;
			if (!m_lastCapture.save(fileNameFailed)) {
				qWarning() << "Unable to save FAIL image to" << fileNameFailed;
			}
			if (settingValue(QStringLiteral("FailIfComparisonFails")).toBool()) {
				finish(false, QStringLiteral("Image comparison failed: %1 != %2").arg(fileNameFailed).arg(captureFileName));
			} else {
				finish(true);
			}
			// Comparison failed, so do not update the saved version of this image.
			return;
		}
	}

	// Save the captured image for future comparisons.
	if (m_lastCapture.save(captureFileName)) {
		finish(true);
	} else {
		finish(false, QStringLiteral("Failed to save captured image! %1").arg(captureFileName));
	}
}

QString CaptureAndCompareStep::absoluteImagePath(const QString &fileName)
{
	static QString dirPath;
	if (dirPath.isEmpty()) {
		dirPath = settingValue(CaptureAndCompare, QStringLiteral("ImageDir")).toString();
		if (!QDir().mkpath(dirPath)) {
			qWarning() << "mkpath() failed for image directory!" << dirPath;
			return QString();
		}
	}
	static QDir dir(dirPath);
	return dir.absoluteFilePath(fileName);
}

int CaptureAndCompareStep::maxStabilizationCaptures() const
{
	static const int attempts = settingValue(QStringLiteral("MaximumStabilizationCaptures"), 10).toInt();
	return attempts;
}

CaptureAndCompareStep *CaptureAndCompareStep::create(QObject *parent, QQuickWindow *window, const QString &imagePrefix, const QVariantMap &params)
{
	Q_ASSERT(window);
	Q_ASSERT(!imagePrefix.isEmpty());

	const QString imageName = params.value(QStringLiteral("imageName")).toString();
	if (imageName.isEmpty()) {
		qWarning() << "CaptureAndCompare: no imageName set!";
		return nullptr;
	}

	const QString filePath = QString("%1-%2").arg(imagePrefix).arg(imageName).replace("/", "_");
	return new CaptureAndCompareStep(parent, window, filePath, messageText(params));
}


InvokeStep::InvokeStep(QObject *parent, const QJSValue &callable, const QString &message)
	: UiTestStep(parent, Invoke, message)
	, m_callable(callable)
{
}

void InvokeStep::start()
{
	const QJSValue result = m_callable.call();
	if (result.isError()) {
		const QString &errorMsg = QStringLiteral("Callable triggered uncaught exception at line %1: %2")
				.arg(result.property("lineNumber").toInt())
				.arg(result.toString());
		finish(false, errorMsg);
		return;
	}

	if (result.isUndefined() || result.toBool()) {
		finish(true);
	} else {
		finish(false, QStringLiteral("Callable returned false!"));
	}
}

InvokeStep *InvokeStep::create(QObject *parent, const QVariantMap &params)
{
	const QJSValue callable = params.value(QStringLiteral("callable")).value<QJSValue>();
	if (!callable.isCallable()) {
		qWarning() << "Invoke: callable is not actually callable!";
		return nullptr;
	}
	return new InvokeStep(parent, callable, messageText(params));
}


WaitStep::WaitStep(QObject *parent, int timeout, const QString &message)
	: UiTestStep(parent, Wait, message)
	, m_timeout(timeout)
{
}

QString WaitStep::summary() const
{
	return QStringLiteral("%1: %2ms").arg(UiTestStep::summary()).arg(m_timeout);
}

void WaitStep::start()
{
	m_timerId = startTimer(m_timeout);
	if (m_timerId == 0) {
		finish(false, QStringLiteral("Unable to start timeout timer!"));
	}
}

void WaitStep::timerEvent(QTimerEvent *event)
{
	Q_UNUSED(event);
	killTimer(m_timerId);
	m_timerId = 0;
	finish(true);
}

WaitStep *WaitStep::create(QObject *parent, const QVariantMap &params)
{
	bool hasTimeout = false;
	const int timeout = params.value(QStringLiteral("timeout")).toInt(&hasTimeout);
	return new WaitStep(parent, hasTimeout ? timeout : 5000, messageText(params));
}


WaitUntilStep::WaitUntilStep(QObject *parent, const QJSValue &callable, int timeout, const QString &message)
	: UiTestStep(parent, WaitUntil, message)
	, m_callable(callable)
	, m_timeout(timeout)
{
}

void WaitUntilStep::start()
{
	m_timerId = startTimer(m_timeout);
	if (m_timerId == 0) {
		finish(false, QStringLiteral("Unable to start timeout timer!"));
	} else {
		tryCallable();
	}
}

void WaitUntilStep::tryCallable()
{
	if (m_timerId == 0) {
		return;
	}

	const QJSValue result = m_callable.call();
	if (result.isError()) {
		const QString &errorMsg = QStringLiteral("Callable triggered uncaught exception at line %1: %2")
				.arg(result.property("lineNumber").toInt())
				.arg(result.toString());
		finish(false, errorMsg);
		return;
	}

	if (result.toBool()) {
		// The waitUntil condition succeeded. Finish the step.
		finish(true);
	} else {
		// Wait until the next frame, and try again.
		QTimer::singleShot(16, this, &WaitUntilStep::tryCallable);
	}
}

void WaitUntilStep::timerEvent(QTimerEvent *event)
{
	Q_UNUSED(event);
	killTimer(m_timerId);
	m_timerId = 0;
	finish(false, QStringLiteral("Step timed out!"));
}

WaitUntilStep *WaitUntilStep::create(QObject *parent, const QVariantMap &params)
{
	const QJSValue callable = params.value(QStringLiteral("callable")).value<QJSValue>();
	if (!callable.isCallable()) {
		qWarning() << "WaitUntil: callable is not actually callable!";
		return nullptr;
	}
	bool hasTimeout = false;
	int timeout = params.value(QStringLiteral("timeout")).toInt(&hasTimeout);
	if (!hasTimeout) {
		timeout = settingValue(WaitUntil, QStringLiteral("DefaultTimeout"), 5000).toInt();
	}
	return new WaitUntilStep(parent, callable, timeout, messageText(params));
}
