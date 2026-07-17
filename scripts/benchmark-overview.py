#!/usr/bin/env python3
"""
Benchmark script for comparing QSG_RENDER_TIMING frame data between
two builds of venus-gui-v2.

Usage:
    # Capture a run (uses built-in ui-test to navigate to Overview page):
    python scripts/benchmark-overview.py capture --exe path/to/venus-gui-v2 --output optimized.csv --duration 20

    # Capture with custom arguments:
    python scripts/benchmark-overview.py capture --exe path/to/venus-gui-v2 --output run.csv -- --mock --skip-splash --ui-test benchmark/overview

    # Compare two captured runs:
    python scripts/benchmark-overview.py compare --baseline baseline.csv --optimized optimized.csv
"""

import argparse
import csv
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def _ensure_utf8_stdout():
    """Reconfigure stdout/stderr for UTF-8 if possible (fixes Windows cp1252)."""
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')


def parse_timing_lines(lines):
    """Parse QSG_RENDER_TIMING output lines into frame records."""
    results = []
    # Qt 6 render timing format variants:
    #   "qt.scenegraph.time.renderloop: ..., sync=1.23, render=4.56, swap=0.78, ..."
    #   "white: sync 1 ms, render 4 ms, swap 0 ms, ..."
    #   "white: 1.23 ms in sync, 4.56 ms in render, 0.78 ms in swap"
    # We flexibly match "sync=X" or "sync X" or "X ms in sync" patterns.
    pat_eq = re.compile(
        r'sync\s*[=:]\s*([\d.]+).*?render\s*[=:]\s*([\d.]+)(?:.*?swap\s*[=:]\s*([\d.]+))?'
    )
    pat_ms = re.compile(
        r'([\d.]+)\s*(?:ms\s+)?(?:in\s+)?sync.*?([\d.]+)\s*(?:ms\s+)?(?:in\s+)?render(?:.*?([\d.]+)\s*(?:ms\s+)?(?:in\s+)?swap)?'
    )

    for line in lines:
        m = pat_eq.search(line)
        if not m:
            m = pat_ms.search(line)
        if m:
            sync = float(m.group(1))
            render = float(m.group(2))
            swap = float(m.group(3)) if m.group(3) else 0.0
            total = sync + render + swap
            results.append({
                'sync_ms': sync,
                'render_ms': render,
                'swap_ms': swap,
                'total_ms': total,
            })
    return results


def percentile(sorted_values, pct):
    """Return the value at the given percentile from a sorted list."""
    if not sorted_values:
        return 0.0
    idx = int(len(sorted_values) * pct / 100.0)
    idx = min(idx, len(sorted_values) - 1)
    return sorted_values[idx]


def compute_stats(records):
    """Compute summary statistics from frame records."""
    if not records:
        return None

    sync = sorted(r['sync_ms'] for r in records)
    render = sorted(r['render_ms'] for r in records)
    total = sorted(r['total_ms'] for r in records)

    avg = lambda vals: sum(vals) / len(vals)

    return {
        'frames': len(records),
        'sync_avg': avg(sync),
        'sync_p95': percentile(sync, 95),
        'sync_p99': percentile(sync, 99),
        'sync_max': max(sync),
        'render_avg': avg(render),
        'render_p95': percentile(render, 95),
        'render_p99': percentile(render, 99),
        'render_max': max(render),
        'total_avg': avg(total),
        'total_p95': percentile(total, 95),
        'total_p99': percentile(total, 99),
        'total_max': max(total),
        'fps_avg': 1000.0 / avg(total) if avg(total) > 0 else 0,
    }


