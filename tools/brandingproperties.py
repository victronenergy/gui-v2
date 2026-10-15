#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Generates tools/branding-properties.json, the Branding property list that
# gui-v2-plugin-compiler.py uses for its literal-only check and to work out a
# plugin's requiredBrandingVersion. It is generated from the Q_PROPERTY
# declarations in src/branding/branding.h and the module version in
# cmake/ModuleBranding.cmake.
#
# Usage:
#   brandingproperties.py           regenerate the JSON file
#   brandingproperties.py --check   exit non-zero if the JSON file is out of date

import argparse
import json
import os
import re
import sys

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_HEADER = os.path.join(TOOLS_DIR, '..', 'src', 'branding', 'branding.h')
DEFAULT_CMAKE_FILE = os.path.join(TOOLS_DIR, '..', 'cmake', 'ModuleBranding.cmake')
DEFAULT_OUTPUT = os.path.join(TOOLS_DIR, 'branding-properties.json')

TYPE_NAMES = {
    'QColor': 'color',
    'QUrl': 'url',
    'QString': 'string',
    'QStringList': 'stringlist',
    'bool': 'bool',
    'int': 'int',
    'qreal': 'real',
    'double': 'real',
}

PROPERTY_RE = re.compile(r'Q_PROPERTY\(\s*([\w:<>]+)\s+(\w+)\s(.*)\)\s*$')
REVISION_RE = re.compile(r'\bREVISION\b\s*(\(\s*(\d+)\s*,\s*(\d+)\s*\))?')


def read_module_version(cmake_path):
    """Returns (major, minor) from the VICTRON_BRANDING_VERSION_* lines of cmake_path."""
    with open(cmake_path, encoding='utf-8') as file:
        text = file.read()
    version = []
    for part in ('MAJOR', 'MINOR'):
        match = re.search(r'set\(VICTRON_BRANDING_VERSION_%s\s+(\d+)\)' % part, text)
        if not match:
            raise ValueError('%s: no set(VICTRON_BRANDING_VERSION_%s <number>) line' % (cmake_path, part))
        version.append(int(match.group(1)))
    return tuple(version)


def read_properties(header_path, module_version):
    """Returns the Q_PROPERTY declarations of header_path as a list of (name, type, since) tuples.

    since is the (major, minor) version that added the property: its REVISION(major, minor),
    or the module's major.0 if it has none.
    """
    with open(header_path, encoding='utf-8') as file:
        lines = file.read().splitlines()
    properties = []
    for line in lines:
        match = PROPERTY_RE.search(line)
        if not match:
            continue
        cpp_type, name, rest = match.groups()
        if cpp_type not in TYPE_NAMES:
            raise ValueError('%s: property %s has unsupported type %s' % (header_path, name, cpp_type))
        since = (module_version[0], 0)
        revision = REVISION_RE.search(rest)
        if revision:
            if revision.group(1) is None:
                raise ValueError('%s: property %s: write its revision as REVISION(major, minor)'
                                 % (header_path, name))
            since = (int(revision.group(2)), int(revision.group(3)))
            if since[0] != module_version[0] or since[1] > module_version[1]:
                raise ValueError('%s: property %s: REVISION(%d, %d) does not fit the module version %d.%d'
                                 % ((header_path, name) + since + module_version))
        properties.append((name, TYPE_NAMES[cpp_type], since))
    if not properties:
        raise ValueError('%s: no Q_PROPERTY declarations found' % header_path)
    return properties


def generate(header_path, cmake_path):
    module_version = read_module_version(cmake_path)
    properties = [{'name': name, 'type': kind, 'since': '%d.%d' % since}
                  for name, kind, since in read_properties(header_path, module_version)]
    return json.dumps({
        'module': 'Victron.Branding',
        'version': '%d.%d' % module_version,
        'properties': properties,
    }, indent=4) + '\n'


def main():
    parser = argparse.ArgumentParser(description='Generates the Branding property list for the plugin compiler')
    parser.add_argument('--header', default=DEFAULT_HEADER)
    parser.add_argument('--cmake-file', default=DEFAULT_CMAKE_FILE)
    parser.add_argument('--output', default=DEFAULT_OUTPUT)
    parser.add_argument('--check', action='store_true', help='Fail if the output file is out of date')
    args = parser.parse_args()

    contents = generate(args.header, args.cmake_file)
    if args.check:
        try:
            with open(args.output, encoding='utf-8', newline='') as file:
                current = file.read().replace('\r\n', '\n')
        except OSError:
            current = None
        if current != contents:
            print('%s is out of date. Run tools/brandingproperties.py to regenerate it.' % args.output)
            return 1
        print('%s is up to date.' % args.output)
        return 0

    with open(args.output, 'w', encoding='utf-8', newline='\n') as file:
        file.write(contents)
    return 0


if __name__ == '__main__':
    sys.exit(main())
