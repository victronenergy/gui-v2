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

## Benchmarking page construction

`--ui-test benchmark/pages` measures how long pages take to construct, which is
what determines the delay between pressing a settings entry or an Overview
widget and the page appearing.  `PageStack.pushPage()` compiles and instantiates
the whole page synchronously before the push transition starts, so this time is
a hard freeze of the UI.

```bash
./venus-gui-v2 --mock --skip-splash --ui-test benchmark/pages
```

It emits three kinds of line on stderr:

| Line | Meaning |
|------|---------|
| `PAGEBENCH <pass> <compile> <instantiate> <url>` | Per page, in ms. The `cold` pass includes QML compilation; the `warm` pass is instantiation only, since Qt caches the compiled unit. |
| `PAGEBENCH-TOTAL <pass> <pages> <compile> <instantiate>` | Totals for the pass. |
| `COMPBENCH <ms> <type>` | Average construction cost of one instance of a list item type. Settings pages are built almost entirely out of these, so this is where a page's instantiation time goes. The types are declared as Components in the test, so this measures constructing one, not compiling it. |

The page list is deliberately a small, representative sample — the Overview
widget drilldowns plus the most-used settings pages — rather than every page in
the app, so that it does not need updating whenever a page is added or removed.

Reference numbers on a Cerbo GX (v3.80~57), median of 3 runs, for orientation:

```
warm instantiate      median 330 ms/page, worst 749 ms
cold compile          86 ms/page median, 309 ms worst; 2036 ms for the sample
                      (21 / 124 / 526 ms with Qt's bytecode cache populated)
one settings row      ListSetting 4 ms, ListNavigation 12 ms, ListSwitch 14 ms
```

The compile column is much noisier between runs than the instantiate column, so
treat a single page's compile figure as indicative only.

**Read the compile column carefully: it has two very different values, and
which one you measure depends on the state of a cache you cannot see.**  A GX
install puts the QML on disk as ~669 loose files under
`/opt/victronenergy/gui-v2/Victron/VenusOS`, and a url interceptor redirects the
types to those files rather than to the copy in the binary's resources (see
"Why qmlcachegen does nothing here" below).  Qt caches the bytecode it compiles
for them under
`/.cache/Venus/qmlcache`, and reuses a cached unit on a later run as long as it
is still valid for that source file and Qt version.  So a page costs:

- **86 ms** median, worst measured 309 ms, with the bytecode cache empty;
- **21 ms** median, worst 124 ms, with the bytecode cache populated.

Those are the two endpoints, and real devices sit between them, because the
cache is per source file rather than per page.  Opening a page compiles the page
document and every type it pulls in that is not already resident, so a page can
be part cached and part not: an update invalidates the files it changed and
leaves the rest (unless the Qt version changed, which invalidates everything),
and a page that has never been opened has never been compiled however long the
device has been up.  You can watch the engine decide, file by file, with
`QT_LOGGING_RULES="qt.qml.diskcache.debug=true"`, which reports lines like
`Checksum mismatch for cached version of ".../QuantityTable.qml"`.

To measure the empty-cache endpoint, delete `/.cache/Venus/qmlcache` (and the
copy under `/data/home/root/.cache/Venus/`) before **each** run.  Clearing it
once before a series of runs is the trap: the first run compiles and repopulates
it, the rest do not, and a median over the series lands between the endpoints
and means nothing in particular.

Either way this is what blocks the UI when a page is first opened:
`PageStack.pushPage()` builds the page with an incubator, but compiles it with
`Qt.createComponent()` first, which for a local url compiles synchronously.

A page's instantiation cost tracks the number of items its model builds, not the
number of rows the user can see on it: `PageAcIn` declares a single row of its
own, but the `PageAcInModel` it loads declares about thirty items, several of
them Repeaters over the AC phases, and the page takes 474 ms to instantiate.  So
the two ways to make a page open faster are to build fewer items or to make an
item cheaper.

### Why qmlcachegen does nothing here

`NO_CACHEGEN` defaults to `ON` in `CMakeLists.txt` — that is, compiling QML
ahead of time is *disabled* by default — and `scripts/build-gx.sh` does not
override it.  Given that a first run spends two seconds compiling QML, turning
it on looks like free speed.  It changes nothing at all, and the reason is worth
knowing before anyone tries again.

Measured on a Cerbo GX with two builds of the same source differing only in
`-DNO_CACHEGEN`, three runs of `--ui-test benchmark/pages` each, with
`/.cache/Venus/qmlcache` deleted before every run so that both are genuinely
compiling rather than reloading bytecode:

| | cachegen off (default) | cachegen on |
|---|---|---|
| cold compile, whole sample | 2036 ms | 2040 ms |
| cold compile, median page | 86 ms | 86 ms |
| warm instantiate, whole sample | 5553 ms | 5488 ms |
| `venus-gui-v2` size | 9.2 MB | 39.7 MB |

Not "a little better": identical.  The treatment did apply — 679 QML files were
compiled to C++, with AOT statistics generated for each, and the binary grew
4.3x — and it bought nothing at all.

Qt can only use ahead-of-time compiled code for a document it loads from the
resource filesystem, and on a GX it deliberately does not.  `src/main.cpp:518`
installs `UrlInterceptor` on the engine for `VENUS_GX_BUILD` only, and
`src/urlinterceptor.cpp` rewrites every url that starts with `qrc:/qt/qml/` and
ends in `.qml` to the matching file beside the executable.  That is not an
oversight — it is what lets someone edit QML on a Cerbo and restart gui-v2 to
see the change, and the file says so.

So the module's `qmldir` does carry `prefer :/qt/qml/Victron/VenusOS/`, and Qt
does resolve the types towards the resources as that asks; the interceptor then
sends each one back to the installed copy, and the ahead-of-time unit that
belongs to the resource url is never reached.  It also explains why a request
the benchmark makes explicitly as `qrc:` is reported at a `file://` url in the
disk cache log, and why the disk cache is populated at all.

Note what the interceptor does *not* touch: it matches only `.qml` under
`qrc:/qt/qml/`, so images, fonts, qmldir files and `Main.qml` — which lives at
`qrc:/venus-gui-v2/Main.qml` — still come from the resources.  This result is
therefore about the Victron QML that pages are built from, not about
qmlcachegen in general.

So enabling cachegen as things stand costs 30 MB of root filesystem — a large
fraction of the ~79 MB free on the device this was measured on — for no
measurable benefit to this page-construction path.  Making it pay for these
pages means changing or conditioning the interceptor, which today redirects
unconditionally: it could redirect only in a development configuration, or only
where an override file actually exists.  That is a product and architecture
decision about on-device editing, not a build flag.

Two limits on this result.  It says nothing about `qmltc`, which is a different
tool that generates C++ classes rather than compilation units.  And it measures
construction only: cachegen also compiles bindings and functions to native code,
and this benchmark would not see a gain in bindings evaluated later while the UI
runs.  That second limit does not rescue the QML above — a document loaded from
the filesystem has no ahead-of-time unit to draw on at any point in its life —
but it would apply to any QML that does load from the resources.
