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
	MockValueApplier lives on the GUI thread. It:
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

	// Drop queued copies of uid and ignore in-flight batches until the worker acks.
	void supersede(const QString &uid);
	void acknowledgeExternalWrite(const QString &uid);
	// Drop queued updates under prefix until forgetUidPrefix() emits uidPrefixForgotten().
	void blockPrefix(const QString &prefix);
	void acknowledgePrefix(const QString &prefix);
	bool hasPending(const QString &uid) const;

public Q_SLOTS:
	void applyValues(const Victron::VenusOS::MockValueUpdateList &updates,
			const Victron::VenusOS::MockNotifyEventList &notifications = {});

private Q_SLOTS:
	void processQueue();

private:
	VeQItemMockProducer *m_producer = nullptr;
	QQueue<MockValueUpdate> m_queue;
	QTimer m_drainTimer;

	// Direct dispatch map: animatorId -> callbacks
	QHash<int, MockNotifyCallbacks> m_notifyMap;
	// Uids with an external write the worker has not observed yet.
	QHash<QString, int> m_externalBlocks;
	// Service prefixes removed on the GUI thread. Held until the worker acks.
	QHash<QString, int> m_prefixBlocks;

	bool isBlocked(const QString &uid) const;
	void removeQueued(const QString &uid);
	void removeQueuedUnderPrefix(const QString &prefix);
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
