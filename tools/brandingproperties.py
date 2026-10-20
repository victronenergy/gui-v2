#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Generates tools/branding-properties.json from the Q_PROPERTY declarations in
# src/branding/branding.h and the module version in cmake/ModuleBranding.cmake. It is the Branding
# property list that gui-v2-plugin-compiler.py uses for its literal-only check and to work out a
# plugin's requiredBrandingVersion. It is also the checked-in record of the Victron.Branding API:
# plugins can only set properties, so the list of property names, types and versions is the whole
# API. This script will not remove a property from it, or change one's type or version, unless the
# major version goes up (see --allow-breaking-changes).
#
# Usage:
#   brandingproperties.py           regenerate it
#   brandingproperties.py --check   exit non-zero if it is out of date, or if branding.h breaks
#                                   the checked-in property list

import argparse
import json
import os
import re
import sys

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.dirname(TOOLS_DIR)
DEFAULT_HEADER = os.path.join(SOURCE_DIR, 'src', 'branding', 'branding.h')
DEFAULT_CMAKE_FILE = os.path.join(SOURCE_DIR, 'cmake', 'ModuleBranding.cmake')
DEFAULT_OUTPUT = os.path.join(TOOLS_DIR, 'branding-properties.json')

IF_NOT_SET = 'If not set:'

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
COMMENT_RE = re.compile(r'^\s*//\s?(.*)$')


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
    with open(header_path, encoding='utf-8') as file:
        return parse_properties(file.read(), header_path, module_version)


def parse_properties(header_text, header_path, module_version):
    """Returns the Q_PROPERTY declarations of header_text, in order, as a list of dicts.

    Each has the name, the type, since (the (major, minor) version that added the property: its
    REVISION(major, minor), or the module's major.0 if it has none), and the description and
    if_not_set text from the comment directly above the declaration.
    """
    properties = []
    comment = []
    for line in header_text.splitlines():
        comment_match = COMMENT_RE.match(line)
        if comment_match:
            comment.append(comment_match.group(1).strip())
            continue
        match = PROPERTY_RE.search(line)
        if not match:
            # A declaration this script cannot read would be missing from the property list.
            if 'Q_PROPERTY' in line:
                raise ValueError('%s: write each Q_PROPERTY on one line: %s' % (header_path, line.strip()))
            comment = []
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
        text = ' '.join(comment)
        description, _, if_not_set = text.partition(IF_NOT_SET)
        if not description.strip() or not if_not_set.strip() or IF_NOT_SET in if_not_set:
            raise ValueError('%s: property %s: the comment above it must say what it sets, then "%s" once, '
                             'and what is used then' % (header_path, name, IF_NOT_SET))
        properties.append({
            'name': name,
            'type': TYPE_NAMES[cpp_type],
            'since': since,
            'description': description.strip(),
            'if_not_set': if_not_set.strip(),
        })
        comment = []
    if not properties:
        raise ValueError('%s: no Q_PROPERTY declarations found' % header_path)
    return properties


def generate_json(module_version, properties):
    return json.dumps({
        'module': 'Victron.Branding',
        'version': '%d.%d' % module_version,
        'properties': [{'name': prop['name'], 'type': prop['type'], 'since': '%d.%d' % prop['since']}
                       for prop in properties],
    }, indent=4) + '\n'


def breaking_changes(old_list, module_version, properties):
    """Returns a message for each property of old_list that properties removes, or whose type or
    version it changes. old_list is the checked-in property list (the parsed JSON), or None.

    Plugins built against old_list may set any of its properties, so these changes break them.
    A new major version may make them.
    """
    if old_list is None:
        return []
    old_version = tuple(int(part) for part in old_list['version'].split('.'))
    if module_version[0] > old_version[0]:
        return []
    messages = []
    if module_version < old_version:
        messages.append('the module version went down, from %d.%d to %d.%d' % (old_version + module_version))
    new_properties = {prop['name']: prop for prop in properties}
    for old in old_list['properties']:
        prop = new_properties.get(old['name'])
        if prop is None:
            messages.append('%s was removed or renamed' % old['name'])
        elif prop['type'] != old['type']:
            messages.append('%s changed type, from %s to %s' % (old['name'], old['type'], prop['type']))
        elif '%d.%d' % prop['since'] != old['since']:
            messages.append('%s changed version, from %s to %d.%d' % ((old['name'], old['since']) + prop['since']))
    return messages


def new_properties_without_revision(old_list, module_version, properties):
    """Returns a message for each property that old_list does not have, and whose version is not the
    module version. A plugin that sets it must not load on a GUI that has an older version.
    """
    old_names = {prop['name'] for prop in old_list['properties']} if old_list else set()
    if not old_names:
        return []
    return ['%s is new, so it needs REVISION(%d, %d): the current module version' % ((prop['name'],) + module_version)
            for prop in properties
            if prop['name'] not in old_names and prop['since'] != module_version]


def read_text(path):
    try:
        with open(path, encoding='utf-8', newline='') as file:
            return file.read().replace('\r\n', '\n')
    except OSError:
        return None


def main():
    parser = argparse.ArgumentParser(description='Generates the Branding property list for the plugin compiler')
    parser.add_argument('--header', default=DEFAULT_HEADER)
    parser.add_argument('--cmake-file', default=DEFAULT_CMAKE_FILE)
    parser.add_argument('--output', default=DEFAULT_OUTPUT)
    parser.add_argument('--check', action='store_true', help='Fail if the output file is out of date')
    parser.add_argument('--allow-breaking-changes', action='store_true',
                        help='Allow removing a property, or changing its type or version, without a new major '
                             'version. Only do this for a property that no released GUI has.')
    args = parser.parse_args()

    module_version = read_module_version(args.cmake_file)
    properties = read_properties(args.header, module_version)

    current_list = read_text(args.output)
    old_list = json.loads(current_list) if current_list is not None else None
    breaking = [] if args.allow_breaking_changes else breaking_changes(old_list, module_version, properties)
    if breaking:
        print('%s breaks the Victron.Branding API in %s:' % (args.header, args.output))
        for message in breaking:
            print('  ' + message)
        print('Plugins built for Victron.Branding %s may set these properties. Keep them as they were, or '
              'increase VICTRON_BRANDING_VERSION_MAJOR in %s. If no released GUI has the property, run '
              'this script with --allow-breaking-changes.' % (old_list['version'], args.cmake_file))
    unversioned = new_properties_without_revision(old_list, module_version, properties)
    for message in unversioned:
        print('%s: %s' % (args.header, message))
    if breaking or unversioned:
        return 1

    contents = generate_json(module_version, properties)

    if args.check:
        if current_list != contents:
            print('%s is out of date. Run tools/brandingproperties.py to regenerate it.' % args.output)
            return 1
        print('%s is up to date.' % args.output)
        return 0

    with open(args.output, 'w', encoding='utf-8', newline='\n') as file:
        file.write(contents)
    return 0


if __name__ == '__main__':
    sys.exit(main())
