# Benchmarking

This guide explains how to measure rendering/animation performance of the
Overview page using the built-in benchmark UI test and the
`scripts/benchmark-overview.py` helper script.

## Overview

The benchmark uses Qt's **QSG_RENDER_TIMING** facility to collect per-frame
timing data from the scene graph render loop.  A dedicated UI test
(`tests/ui/benchmark/overview/`) automatically navigates to the Overview page
so that only the electron flow animations drive rendering — no manual
interaction is required.

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Python 3.8+ | For the benchmark script |
| Release build | Debug builds stall with `QSG_RENDER_TIMING` enabled |
| Qt bin on PATH | Or pass `--qt-bin` to the script |

> **Important:** Never use `--fpsCounter` during benchmarking — it adds an
> overlay that triggers additional rendering work and invalidates results.

## Environment variables

The benchmark script sets these automatically, but they are documented here for
reference:

| Variable | Value | Purpose |
|----------|-------|---------|
| `QSG_RENDER_TIMING` | `1` | Enables per-frame timing output from the Qt scene graph render loop |
| `QT_FORCE_STDERR_LOGGING` | `1` | **(Windows only)** Forces Qt logging to stderr instead of the Windows debug output channel, which is not captured by `subprocess.PIPE` |

> **Do not** set `QT_LOGGING_RULES` to filter scenegraph categories — it is
> unnecessary when `QSG_RENDER_TIMING=1` is set and may suppress other
> important log output.

## Building for benchmarking

The benchmark **must** use a Release build.  Debug builds interact badly with
`QSG_RENDER_TIMING` (the threaded render loop can stall during async mock data
loading).

```bash
cmake -B build-release -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=<path-to-qt>
cmake --build build-release --target venus-gui-v2
```

## Running a benchmark

### Capture timing data

```bash
python scripts/benchmark-overview.py capture \
    --exe build-release/bin/venus-gui-v2 \
    --output results.csv \
    --duration 15 \
    --warmup 10 \
    --qt-bin <path-to-qt>/bin
```

| Flag | Default | Description |
|------|---------|-------------|
| `--exe` | *(required)* | Path to the `venus-gui-v2` executable |
| `--output` / `-o` | `benchmark.csv` | Output CSV file |
| `--duration` / `-d` | `15` | Seconds to capture after warmup |
| `--warmup` / `-w` | `8` | Seconds to wait for app startup and test navigation |
| `--qt-bin` | *(none)* | Path to Qt `bin/` directory (added to PATH for shared libs) |
| `exe_args` | `--mock --skip-splash --ui-test benchmark/overview` | Arguments passed to the executable (override by appending after `--`) |

The script:
1. Launches the executable with `QSG_RENDER_TIMING=1`
2. Redirects stderr to a temporary file (avoids pipe buffer deadlock from
   high-frequency render timing output)
3. Waits for warmup (app loads, UI test navigates to Overview)
4. Captures for the specified duration
5. Terminates the process and parses frame timing from the log
6. Writes a CSV with columns: `sync_ms`, `render_ms`, `swap_ms`, `total_ms`

### Compare two runs

```bash
python scripts/benchmark-overview.py compare \
    --baseline baseline.csv \
    --optimized feature.csv
```

Prints a table showing per-metric deltas with ✓/✗ indicators for
improvements/regressions.

## The benchmark UI test

The test configuration (`tests/ui/benchmark/overview/overview.json`) uses:

```json
{
    "ExitWhenFinished": false,
    "Mock": {
        "Configuration": ":/data/mock/conf/maximal.json",
        "TimersActive": false,
        "UIAnimations": 1
    }
}
```

Key settings:
- **`TimersActive: false`** — Mock data timers are disabled so that label/value
  updates do not cause rendering work unrelated to the animations being
  measured.
- **`UIAnimations: 1`** — Animations are enabled so the electron flow arrows
  run continuously, driving the render loop.
- **`ExitWhenFinished: false`** — The application stays alive after the test
  completes (allowing the script to control the run duration via process
  termination).

The test QML (`tst_benchmark_overview.qml`) waits for the "Overview" nav bar
button to become available (the UI takes several seconds to load on embedded
hardware, especially with `--skip-splash`), clicks it, waits for the page
transition to complete, then holds for 30 seconds while the animations run.

> **Important:** On device, the nav bar buttons do not exist immediately after
> launch.  The app must finish loading data sources, instantiating the
> SwipeView pages, and animating the nav bar into view.  Always use a
> `WaitUntil` step to confirm the target button exists before attempting to
> click it — otherwise the test silently runs on the wrong page and produces
> invalid benchmark data.

## Interpreting results

| Metric | Meaning |
|--------|---------|
| `sync_ms` | CPU time spent synchronising the QML scene graph with the render thread |
| `render_ms` | GPU time spent drawing the frame |
| `swap_ms` | Time waiting for buffer swap (vsync) |
| `total_ms` | Sum of sync + render + swap |
| `fps_avg` | `1000 / total_avg` — effective frame rate |

On desktop hardware the GPU render time is typically <1 ms and the CPU sync
time dominates (~14 ms).  The optimisations target embedded GX hardware where
the GPU is the bottleneck.

Key metrics to watch:
- **Total p95 / p99** — steady-state frame time under load
- **Total max** — worst-case stall (affects perceived smoothness)
- **Frame count** — fewer frames with equal fps may indicate the render loop
  skips unnecessary repaints (a positive sign)

## Typical comparison workflow

```bash
# 1. Build both branches as Release
cmake -B build-main -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=<qt>
cmake --build build-main --target venus-gui-v2

cmake -B build-feature -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=<qt>
cmake --build build-feature --target venus-gui-v2

# 2. Capture
python scripts/benchmark-overview.py capture --exe build-main/bin/venus-gui-v2 -o baseline.csv --qt-bin <qt>/bin
python scripts/benchmark-overview.py capture --exe build-feature/bin/venus-gui-v2 -o feature.csv --qt-bin <qt>/bin

# 3. Compare
python scripts/benchmark-overview.py compare -a baseline.csv -b feature.csv
```

> **Tip:** Close other GPU-intensive applications during benchmarking to reduce
> variance.  Run each capture 2–3 times and compare the most representative
> results.
