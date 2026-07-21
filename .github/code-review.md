# Code Review Guide

Structured checklist for reviewing changes to gui-v2. Items are ordered by priority within each category.

## Table of contents

- [Review methodology](#review-methodology)
- [Correctness (highest priority)](#correctness-highest-priority)
  - [Invariant consistency](#invariant-consistency)
  - [Data flow and path correctness](#data-flow-and-path-correctness)
  - [Boundary validation](#boundary-validation)
  - [Thread safety](#thread-safety)
  - [Event delivery and ordering](#event-delivery-and-ordering)
  - [Backend disconnection and state transitions](#backend-disconnection-and-state-transitions)
  - [Lifecycle and resource management](#lifecycle-and-resource-management)
  - [Enable/disable and reconfiguration cycles](#enabledisable-and-reconfiguration-cycles)
  - [Numeric edge cases](#numeric-edge-cases)
  - [Collection and container edge cases](#collection-and-container-edge-cases)
  - [QML-specific correctness](#qml-specific-correctness)
  - [State machine and enum correctness](#state-machine-and-enum-correctness)
- [Performance (medium priority)](#performance-medium-priority)
  - [GUI thread stalls](#gui-thread-stalls)
  - [GUI thread execution pressure](#gui-thread-execution-pressure)
  - [Rendering performance](#rendering-performance)
  - [Memory pressure](#memory-pressure)
- [Maintainability (lower priority)](#maintainability-lower-priority)
  - [Code clarity](#code-clarity)
  - [Code style](#code-style)
  - [Documentation](#documentation)

---

## Review methodology

The checklist below describes WHAT to look for. This section describes HOW to apply it systematically. Do not skim — read every changed line and trace its implications.

### Per-function discipline

For each function or property setter that is new or modified:

1. **Read line by line.** Do not skip "obvious" code. Bugs hide in the lines you assume are correct.

2. **Enumerate all callers.** Find every call site (including signal connections and QML bindings). For each caller, verify the arguments are correct in type, order, range, and meaning. Ask: "What is the worst value this caller could pass, and does this function handle it?"

3. **Identify the downstream effect.** What does this function ultimately cause? (e.g., "posts config to worker", "writes a value to cache", "starts a timer"). Then trace ALL other code paths that lead to the same downstream effect and verify they share the same preconditions and guards.

4. **Check the else/error/early-return paths.** If the function has an early return or else branch, verify it cleans up or invalidates everything that the success path would have set. Partial cleanup is a bug.

5. **Simulate with edge-case inputs.** Mentally execute the function with: empty strings, empty collections, NaN, zero, negative numbers, null/undefined, maximum values, and the value it had on the previous call (no-change case).

### Cross-file verification

6. **Cross-reference constructed paths against data sources.** For every UID/path string built in code, find the JSON config file, D-Bus definition, or backend documentation that defines that path and verify character-by-character that they match. Do not assume a path is correct because it "looks right."

7. **Verify consistency between sibling implementations.** If multiple files implement the same pattern (e.g., several QML mock files each using `Global.system.serviceUid`), check ALL of them — not just the one being changed. Inconsistency between siblings usually means at least one is wrong.

### Temporal reasoning

8. **Trace the full lifecycle.** For any object or subsystem: what happens at creation → first use → reconfiguration → deactivation → reactivation → destruction? Verify each transition is handled and leaves the system in a valid state.

9. **Consider ordering between async operations.** When code posts multiple queued invocations or emits multiple signals, reason about what happens if other events interleave between them. Verify correctness doesn't depend on the assumption that queued calls execute atomically as a group.

10. **Ask "what if this is called twice?"** For setup/teardown operations, registrations, timer starts, and config posts — what happens if the same operation is triggered redundantly? It should be idempotent or properly guarded.

---

## Correctness (highest priority)

### Invariant consistency

For every function or property setter:

1. **Sibling consistency**: If multiple functions lead to the same downstream effect (e.g., posting config to a worker), verify that ALL of them share the same precondition guards. If one gates on `m_active`, all must gate on `m_active`. If one checks for empty strings, all must check for empty strings.

2. **State flag accuracy**: Track boolean state flags (`m_registered`, `m_active`, `m_complete`, etc.) through every code path. Verify they are set/cleared at the correct point — not before the action they represent, and not left stale after failure.

3. **Bidirectional map consistency**: If two maps are kept in sync (e.g., `m_timerIdToAnimator` / `m_animatorToTimer`), verify that every insert, remove, and clear operation affects both maps in all code paths including error/early-return paths.

4. **Re-entry safety**: If a function can be called while already in effect (e.g., re-registering an animator that's already registered), verify the old state is fully cleaned up before establishing new state.

5. **Conditional action completeness**: If a condition gates multiple related writes (e.g., "if has data, write power AND current AND phase count"), verify the else-branch clears ALL of the same fields — not a subset.

### Data flow and path correctness

6. **UID/path string construction**: For every constructed path string, verify it matches the actual data model. Cross-reference against JSON config files, D-Bus introspection data, or backend documentation. Common errors: missing path segments (`/Ac/1/P` vs `/Ac/In/1/P`), wrong separators, wrong index bases (0-based vs 1-based).

7. **Variable vs literal in string construction**: In template literals and `QString::arg()` calls, verify that loop variables and parameters are actually used — not accidentally left as literal text (e.g., `` `${prefix}/path` `` vs `` `${prefix}${path}` ``).

8. **Argument ordering and naming**: When a function takes multiple string/numeric arguments of the same type, verify callers pass them in the correct order. Watch for swapped arguments that happen to compile (e.g., two `QString` parameters swapped).

9. **Cross-boundary data consistency**: When QML posts data to C++, or GUI thread posts to worker thread, verify the values at the call site match what the receiver expects. Check types, ranges, and whether "empty" means `""`, `null`, `undefined`, `QVariant()`, or `-1`.

10. **Service UID prefix handling**: `Global.system.serviceUid` includes the backend prefix (`mock/`, `dbus/`, `mqtt/`). `VeQItemMockProducer::normalizedUid()` strips `mock/`. Verify that paths aren't double-prefixed or missing the prefix depending on which API consumes them.

### Boundary validation

11. **Validate inputs at component boundaries**: Functions that receive data from another component, thread, or QML layer must not assume inputs are well-formed. Validate that required strings are non-empty, required collections are non-empty, and numeric values are in expected ranges. An empty `targetPrefix` should not silently produce paths like `"/L1/Power"`.

12. **Fail safe on invalid input**: When input validation fails, the function should either return early (doing nothing), clear/invalidate any previously-written output, or emit an error signal. It must NOT proceed with garbage data and write nonsense to shared state.

13. **Validate at the earliest boundary**: If a value passes through multiple layers (QML → C++ property setter → queued invocation → worker function), validate at the first C++ entry point — not deep inside the worker where the damage is already in the queue.

14. **Document preconditions**: If a function requires non-empty strings, positive numbers, or non-null objects, document it. But still validate defensively — documentation alone doesn't prevent bugs.

### Thread safety

15. **Cross-thread data access**: Any data shared between threads must be protected. In this codebase, the primary pattern is message-passing via `QMetaObject::invokeMethod(Qt::QueuedConnection)` and signal/slot auto-connections. Verify no direct member access across thread boundaries.

16. **Signal emission from wrong thread**: If an object has thread affinity to thread A, its signals must be emitted from thread A. Emitting from thread B with connected slots on thread A is safe (queued), but emitting from thread B with connected slots on thread B (direct connection) while thread A may access shared state is not.

17. **Shared container modification**: `QHash`, `QMap`, `QList`, `QVector` are not thread-safe. If a container is read from one thread and written from another (even via queued connections), verify there is no concurrent access window.

18. **Atomic operations**: `std::atomic` is thread-safe for single reads/writes but compound operations (read-modify-write) may still race. Verify atomics are used correctly (e.g., `fetch_add` vs separate read + write).

### Event delivery and ordering

19. **Queued invocation ordering**: Multiple `QMetaObject::invokeMethod(Qt::QueuedConnection)` calls to the same target are delivered in order. But calls to DIFFERENT targets (e.g., worker first, then applier) may interleave with other events. Verify correctness doesn't depend on cross-object delivery order.

20. **Signal emission during construction**: `Component.onCompleted` in QML and constructor code in C++ may trigger signals before all related objects are fully initialized. Verify signal handlers don't access uninitialized siblings or properties.

21. **Deferred deletion**: `QObject::deleteLater()` and QML garbage collection mean an object may still receive queued signals/events after logical destruction. Verify handlers guard against stale state.

22. **Timer coalescing**: Zero-interval timers (`startTimer(0)`) fire once per event loop iteration but may coalesce multiple triggers. Verify that batch-flush patterns handle being called once even if multiple sources triggered.

23. **Model reset ordering**: When a model emits `modelReset`, all delegates are destroyed and recreated. Any state stored in delegates (connections, timers, cached values) is lost. Verify that delegate-held state is either reconstructed correctly or stored externally.

### Backend disconnection and state transitions

24. **Connection state regression**: `BackendConnection` can transition from `Ready` back to `Connecting` (network loss, VRM disconnect). Verify code handles the sequence Ready → Connecting → Ready without stale data or duplicate registrations.

25. **Service disappearance**: Services can disappear at any time (device unplugged, D-Bus service crash). `VeQuickItem.valid` becomes false, `value` becomes undefined/invalid. Verify code handles `!valid` / `undefined` / `NaN` gracefully in all consumers.

26. **Partial service data**: A service may appear with only some paths populated. Verify code doesn't assume all paths exist simultaneously (e.g., `/Ac/L1/Power` may exist without `/Ac/L2/Power`).

27. **Stale values after disconnect**: When a service disappears, cached/computed values derived from it must be cleared. Verify derived-value producers (calculators, aggregators) invalidate their outputs when inputs disappear.

28. **Reconnection idempotence**: If the backend reconnects, all `VeQuickItem` UIDs re-resolve. Verify that code which registers callbacks or watchers on service appearance doesn't double-register on reconnect.

### Lifecycle and resource management

29. **Parent-child ownership**: In C++, verify `QObject` parent-child relationships don't create double-free scenarios. In QML, verify that objects assigned to properties or stored in JS arrays don't outlive their expected scope.

30. **Instantiator delegate lifecycle**: `Instantiator` delegates are created/destroyed as the model changes. Any external registration (worker registration, signal connections to singletons) made in `Component.onCompleted` must be undone in `Component.onDestruction`.

31. **Loader content lifecycle**: `Loader.item` can be `null` when `active` is false or `source`/`sourceComponent` is empty. Verify all accesses guard against null.

32. **Singleton initialization order**: QML singletons are created on first access. If singleton A's construction accesses singleton B, and B's construction accesses A, there's a circular dependency. Verify no such cycles exist.

33. **Self-disabling resources**: When a timer, worker loop, or periodic callback detects that its work is pointless (degenerate configuration, empty input set, invalid range), it should stop itself rather than continuing to fire and no-op. A timer that repeatedly does nothing is both a performance waste and a correctness smell — it indicates the system is in a state the designer didn't anticipate.

34. **Resource cleanup on all exit paths**: If a function acquires a resource (starts a timer, registers a callback, allocates memory), verify that ALL exit paths — including early returns, error branches, and exceptions — release or account for that resource.

### Enable/disable and reconfiguration cycles

35. **Disable must clear all side effects**: When a component is deactivated (`active = false`, timer stopped, config cleared), ALL outputs and registrations produced while active must be cleaned up. Stale values left in caches, models, or backend paths after deactivation are bugs.

36. **Re-enable must fully reconstruct**: After disable → re-enable, the component must behave identically to fresh activation. Verify no state leaks from the previous activation (stale cached values, old timer IDs, leftover registrations).

37. **Reconfiguration = invalidate old + apply new**: When a component's configuration changes while active (e.g., target prefix changes, service list changes), the old outputs must be invalidated BEFORE the new configuration is applied. Otherwise stale values from the old config remain visible alongside new values.

38. **Reconfiguration while inactive**: If a property changes while the component is inactive, verify the change is noted but NOT acted upon (no config posted, no values written). The new config should only take effect on the next activation.

39. **Idempotent activation**: Calling `setActive(true)` when already active, or `setActive(false)` when already inactive, must be a no-op. Verify enable/disable paths are guarded by state checks and don't double-register or double-clear.

### Numeric edge cases

40. **NaN propagation**: `qIsNaN()` / `isNaN()` checks must happen before any arithmetic or comparison. NaN compared with `<=`, `>=`, `<`, `>` always returns false. NaN in `qMin`/`qMax` propagates. Verify NaN doesn't silently produce wrong results.

41. **NaN to int conversion**: `static_cast<int>(NaN)` is undefined behavior in C++. Always guard with `std::isnan()` before casting floating-point to integer.

42. **Integer overflow/underflow**: Array indices, timer intervals, and counters derived from floating-point or external data may overflow `int`. Verify bounds or use appropriate types.

43. **Division by zero**: Any division where the divisor comes from external data (VeQuickItem values, user input, computed results) must guard against zero.

44. **Floating-point equality**: `QVariant` comparison (`==`, `!=`) on floating-point values uses exact equality. Verify this is intentional (it usually is for cache-comparison, but can miss NaN since `NaN != NaN`).

45. **Truncation surprises**: Casting `qreal` (double) to `int` truncates toward zero. A value of 0.9 becomes 0, not 1. If the intent is rounding up, use `std::ceil()`. Validate the floating-point value BEFORE casting — not after, when information is already lost.

### Collection and container edge cases

46. **Empty collection access**: `first()`, `last()`, `at(0)` on empty `QList`/`QVector`/`QStringList` is undefined behavior. Verify emptiness checks before indexed access.

47. **Iterator invalidation**: Inserting/removing from a `QHash`/`QMap` while iterating invalidates iterators. Verify loops that modify containers use safe patterns (iterate a copy, or collect keys first).

48. **Index validity after mutation**: If an index into a container is stored (e.g., in a hash map for deduplication), verify the index remains valid after any operation that could resize or reorder the container.

45. **Model index validity**: `QModelIndex` from one model operation may be invalid after the model is mutated. Verify indices aren't cached across model changes.

### QML-specific correctness

46. **`parent` in nested QML objects**: Inside a `property var` declaration or a child of `QtObject`, `parent` refers to the visual parent — not the `QtObject`. Use explicit `id` references instead of `parent` when calling functions on a `QtObject`.

47. **Binding loops**: A property binding that writes to itself (directly or transitively) causes a binding loop warning and undefined behavior. Verify new bindings don't create cycles.

48. **Undefined vs null vs NaN**: In QML, `undefined` and `null` are distinct from `NaN`. `VeQuickItem.value` is `undefined` when not valid. Verify comparisons and arithmetic handle all three correctly (e.g., `isNaN(undefined)` is true in JS but `undefined === NaN` is false).

49. **Dynamic `uid` changes**: Changing a `VeQuickItem.uid` at runtime triggers unsubscribe from old + subscribe to new. Verify no code assumes the value is immediately available after a uid change (it may be undefined until the new subscription resolves).

50. **Duplicate VeQuickItems**: Multiple `VeQuickItem` instances bound to the same uid create redundant subscriptions and backend traffic. Prefer reusing a single instance (via `id` reference or shared component) where possible.

51. **Type coercion in comparisons**: JavaScript `==` performs type coercion. Prefer `===` unless coercion is intentional. Watch for `0 == ""` (true), `null == undefined` (true), `NaN == NaN` (false).

### State machine and enum correctness

52. **Switch exhaustiveness**: When switching on an enum, verify all values are handled. Missing cases can silently fall through to default/no-op, hiding bugs.

53. **Enum value assumptions**: Don't assume enum values are contiguous or start at 0. Use the actual enum constants, not arithmetic on raw integers.

54. **State transition validity**: For state machines, verify that transitions only occur from valid source states. Verify that entering a state always sets up the expected invariants for that state.

---

## Performance (medium priority)

### GUI thread stalls

These cause visible frame drops or UI freezes. Highest performance priority.

55. **Blocking synchronous calls**: Never call blocking I/O (file reads, network requests, `QProcess::waitForFinished`, `QThread::wait`) on the GUI thread. Use async patterns or worker threads.

56. **Mutex contention**: If a mutex is held by a worker thread during a long operation, and the GUI thread also acquires it (even briefly for a read), the GUI thread blocks. Prefer message-passing over shared-mutex architectures.

57. **Synchronous DNS/network**: `QNetworkAccessManager` is async, but some codepaths (QML `XMLHttpRequest` with sync flag, manual socket operations) can block. Verify no synchronous network I/O occurs on the GUI thread.

58. **Large JSON/XML parsing**: Parsing large JSON documents (`QJsonDocument::fromJson`) on the GUI thread can stall frames. For files >10KB, consider parsing on a worker thread.

59. **Sleep/busy-wait**: Never use `QThread::sleep`, `QThread::msleep`, busy-wait loops, or spin-locks on the GUI thread.

### GUI thread execution pressure

These don't block but consume excessive CPU time on the GUI thread, causing frame budget overruns.

60. **Binding cascade avalanche**: A single value change that triggers dozens of downstream binding re-evaluations can consume the entire frame budget. Watch for wide fan-out from frequently-changing properties (e.g., a timer-driven value that feeds 50+ bindings).

61. **O(n²) or worse in hot paths**: Operations triggered per-frame or per-value-change must be O(1) or O(log n). Linear scans of large collections in signal handlers, `onValueChanged`, or animation callbacks add up quickly.

62. **JavaScript in binding expressions**: Complex JS in bindings (loops, object allocation, string concatenation) runs on every re-evaluation. Prefer C++ helpers or precomputed properties for hot-path bindings.

63. **Frequent signal emission without change**: Emitting a signal when the value hasn't actually changed forces all connected slots/bindings to re-evaluate unnecessarily. Always guard signal emission with an equality check.

64. **Instantiator/Repeater with large models**: Creating hundreds of QML delegates simultaneously stalls the GUI thread. Use lazy loading, pagination, or `ListView` (which recycles delegates) instead of `Instantiator`/`Repeater` for large dynamic collections.

65. **Timer granularity**: Timers firing faster than the frame rate (< 16ms) burn CPU without visible benefit. Verify timer intervals are appropriate for their purpose.

66. **Redundant model updates**: Emitting `dataChanged` or resetting a model when no data actually changed forces views to re-render. Gate model signals on actual data differences.

### Rendering performance

67. **Shape and Canvas usage**: `Shape`/`ShapePath` and `Canvas` items require CPU-side path tessellation on every geometry or property change. Prefer `Image`/`BorderImage` for static shapes. For dynamic shapes, minimize property changes.

68. **Opacity and layer composition**: Setting `opacity` on an item with children forces layer composition (render to offscreen surface, then composite). Prefer `visible: false` to hide items instead of `opacity: 0`. If fading is needed, apply opacity only to leaf items.

69. **Clip and masking**: `clip: true` on an `Item` enables scissor clipping, which is cheap. But `layer.enabled: true` (used for rounded clipping) forces texture rendering. Minimize layer usage.

70. **Large texture uploads**: Loading large images or creating large offscreen textures stalls the render thread. Use `sourceSize` to constrain image decode size. Use `asynchronous: true` on `Image` for large files.

71. **Shader effects**: `ShaderEffect` and `ShaderEffectSource` force layer composition. Verify they're not applied to frequently-changing content or large item trees.

72. **Animation frame cost**: Animations that change `x`/`y`/`width`/`height`/`scale`/`rotation` on items with many children force layout recalculation. Prefer animating `transform` properties or using `Translate`/`Scale`/`Rotation` transform types which don't trigger re-layout.

73. **Font rendering**: Frequent changes to `Text.text` with different content lengths forces glyph cache updates and text layout recalculation. For rapidly updating numeric displays, consider fixed-width fonts or preformatted strings.

### Memory pressure

74. **Unbounded cache/queue growth**: Any cache, queue, or history buffer that grows without bound (no eviction, no size cap) will eventually exhaust memory on resource-constrained GX devices (256MB–512MB RAM). Verify all collections have a maximum size or cleanup policy.

75. **Retained object graphs**: QML objects referenced from JavaScript arrays, closures, or `property var` declarations prevent garbage collection. Verify dynamic objects are explicitly released when no longer needed.

76. **Image cache exhaustion**: Qt's image cache is bounded but large decoded textures can still accumulate. Verify that pages/views which are not visible release or unload their image sources.

77. **Model data duplication**: If a model stores the same data that's already in `VeQItem` tree nodes, that's doubled memory usage. Prefer referencing the tree directly where possible.

78. **Connection accumulation**: Each `connect()` call in C++ or `Connections {}` in QML that isn't eventually disconnected (via parent destruction or explicit disconnect) creates a retained closure. Verify connections in dynamic delegates are cleaned up on delegate destruction.

---

## Maintainability (lower priority)

### Code clarity

79. **Function length**: Functions over 50 lines should be considered for extraction. Each function should do one thing at one level of abstraction.

80. **Parameter count**: Functions with more than 4-5 parameters suggest the parameters should be grouped into a struct or that the function has too many responsibilities.

81. **Magic numbers and strings**: Literal numbers and repeated string constants should be named constants or enums. Exception: 0, 1, -1, and obvious mathematical constants.

82. **Naming precision**: Variable/function names should describe WHAT, not HOW. Prefer `maxPhaseIndex` over `idx`. Prefer `invalidateConsumptionValues` over `cleanup`.

83. **Dead code**: Unused functions, unreachable branches, commented-out code, and `#if 0` blocks add confusion. Remove them.

### Code style

84. **Formatting**: Follow `victron.astyle` rules — 1TBS braces, tab indentation, 120 character line limit. Run astyle before committing C++ changes.

85. **Include ordering**: System includes, then Qt includes, then project includes. Each group alphabetically sorted.

86. **Const correctness**: Use `const` on local variables, parameters, and member functions wherever possible. Prefer `constexpr` for compile-time constants.

87. **Auto usage**: Use `auto` when the type is obvious from the right-hand side (e.g., `auto it = map.find(key)`). Don't use `auto` when it obscures the type.

### Documentation

88. **Public API documentation**: Public C++ methods exposed to QML should have brief doc comments explaining purpose, preconditions, and thread-safety requirements.

89. **Non-obvious logic**: Complex algorithms, workarounds for Qt bugs, and platform-specific code should have comments explaining WHY, not WHAT.

90. **Architecture decisions**: If a design choice isn't obvious (e.g., "why is this on a worker thread?"), document the reasoning near the code or in the relevant topic guide under `.github/`.