def cmd_capture(args):
    """Capture QSG_RENDER_TIMING data from a venus-gui-v2 run."""
    exe = Path(args.exe)
    if not exe.exists():
        print(f"ERROR: Executable not found: {exe}", file=sys.stderr)
        sys.exit(1)

    print()
    print("=== Overview Animation Benchmark - Capture ===")
    print()
    print(f"Executable: {exe}")
    print(f"Duration:   {args.duration}s (+ {args.warmup}s warmup)")
    print()

    env = os.environ.copy()
    env['QSG_RENDER_TIMING'] = '1'
    # On Windows, GUI apps don't write to stderr by default; force it.
    env['QT_FORCE_STDERR_LOGGING'] = '1'

    # Ensure Qt libraries are findable
    qt_bin = args.qt_bin
    if qt_bin:
        env['PATH'] = qt_bin + os.pathsep + env.get('PATH', '')

    cmd = [str(exe)] + args.exe_args
    print(f"Launching: {' '.join(cmd)}")

    # Use a temp file for stderr to avoid pipe buffering issues
    fd, tmp_err = tempfile.mkstemp(suffix='_qsg_timing.txt')
    proc = None
    try:
        with os.fdopen(fd, 'w') as ferr:
            proc = subprocess.Popen(
                cmd,
                stderr=ferr,
                stdout=subprocess.DEVNULL,
                env=env,
            )

            print(f"  PID: {proc.pid}")
            print(f"  Warming up for {args.warmup}s...")
            time.sleep(args.warmup)

            if proc.poll() is not None:
                print(f"ERROR: Process exited with code {proc.returncode}", file=sys.stderr)
                sys.exit(1)

            # Record file position after warmup so we only parse frames
            # generated during the capture window.
            warmup_end_pos = os.path.getsize(tmp_err)

            print(f"  Capturing for {args.duration} seconds...")
            time.sleep(args.duration)
            print(f"  Stopping...")

            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()

        # Read only the lines written after the warmup period
        with open(tmp_err, 'r', encoding='utf-8', errors='replace') as f:
            f.seek(warmup_end_pos)
            lines = f.read().splitlines()
    except KeyboardInterrupt:
        print("\n  Interrupted — cleaning up...")
        if proc and proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
        sys.exit(130)
    finally:
        os.unlink(tmp_err)

    print(f"  Read {len(lines)} lines of output.")

    records = parse_timing_lines(lines)

    if not records:
        print("WARNING: No timing data parsed!", file=sys.stderr)
        print("First 30 lines of stderr:")
        for line in lines[:30]:
            print(f"  {line}")
        sys.exit(1)

    # Write CSV
    output = Path(args.output)
    with open(output, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['sync_ms', 'render_ms', 'swap_ms', 'total_ms'])
        writer.writeheader()
        writer.writerows(records)

    print(f"\nCaptured {len(records)} frames to: {output}")

    # Quick summary
    stats = compute_stats(records)
    print()
    print("Quick summary:")
    print(f"  Frames:     {stats['frames']}")
    print(f"  Sync avg:   {stats['sync_avg']:.2f} ms")
    print(f"  Render avg: {stats['render_avg']:.2f} ms")
    print(f"  Total avg:  {stats['total_avg']:.2f} ms")
    print(f"  Total p95:  {stats['total_p95']:.2f} ms")
    print(f"  Total max:  {stats['total_max']:.2f} ms")
    print(f"  FPS avg:    {stats['fps_avg']:.1f}")
    print()


