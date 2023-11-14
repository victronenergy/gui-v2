/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "frameratemodel.h"

#include <QDateTime>
#include <QQuickWindow>

namespace Victron {
namespace VenusOS {

QObject* FrameRateModel::instance(QQmlEngine *, QJSEngine *)
{
	static FrameRateModel *frameRateModel = new FrameRateModel;
	return frameRateModel;
}

FrameRateModel::FrameRateModel(QObject *parent)
	: QAbstractListModel(parent)
{
	initChunks();
	initTimeslices();
	setVisualizationRate(20); // default to 20 fps updates.
	connect(&m_visualizationTimer, &QTimer::timeout,
		this, [this] {
			if (m_deltaTimer.isValid()) {
				const qint64 currTimestamp = QDateTime::currentMSecsSinceEpoch();
				qint64 delta = currTimestamp - m_lastFrameTimestamp;
				while (delta > m_expectedFrameDelta) {
					// The GUI thread is unblocked (else this handler wouldn't be invoked)
					// but time has passed - it must be because nothing in the UI
					// changed, and so no frames needed to be rendered.
					// Report the delta of "skipped" frames as successfully rendered.
					m_renderedFrameWithinTimeslice.removeFirst();
					m_renderedFrameWithinTimeslice.append(true);
					m_lastFrameTimestamp = currTimestamp;
					delta -= m_expectedFrameDelta;
				}
				updateChunks();
			}
		});
}

void FrameRateModel::setWindow(QQuickWindow *window)
{
	// We detect frame drops by listening to the afterRendering
	// signal and determining whether the UI thread is blocked
	// at that point.  The choice was somewhat arbitrary
	// (for example, could have chosen to listen to the
	// beforeSynchronizing() and afterSynchronizing()
	// signals, and determined whether the render thread
	// was blocked waiting to synchronize, instead),
	// but it was the simplest solution that still provides
	// reasonable accuracy.  It won't detect single-frame
	// drops reliably, but it will detect periods of lower
	// framerate with decent accuracy.

	QObject::connect(window, &QQuickWindow::afterRendering,
		this, [this] {
			{
				QMutexLocker lock(&m_blockedTimerMutex);
				if (!m_blockedTimer.isValid()) {
					m_blockedTimer.start();
				}
			}
			emit frameRendered();
		}); // direct connection, serviced in Render thread.

	QObject::connect(this, &FrameRateModel::frameRendered,
		this, [this] {
			// blocked is the time between the render thread emitting
			// afterRendering and the gui thread receiving frameRendered.
			// If the blocked timer is invalid, it means that we're
			// receiving a backlog of signals in the gui thread
			// due to a gui thread stall.
			qint64 blocked = -1;
			{
				QMutexLocker lock(&m_blockedTimerMutex);
				if (m_blockedTimer.isValid()) {
					blocked = m_blockedTimer.elapsed();
					m_blockedTimer.invalidate();
				}
			}

			// delta is the time between receiving frame rendered
			// signals on the gui thread.
			qint64 delta = m_deltaTimer.elapsed();
			if (blocked > 0) {
				// If blocked is non-zero, we certainly skipped frames.
				while (delta > m_expectedFrameDelta) {
					m_renderedFrameWithinTimeslice.removeFirst();
					m_renderedFrameWithinTimeslice.append(false);
					delta -= m_expectedFrameDelta;
				}
			} else {
				// If blocked is low but delta is large
				// it is likely that there was no content to render
				// for the entire duration of the delta,
				// so we can record the skipped frames as successful.
				while (delta > m_expectedFrameDelta) {
					m_renderedFrameWithinTimeslice.removeFirst();
					m_renderedFrameWithinTimeslice.append(true);
					delta -= m_expectedFrameDelta;
				}
			}

			// record the current frame timeslice as successful regardless.
			const qint64 currTimestamp = QDateTime::currentMSecsSinceEpoch();
			if ((currTimestamp - m_lastFrameTimestamp) > m_expectedFrameDelta) {
				m_renderedFrameWithinTimeslice.removeFirst();
				m_renderedFrameWithinTimeslice.append(true);
				m_lastFrameTimestamp = currTimestamp;
			}
			m_deltaTimer.start();
		}, Qt::QueuedConnection); // serviced in GUI thread.

	if (m_enabled) {
		m_deltaTimer.start();
	}
}

void FrameRateModel::updateChunks()
{
	// Calculate each "chunk".  A chunk consists of multiple frames.
	// The chunk value is the proportion of frames in the chunk
	// which were rendered within the appropriate timeslice.
	bool changed = false;
	qreal chunkValue = 0.0;
	const int frameCount = static_cast<int>(m_renderedFrameWithinTimeslice.count());
	for (int i = 0, c = 0; i < frameCount; i += m_framesPerChunk, ++c) {
		chunkValue = 0.0;
		for (int j = 0; j < m_framesPerChunk && ((i+j) < frameCount); ++j) {
			chunkValue += m_renderedFrameWithinTimeslice.at(i+j) ? 1.0 : 0.0;
		}
		chunkValue /= (1.0*m_framesPerChunk);
		if (m_chunks.at(c) != chunkValue) {
			changed = true;
			m_chunks[c] = chunkValue;
			// TODO: coalesce ranges of changed indexes.
			const QModelIndex changedIdx = index(c);
			emit dataChanged(changedIdx, changedIdx);
		}
	}
	if (changed) {
		emit chunksChanged();
	}

	// also update our fps, averaged over the last second
	qreal proportion = 0.0;
	const int chunksPerSecond = m_expectedFrameRate / m_framesPerChunk;
	for (int i = 0; i < chunksPerSecond; ++i) {
		proportion += m_chunks.at(m_chunkCount - i - 1);
	}
	proportion /= chunksPerSecond;
	const int newFps = static_cast<int>(m_expectedFrameRate * proportion);
	if (m_frameRate != newFps) {
		m_frameRate = newFps;
		emit frameRateChanged();
	}
}

void FrameRateModel::initChunks()
{
	QList<qreal> chunks;
	chunks.reserve(m_chunkCount);
	chunks.resize(m_chunkCount);
	std::fill(chunks.begin(), chunks.end(), 1.0);
	beginResetModel();
	m_chunks = chunks;
	endResetModel();
}

void FrameRateModel::initTimeslices()
{
	// initialize every timeslice by assuming that we successfully
	// rendered the associated frame.
	m_renderedFrameWithinTimeslice.clear();
	const int timeslices = m_secondsToVisualize * m_expectedFrameRate;
	m_renderedFrameWithinTimeslice.reserve(timeslices);
	for (int i = 0; i < timeslices; ++i) {
		m_renderedFrameWithinTimeslice.append(true);
	}
	m_lastFrameTimestamp = QDateTime::currentMSecsSinceEpoch();
}

bool FrameRateModel::isEnabled() const
{
	return m_enabled;
}

void FrameRateModel::setEnabled(bool enabled)
{
	if (m_enabled != enabled) {
		m_enabled = enabled;
		emit enabledChanged();
		if (enabled) {
			m_visualizationTimer.start();
			m_deltaTimer.start();
			QMutexLocker lock(&m_blockedTimerMutex);
			if (m_blockedTimer.isValid()) {
				m_blockedTimer.invalidate();
			}
		} else {
			m_visualizationTimer.stop();
			m_deltaTimer.invalidate();
		}
	}
}

int FrameRateModel::visualizationRate() const
{
	return m_visualizationRate;
}

void FrameRateModel::setVisualizationRate(int rate)
{
	if (m_visualizationRate != rate) {
		m_visualizationRate = rate;
		m_visualizationTimer.stop();
		m_visualizationTimer.setInterval(1000 / m_visualizationRate);
		if (m_enabled) {
			m_visualizationTimer.start();
		}
		emit visualizationRateChanged();
	}
}

int FrameRateModel::secondsToVisualize() const
{
	return m_secondsToVisualize;
}

void FrameRateModel::setSecondsToVisualize(int seconds)
{
	if (m_secondsToVisualize != seconds) {
		m_secondsToVisualize = seconds;
		setChunkCount(m_secondsToVisualize * (m_expectedFrameRate / m_framesPerChunk));
		initTimeslices();
		emit secondsToVisualizeChanged();
	}
}

int FrameRateModel::expectedFrameRate() const
{
	return m_expectedFrameRate;
}

void FrameRateModel::setExpectedFrameRate(int fps)
{
	if (m_expectedFrameRate != fps) {
		m_expectedFrameRate = fps;
		m_expectedFrameDelta = 1000 / m_expectedFrameRate;
		setChunkCount(m_secondsToVisualize * (m_expectedFrameRate / m_framesPerChunk));
		initTimeslices();
		emit expectedFrameRateChanged();
	}
}

int FrameRateModel::framesPerChunk() const
{
	return m_framesPerChunk;
}

void FrameRateModel::setFramesPerChunk(int frames)
{
	if ((m_expectedFrameRate % frames) != 0) {
		qWarning() << "Ignoring invalid frames per chunk, doesn't evenly divide expected fps";
	} else if (m_framesPerChunk != frames) {
		m_framesPerChunk = frames;
		setChunkCount(m_secondsToVisualize * (m_expectedFrameRate / m_framesPerChunk));
		emit framesPerChunkChanged();
	}
}

int FrameRateModel::chunkCount() const
{
	return m_chunkCount;
}

void FrameRateModel::setChunkCount(int count)
{
	if (m_chunkCount != count) {
		m_chunkCount = count;
		initChunks();
		emit chunkCountChanged();
		emit chunksChanged();
	}
}

QList<qreal> FrameRateModel::chunks() const
{
	return m_chunks;
}

int FrameRateModel::frameRate() const
{
	return m_frameRate;
}

int FrameRateModel::rowCount(const QModelIndex &) const
{
	return m_chunkCount;
}

QVariant FrameRateModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < m_chunkCount) {
		switch (role) {
			case Qt::DisplayRole: return m_chunks[row];
			case Qt::DecorationRole: return QColor(
						static_cast<int>(255 * (1.0 - m_chunks[row])),
						static_cast<int>(255 * m_chunks[row]),
						0, 255);
			default: break;
		}
	}
	return QVariant();
}

} // VenusOS
} // Victron
