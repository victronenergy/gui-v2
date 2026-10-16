/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKVALUEAPPLIER_H
#define VICTRON_GUIV2_MOCKVALUEAPPLIER_H

#include "mocktimerworker.h"

#include <QHash>
#include <QObject>
#include <QQueue>
#include <QTimer>

#include <functional>

namespace Victron {
namespace VenusOS {

class VeQItemMockProducer;

// Notification callbacks registered by individual animator instances
struct MockNotifyCallbacks {
	std::function<void(int index, qreal newValue)> onUpdate;
	std::function<void(qreal total)> onTotal;
};

/*
	MockValueApplier:
	1. Receives batched value updates from MockTimerWorker and applies them
	   spread across frames (max N per 16ms tick) to avoid binding cascade spikes.
	2. Emits notifyUpdate/notifyTotal only after setValue() has applied the
	   uids listed on that notify record. The worker must not emit those
	   QML signals itself.
*/
class MockValueApplier : public QObject
{
	Q_OBJECT

public:
	explicit MockValueApplier(QObject *parent = nullptr);

	// Maximum number of values to apply per frame tick.
	// More values can result in stutter (due to text layout etc),
	// but less values spreads updates over longer time period.
	static constexpr int MaxUpdatesPerTick = 16;

	// If queue exceeds this size, drain all immediately to prevent unbounded growth.
	static constexpr int MaxQueueSize = 256;

	// Register/unregister notification callbacks for a specific animator
	void registerNotify(int animatorId, const MockNotifyCallbacks &callbacks);
	void unregisterNotify(int animatorId);

	// Drop queued updates for uid, or for every uid under prefix, and the notify
	// records that depend on them.
	void removeQueued(const QString &uid);
	void removeQueuedUnderPrefix(const QString &prefix);
	// The queued value for uid if there is one, else the producer value.
	QVariant latestValue(const QString &uid) const;

	void applyValues(const MockValueUpdateList &updates,
			const MockNotifyEventList &notifications = {});

private Q_SLOTS:
	void processQueue();

private:
	VeQItemMockProducer *m_producer = nullptr;
	QQueue<MockValueUpdate> m_queue;
	QTimer m_drainTimer;

	// Direct dispatch map: animatorId -> callbacks
	QHash<int, MockNotifyCallbacks> m_notifyMap;
	// True while values or notifies are being applied. QML handlers run then, and
	// may call back in; the outer pass dispatches notifies when it is done.
	bool m_applying = false;

	bool notificationReady(const MockNotifyEvent &event) const;
	void enqueueNotification(const MockNotifyEvent &event);
	void dropNotifications(const std::function<bool(const QString &)> &affected);
	void dispatchNotification(const MockNotifyEvent &event);
	void dispatchReadyNotifications();

	// Notify records waiting until every dependsOn uid has left m_queue.
	QVector<MockNotifyEvent> m_pendingNotifications;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKVALUEAPPLIER_H