def cmd_compare(args):
    """Compare two CSV benchmark files."""
    def load_csv(path):
        records = []
        with open(path) as f:
            reader = csv.DictReader(f)
            for row in reader:
                records.append({k: float(v) for k, v in row.items()})
        return records

    a_records = load_csv(args.baseline)
    b_records = load_csv(args.optimized)

    a = compute_stats(a_records)
    b = compute_stats(b_records)

    if not a or not b:
        print("ERROR: One or both files have no valid data.", file=sys.stderr)
        sys.exit(1)

    def fmt_delta(va, vb, lower_is_better=True):
        delta = vb - va
        pct = (delta / va * 100) if va != 0 else 0
        sign = '+' if delta >= 0 else ''
        improved = (delta <= 0) if lower_is_better else (delta >= 0)
        marker = ' ✓' if improved else ' ✗'
        return f"{sign}{delta:.2f} ({sign}{pct:.1f}%){marker}"

    # Column widths
    lw, cw, dw = 20, 12, 22

    baseline_name = Path(args.baseline).stem
    optimized_name = Path(args.optimized).stem

    print()
    print("=" * 70)
    print("  Overview Animation Benchmark Comparison")
    print("=" * 70)
    print()
    print(f"  {'Metric':<{lw}} {baseline_name:>{cw}} {optimized_name:>{cw}} {'Delta':>{dw}}")
    print(f"  {'─' * lw} {'─' * cw} {'─' * cw} {'─' * dw}")

    metrics = [
        ('Frames',          'frames',     'frames',     False),
        ('Sync avg (ms)',   'sync_avg',   'sync_avg',   True),
        ('Sync p95 (ms)',   'sync_p95',   'sync_p95',   True),
        ('Sync p99 (ms)',   'sync_p99',   'sync_p99',   True),
        ('Sync max (ms)',   'sync_max',   'sync_max',   True),
        ('Render avg (ms)', 'render_avg', 'render_avg', True),
        ('Render p95 (ms)', 'render_p95', 'render_p95', True),
        ('Render p99 (ms)', 'render_p99', 'render_p99', True),
        ('Render max (ms)', 'render_max', 'render_max', True),
        ('Total avg (ms)',  'total_avg',  'total_avg',  True),
        ('Total p95 (ms)',  'total_p95',  'total_p95',  True),
        ('Total p99 (ms)',  'total_p99',  'total_p99',  True),
        ('Total max (ms)',  'total_max',  'total_max',  True),
        ('FPS avg',         'fps_avg',    'fps_avg',    False),  # higher is better
    ]

    for label, ka, kb, lower_is_better in metrics:
        va = a[ka]
        vb = b[kb]
        if label == 'Frames':
            delta_str = ''
            print(f"  {label:<{lw}} {int(va):>{cw}} {int(vb):>{cw}} {delta_str:>{dw}}")
        else:
            delta_str = fmt_delta(va, vb, lower_is_better)
            print(f"  {label:<{lw}} {va:>{cw}.2f} {vb:>{cw}.2f} {delta_str:>{dw}}")

    print()
    print("  ✓ = improved, ✗ = regressed")
    print()


def main():
    _ensure_utf8_stdout()

    parser = argparse.ArgumentParser(
        description='Benchmark overview page animation performance'
    )
    subparsers = parser.add_subparsers(dest='command', required=True)

    # capture subcommand
    cap = subparsers.add_parser('capture', help='Capture timing data from a run')
    cap.add_argument('--exe', required=True, help='Path to venus-gui-v2 executable')
    cap.add_argument('--output', '-o', default='benchmark.csv', help='Output CSV file')
    cap.add_argument('--duration', '-d', type=int, default=15, help='Capture duration in seconds')
    cap.add_argument('--warmup', '-w', type=int, default=8, help='Warmup duration in seconds')
    cap.add_argument('--qt-bin', default=None, help='Path to Qt bin dir (for shared libs)')
    cap.add_argument('exe_args', nargs='*',
                     default=['--mock', '--skip-splash', '--ui-test', 'benchmark/overview'],
                     help='Arguments to pass to the executable'
                          ' (default: --mock --skip-splash --ui-test benchmark/overview)')

    # compare subcommand
    cmp = subparsers.add_parser('compare', help='Compare two benchmark CSVs')
    cmp.add_argument('--baseline', '-a', required=True, help='Baseline CSV (before changes)')
    cmp.add_argument('--optimized', '-b', required=True, help='Optimized CSV (after changes)')

    args = parser.parse_args()

    if args.command == 'capture':
        cmd_capture(args)
    elif args.command == 'compare':
        cmd_compare(args)


if __name__ == '__main__':
    main()
