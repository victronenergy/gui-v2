#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
'''
Summarize the JSON results written by "uicompare --headless --output <file>".

A Markdown summary is written to stdout, which the UI test workflow appends to the GitHub job
summary. If --differences-dir is given, the baseline and candidate images of the screens that
differ are also copied into that directory (the worst --max-differences of them), so that a CI job
only has to upload the screens that actually changed instead of the whole image set. Any screens
left out are reported in the summary.
'''

import os
import json
import shutil
import argparse

# The maximum number of screens to list individually in the summary table.
MAX_LISTED_DIFFERENCES = 50

# The maximum number of screens whose images are copied by --differences-dir, so that the size of
# an uploaded artifact stays bounded when a change affects every screen.
DEFAULT_MAX_COPIED_DIFFERENCES = 200

STATUS_DESCRIPTIONS = [
    ('passed', 'Identical (within the error tolerance)'),
    ('failed', 'Different'),
    ('no_baseline', 'Only in the candidate'),
    ('no_candidate', 'Only in the baseline'),
]


def sorted_differences(report):
    '''Return the screens that are not identical, most interesting first.

    Screens that are missing from one of the two sets come first, as they are a structural change
    rather than a rendering difference; the rest are ordered by decreasing error.
    '''
    return sorted(
        (r for r in report.get('results', []) if r.get('status') != 'passed'),
        key=lambda r: (r.get('status') == 'failed', -r.get('mse', 0)),
    )


def copy_difference_images(results, baseline_dir, candidate_dir, differences_dir):
    '''Copy the baseline and candidate image of each differing screen into differences_dir.'''
    for result in results:
        file_name = result['file_name']
        for source_dir, suffix in ((baseline_dir, 'baseline'), (candidate_dir, 'candidate')):
            source = os.path.join(source_dir, file_name)
            if not os.path.isfile(source):
                continue
            name, extension = os.path.splitext(file_name)
            destination = os.path.join(differences_dir, f'{name}-{suffix}{extension}')
            os.makedirs(differences_dir, exist_ok=True)
            shutil.copyfile(source, destination)


def markdown_summary(report, baseline_label, candidate_label, copied_count=None):
    '''Return a Markdown report of the comparison results.'''
    summary = report.get('summary', {})
    differences = sorted_differences(report)

    lines = ['## UI image comparison', '']
    lines.append(
        f'Compared {summary.get("total", 0)} screens of `{candidate_label}` (candidate) against '
        f'`{baseline_label}` (baseline), with an MSE error tolerance of '
        f'{report.get("error_tolerance", "?")}.'
    )
    lines.append('')
    lines.append('| Result | Screens |')
    lines.append('| --- | ---: |')
    for key, description in STATUS_DESCRIPTIONS:
        lines.append(f'| {description} | {summary.get(key, 0)} |')
    lines.append('')

    if not differences:
        lines.append('No differences were found.')
        return '\n'.join(lines) + '\n'

    lines.append(
        'The screens below are not identical. This is expected if the pull request intentionally '
        'changes the UI; review the uploaded images to confirm that only the intended screens '
        'changed.'
    )
    lines.append('')
    lines.append('| Screen | Status | Mean squared error |')
    lines.append('| --- | --- | ---: |')
    for result in differences[:MAX_LISTED_DIFFERENCES]:
        # The error is only meaningful if both images were present and could be compared.
        error = f'{result.get("mse", 0):.2f}' if result.get('status') == 'failed' else '-'
        lines.append(f'| {result["file_name"]} | {result.get("status", "?")} | {error} |')
    if len(differences) > MAX_LISTED_DIFFERENCES:
        lines.append('')
        lines.append(f'...and {len(differences) - MAX_LISTED_DIFFERENCES} more.')
    if copied_count is not None and copied_count < len(differences):
        remaining = len(differences) - copied_count
        lines.append('')
        lines.append(
            f'Note: only the first {copied_count} of these screens were collected for review; '
            f'the images of the other {remaining} were not collected.'
        )
    return '\n'.join(lines) + '\n'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='ui_comparison_summary',
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument('results', help='The JSON file written by "uicompare --output"')
    parser.add_argument('--baseline-label', default='baseline', help='Name of the baseline revision')
    parser.add_argument('--candidate-label', default='candidate', help='Name of the candidate revision')
    parser.add_argument('--baseline-dir', default='image-captures-baseline', help='The baseline image directory')
    parser.add_argument('--candidate-dir', default='image-captures-candidate', help='The candidate image directory')
    parser.add_argument('--differences-dir', help='If set, copy the images of each differing screen into this directory')
    parser.add_argument('--max-differences', type=int, default=DEFAULT_MAX_COPIED_DIFFERENCES,
                        help=f'The maximum number of screens to copy into --differences-dir. Default: {DEFAULT_MAX_COPIED_DIFFERENCES}')
    args = parser.parse_args()

    with open(args.results, encoding='utf-8') as results_file:
        report = json.load(results_file)

    copied_count = None
    if args.differences_dir:
        # Copy in the same order as they are listed, so that a truncated set is the most useful one.
        differences = sorted_differences(report)[:max(args.max_differences, 0)]
        copied_count = len(differences)
        copy_difference_images(
            differences, args.baseline_dir, args.candidate_dir, args.differences_dir)

    print(markdown_summary(report, args.baseline_label, args.candidate_label, copied_count), end='')
