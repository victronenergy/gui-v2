#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
'''
This script builds baseline and candidate versions of gui-v2, and runs each version with the
--ui-test option to generate image captures that can be compared by the UI Compare tool. It
also optionally launches the UI Compare tool to visually show the comparisons.

For example, to compare the gui-v2 UI between the 'main' branch and the current working branch,
using the "maximal" mock configuration and the default "smoke/mock-maximal" UI test:

    python tools/ui_capture_and_compare.py --qt-dir=~/Qt/6.8.3/gcc_64 --ui-test smoke/mock-maximal --mock-conf maximal

Build directories will be created in the system temp location, unless specified otherwise by the
--baseline-dir, --candidate-dir and --uicompare-dir options.

Note: build directories are NOT deleted on exit unless --clean-up is specified.

------------
How it works
------------

The script creates multiple gui-v2 builds in temporary directories and runs gui-v2 in ui-test mode
before collating the generated images.

For example, this compares images between tag v1.3.9 and my-feature-branch:

python tools/ui_capture_and_compare.py
    --qt-dir=~/Qt/6.8.3/gcc_64
    --baseline=v1.3.9
    --candidate=my-feature-branch

The above command triggers a sequence as follows:

1. a) Checks out the 'v1.3.9' tag
   b) Builds gui-v2 in <tmp>/build-gui-v2-baseline
   c) Runs venus-gui-v2 binary from this build with --ui-test to generate a set of baseline images
2. a) Checks out the 'my-feature-branch' tag
   b) Builds gui-v2 in <tmp>/build-gui-v2-candidate
   c) Runs venus-gui-v2 binary from this build with --ui-test to generate a set of candidate images
3. Checks out the original branch used prior to step 1 (if different from the candidate ref) to
   restore the previous repo state.
4. a) Builds tools/uicompare in <tmp>/build-gui-v2-uicompare
   b) Copies <baseline-build-dir>/image-captures and <candidate-build-dir>/image-captures into
      <uicompare-dir> to provide UI Compare with baseline and candidate image sets.
   c) Launches the UI Compare binary that was built

If step 1) or 2) fails, step 3) is still run to restore the original repo state.
'''

import os
import sys
import shutil
import platform
import tempfile
import subprocess
import argparse

TEMP_DIR = tempfile.gettempdir()
DEFAULT_BASELINE_BUILD_DIR = os.path.join(TEMP_DIR, 'build-gui-v2-baseline')
DEFAULT_CANDIDATE_BUILD_DIR = os.path.join(TEMP_DIR, 'build-gui-v2-candidate')
DEFAULT_UICOMPARE_BUILD_DIR = os.path.join(TEMP_DIR, 'build-gui-v2-uicompare')
DRY_RUN = False

# --- Utility functions ---

def run_command(cmd, cwd=None, check=True):
    '''Run a command, printing it and streaming output. Returns CompletedProcess.'''
    print(f'\n> {" ".join(cmd)}')
    if DRY_RUN:
        return None
    else:
        if cwd:
            print(f'  (in {cwd})')
        result = subprocess.run(cmd, cwd=cwd, check=check)
        return result


def start_and_wait(binary, cwd=None):
    '''Starts a process and blocks until the process is finished.'''
    print(f'\n > {binary}')
    if not DRY_RUN:
        if not os.path.exists(binary):
            sys.exit(f'Error: binary not found at {binary}')
        binary_process = subprocess.Popen([binary], cwd=cwd)
        binary_process.wait()


def is_git_tree_dirty():
    '''Return True if there are uncommitted changes in the working tree.'''
    result = subprocess.run(
        ['git', 'status', '--porcelain'],
        capture_output=True, text=True, check=True
    )
    return len(result.stdout.strip()) > 0


def git_repo_root():
    '''Return the absolute path to the git repository root.'''
    result = subprocess.run(
        ['git', 'rev-parse', '--show-toplevel'],
        capture_output=True, text=True, check=True
    )
    return result.stdout.strip()


