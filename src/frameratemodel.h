/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_FRAMERATEMODEL_H
#define VICTRON_VENUSOS_GUI_V2_FRAMERATEMODEL_H

#include <QTimer>
#include <QElapsedTimer>
#include <QAbstractListModel>
#include <QMutex>

class QQuickWindow;
class QQmlEngine;
class QJSEngine;

namespace Victron {
namespace VenusOS {

/*
  An FPS counter which tries to be a bit clever about how to determines
  whether frames have been actually skipped due to GUI thread blockage,
  or merely omitted due to lack of changed content to render.

  The price of its increased accuracy is unfortunately large overhead.
  It performs a large number of calculations every frame, and then
  the results are visualized at a fast rate, which affects rendering.
  Enabling the FPS counter will adversely affect performance!
*/

class FrameRateModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
	Q_PROPERTY(int visualizationRate READ visualizationRate WRITE setVisualizationRate NOTIFY visualizationRateChanged)
	Q_PROPERTY(int secondsToVisualize READ secondsToVisualize WRITE setSecondsToVisualize NOTIFY secondsToVisualizeChanged)
	Q_PROPERTY(int expectedFrameRate READ expectedFrameRate WRITE setExpectedFrameRate NOTIFY expectedFrameRateChanged)
	Q_PROPERTY(int framesPerChunk READ framesPerChunk WRITE setFramesPerChunk NOTIFY framesPerChunkChanged)
	Q_PROPERTY(int chunkCount READ chunkCount NOTIFY chunkCountChanged)
	Q_PROPERTY(QList<qreal> chunks READ chunks NOTIFY chunksChanged)
	Q_PROPERTY(int frameRate READ frameRate NOTIFY frameRateChanged)

public:
	static QObject* instance(QQmlEngine *engine, QJSEngine *);
	explicit FrameRateModel(QObject *parent = nullptr);

	bool isEnabled() const;
	void setEnabled(bool enabled);

	int visualizationRate() const;
	void setVisualizationRate(int rate);
	int secondsToVisualize() const;
	void setSecondsToVisualize(int seconds);
	int expectedFrameRate() const;
	void setExpectedFrameRate(int fps);
	int framesPerChunk() const;
	void setFramesPerChunk(int frames);

	int chunkCount() const;
	QList<qreal> chunks() const;
	int frameRate() const;

	void setWindow(QQuickWindow *window);

	// QAbstractListModel
	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

Q_SIGNALS:
	void enabledChanged();
	void visualizationRateChanged();
	void secondsToVisualizeChanged();
	void expectedFrameRateChanged();
	void framesPerChunkChanged();
	void chunkCountChanged();
	void chunksChanged();
	void frameRateChanged();

	void frameRendered();

private:
	void setChunkCount(int count);
	void initTimeslices();
	void initChunks();
	void updateChunks();
	QMutex m_blockedTimerMutex;
	QTimer m_visualizationTimer;
	QElapsedTimer m_blockedTimer;
	QElapsedTimer m_deltaTimer;
	QList<qreal> m_chunks;
	QList<bool> m_renderedFrameWithinTimeslice;
	qint64 m_lastFrameTimestamp = 0;
	int m_visualizationRate = 0;
	int m_secondsToVisualize = 4;
	int m_expectedFrameRate = 60;
	int m_expectedFrameDelta = 16;
	int m_framesPerChunk = 3; // MUST evenly divide m_expectedFrameRate!
	int m_chunkCount = 80; // m_secondsToVisualize * (m_expectedFrameRate / m_framesPerChunk)
	int m_frameRate = -1;
	bool m_enabled = false;
};

} // VenusOS
} // Victron

#endif // VICTRON_VENUSOS_GUI_V2_FRAMERATEMODEL_H
