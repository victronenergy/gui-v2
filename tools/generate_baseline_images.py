#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
import json
import os
import subprocess
import sys

def run_cmd(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if result.stdout:
            print("Cmd output:", result.stdout)
        if result.stderr:
            print("Cmd stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Cmd returncode: {e.returncode}")
        print("Cmd error:", e.stderr, file=sys.stderr)

def checkout_baseline(sha1):
    print('Checkout')
    run_cmd(["git", "checkout", sha1])

def build_in_directory(build_dir):
    print('Build')
    run_cmd(["rm", "-rf", build_dir])
    run_cmd(["mkdir", build_dir])
    os.chdir(build_dir)
    run_cmd(["cmake", "-DCMAKE_PREFIX_PATH=~/Qt/6.8.3/gcc_64", ".."])
    run_cmd(["cmake", "--build", ".", "--parallel", str(os.cpu_count())])

def generate_baseline_images():
    print('Generate')
    run_cmd(["./bin/venus-gui-v2", "--mock", "--ui-test", "smoke/mock-maximal"])
    run_cmd(["rm", "-rf", "../image-captures"])
    run_cmd(["mv", "image-captures", ".."])
    os.chdir("..")


if __name__ == '__main__':

    build_baseline_dir = "build-baseline"
    try:
        baseline_sha1 = sys.argv[1]
    except IndexError:
        baseline_sha1 = "ttomkins/ui-test-tools"

    print('Generating baseline capture images')
    checkout_baseline(baseline_sha1) 
    build_in_directory(build_baseline_dir)
    generate_baseline_images()

