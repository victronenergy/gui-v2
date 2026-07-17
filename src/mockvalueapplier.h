/*
** Copyright (C) 2025 Victron Energy B.V.
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
	2. Receives batched notifications and dispatches them directly to the
	   target animator (by ID lookup), avoiding O(N²) broadcast.
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

public Q_SLOTS:
	void applyValues(const Victron::VenusOS::MockValueUpdateList &updates);
	void dispatchNotifyUpdate(int animatorId, int index, qreal newValue);
	void dispatchNotifyTotal(int animatorId, qreal total);

private Q_SLOTS:
	void processQueue();

private:
	VeQItemMockProducer *m_producer = nullptr;
	QQueue<MockValueUpdate> m_queue;
	QTimer m_drainTimer;

	// Direct dispatch map: animatorId -> callbacks
	QHash<int, MockNotifyCallbacks> m_notifyMap;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKVALUEAPPLIER_H