def git_current_branch_or_sha1():
    '''Return the current branch name, or the HEAD sha1 if detached.'''
    result = subprocess.run(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        capture_output=True, text=True, check=True
    )
    branch = result.stdout.strip()
    if branch == 'HEAD':
        # Detached HEAD, return the sha1
        result = subprocess.run(
            ['git', 'rev-parse', 'HEAD'],
            capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    return branch


def git_ref_exists(ref):
    '''Return True if the given git ref (branch/tag/sha1) exists.'''
    result = subprocess.run(
        ['git', 'rev-parse', '--verify', ref],
        capture_output=True, text=True
    )
    return result.returncode == 0


def git_checkout(ref):
    '''Checkout the specified ref.'''
    run_command(['git', 'checkout', ref])


def find_binary(build_dir, name):
    '''Return the platform-appropriate path to a built binary.'''
    if platform.system() == 'Darwin':
        app_path = os.path.join(build_dir, 'bin', f'{name}.app', 'Contents', 'MacOS', name)
        if os.path.exists(app_path):
            return app_path
    elif platform.system() == 'Windows':
        return os.path.join(build_dir, 'bin', f'{name}.exe')
    return os.path.join(build_dir, 'bin', name)


# --- Build functions ---

def cmake_build(source_dir, build_dir, qt_dir, extra_cmake_args=None, jobs=None):
    '''Configure and build a cmake project.'''
    configure_cmd = [
        'cmake',
        '-S', source_dir,
        '-B', build_dir,
        f'-DCMAKE_PREFIX_PATH={qt_dir}',
    ]
    if extra_cmake_args:
        configure_cmd.extend(extra_cmake_args)

    run_command(configure_cmd)

    build_cmd = ['cmake', '--build', build_dir]
    if jobs:
        build_cmd.extend(['--parallel', str(jobs)])

    run_command(build_cmd)


# --- Image generation ---

def generate_images(build_dir, ui_test, mock_conf=None):
    '''Run venus-gui-v2 with the specified UI test to generate image captures.'''
    binary = find_binary(build_dir, 'venus-gui-v2')
    if not DRY_RUN and not os.path.exists(binary):
        sys.exit(f'Error: binary not found at {binary}')

    cmd = [binary, f'--ui-test={ui_test}']
    if mock_conf:
        cmd.append('--mock')
        cmd.append(f'--mock-conf={mock_conf}')
    run_command(cmd, cwd=build_dir)


def copy_images_to_uicompare(baseline_dir, candidate_dir, uicompare_dir):
    '''Copy image captures into the uicompare working directory.'''
    baseline_images = os.path.join(baseline_dir, 'image-captures')
    candidate_images = os.path.join(candidate_dir, 'image-captures')

    dest_baseline = os.path.join(uicompare_dir, 'image-captures-baseline')
    dest_candidate = os.path.join(uicompare_dir, 'image-captures')

    print(f'Copying baseline images from {baseline_images} to {dest_baseline}...')
    if not DRY_RUN:
        if os.path.exists(dest_baseline):
            shutil.rmtree(dest_baseline)
        if os.path.isdir(baseline_images):
            shutil.copytree(baseline_images, dest_baseline)
        else:
            sys.exit(f'Error: baseline images not found at {baseline_images}')

    print(f'Copying candidate images from {candidate_images} to {dest_candidate}...')
    if not DRY_RUN:
        if os.path.exists(dest_candidate):
            shutil.rmtree(dest_candidate)
        if os.path.isdir(candidate_images):
            shutil.copytree(candidate_images, dest_candidate)
        else:
            sys.exit(f'Error: candidate images not found at {candidate_images}')


# --- Main ---

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='ui_capture_and_compare',
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument('--qt-dir', required=True, help='The Qt build to use for building gui-v2 (e.g. ~/Qt/6.8.3/gcc_64)')
    parser.add_argument('--baseline-dir', default=DEFAULT_BASELINE_BUILD_DIR, help=f'The directory to use when building the gui-v2 baseline. Default: {DEFAULT_BASELINE_BUILD_DIR}')
    parser.add_argument('--candidate-dir', default=DEFAULT_CANDIDATE_BUILD_DIR, help=f'The directory to use when building the gui-v2 candidate. Default: {DEFAULT_CANDIDATE_BUILD_DIR}')
    parser.add_argument('--uicompare-dir', default=DEFAULT_UICOMPARE_BUILD_DIR, help=f'The directory to use when building tools/uicompare. Default: {DEFAULT_UICOMPARE_BUILD_DIR}')
    parser.add_argument('--baseline', default='main', help='The gui-v2 baseline branch/sha1/tag. Default: "main"')
    parser.add_argument('--candidate', default='', help='The gui-v2 candidate branch/sha1/tag. Default: current branch or sha1')
    parser.add_argument('--ui-test', help=f'gui-v2 argument: The UI test configuration to run')
    parser.add_argument('--mock-conf', help=f'gui-v2 argument: the mock configuration to use, if mock mode is desired')
    parser.add_argument('--clean-up', action='store_true', default=False, help='Delete all build directories on exit')
    parser.add_argument('--skip-baseline', action='store_true', default=False, help='Skip baseline build and image generation')
    parser.add_argument('--skip-candidate', action='store_true', default=False, help='Skip candidate build and image generation')
    parser.add_argument('-j', '--jobs', type=int, default=8, help='Number of parallel build jobs')
    parser.add_argument('-n', '--dry-run', action='store_true', help='Run the script without actually triggering any actions')
    args = parser.parse_args()

    DRY_RUN = args.dry_run
    source_dir = git_repo_root()
    original_ref = git_current_branch_or_sha1()
    baseline_ref = args.baseline
    candidate_ref = args.candidate or git_current_branch_or_sha1()

    # Validate environment
    if not args.dry_run and is_git_tree_dirty():
        sys.exit(
            'Error: working tree has uncommitted changes.\n'
            'Please commit or stash your changes before running this script.'
        )
    if not git_ref_exists(baseline_ref):
        sys.exit(f'Error: baseline ref "{baseline_ref}" does not exist.')
    if not git_ref_exists(candidate_ref):
        sys.exit(f'Error: candidate ref "{candidate_ref}" does not exist.')

    qt_dir = os.path.expanduser(args.qt_dir)
    if not os.path.isdir(qt_dir):
        sys.exit(f'Error: Qt directory not found: {qt_dir}')

    print(f'In repo {source_dir}, with current ref "{original_ref}"...')
    print(f'Will compare baseline "{baseline_ref}" against candidate "{candidate_ref}"...')
    print(f'Located Qt build in {qt_dir}...')

    try:
        if args.skip_baseline:
            print('Skipping baseline build and image generation...')
        else:
            print(f'\n=== Generate images for baseline "{baseline_ref}" in {args.baseline_dir} ===')
            git_checkout(baseline_ref)
            cmake_build(source_dir, args.baseline_dir, qt_dir, jobs=args.jobs)
            generate_images(args.baseline_dir, args.ui_test, mock_conf=args.mock_conf)

        if args.skip_candidate:
            print('Skipping candidate build and image generation...')
        else:
            print(f'\n=== Generate images for candidate "{candidate_ref}" in {args.candidate_dir} ===')
            git_checkout(candidate_ref)
            cmake_build(source_dir, args.candidate_dir, qt_dir, jobs=args.jobs)
            generate_images(args.candidate_dir, args.ui_test, mock_conf=args.mock_conf)

        if not (args.skip_baseline and args.skip_candidate):
            print('\n=== Restore original branch ===')
            git_checkout(original_ref)

        print('\n=== Build and launch UI Compare ===')
        uicompare_source = os.path.join(source_dir, 'tools', 'uicompare')
        cmake_build(uicompare_source, args.uicompare_dir, qt_dir, jobs=args.jobs)
        uicompare_binary = find_binary(args.uicompare_dir, 'uicompare')
        copy_images_to_uicompare(args.baseline_dir, args.candidate_dir, args.uicompare_dir)
        start_and_wait(uicompare_binary, cwd=args.uicompare_dir)

        print('\nDone!')

    except subprocess.CalledProcessError as e:
        print(f'\nError: command failed with exit code {e.returncode}', file=sys.stderr)
        sys.exit(-1)

    finally:
        try:
            git_checkout(original_ref)
        except Exception:
            print(f'Warning: could not restore branch "{original_ref}"', file=sys.stderr)

        if args.clean_up:
            print('\n=== Clean up ===')
            for dir_path in [args.baseline_dir, args.candidate_dir, args.uicompare_dir]:
                print(f'Deleting {dir_path}...')
                if not DRY_RUN and os.path.exists(dir_path):
                    shutil.rmtree(dir_path)
