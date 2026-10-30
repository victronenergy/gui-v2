#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Generates two things from the Q_PROPERTY declarations in src/branding/branding.h, the property
# reference in src/branding/branding.cpp, and the module version in cmake/ModuleBranding.cmake:
#  - tools/branding-properties.json, the Branding property list that gui-v2-plugin-compiler.py uses
#    to work out a plugin's requiredBrandingVersion. It is also the
#    checked-in record of the Victron.Branding API: plugins can only set properties, so the list of
#    property names, types and versions is the whole API. This script will not remove a property
#    from it, or change one's type or version, unless the major version goes up (see
#    --allow-breaking-changes). Once a gui-v2 release tag (vX.Y.Z) contains the list, a property
#    that tag does not have must belong to a newer module version than the one that was released.
#  - the property reference in .github/branding-plugins.md, between the BEGIN and END lines below.
#    Each entry is the matching entry in branding.cpp, plus Victron's value of each branding color,
#    read from themes/color/Dark.json.
#
# Usage:
#   brandingproperties.py           regenerate both
#   brandingproperties.py --check   exit non-zero if either is out of date, or if branding.h breaks
#                                   the checked-in property list

import argparse
import json
import os
import re
import subprocess
import sys

from themeparser import THEME_KEY_TO_BRANDING_COLOR

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.dirname(TOOLS_DIR)
DEFAULT_HEADER = os.path.join(SOURCE_DIR, 'src', 'branding', 'branding.h')
DEFAULT_IMPLEMENTATION = os.path.join(SOURCE_DIR, 'src', 'branding', 'branding.cpp')
DEFAULT_CMAKE_FILE = os.path.join(SOURCE_DIR, 'cmake', 'ModuleBranding.cmake')
DEFAULT_THEME_DIR = os.path.join(SOURCE_DIR, 'themes', 'color')
DEFAULT_OUTPUT = os.path.join(TOOLS_DIR, 'branding-properties.json')
DEFAULT_DOCS = os.path.join(SOURCE_DIR, '.github', 'branding-plugins.md')

DOCS_BEGIN = ('<!-- BEGIN property reference. tools/brandingproperties.py writes this part from '
              'src/branding/branding.cpp: edit the property reference there, not this text. -->')
DOCS_END = '<!-- END property reference -->'
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

# The type names in the property reference, for people writing a Branding file.
DOCS_TYPE_NAMES = {
    'color': 'color',
    'url': 'url (a file path)',
    'string': 'string',
    'stringlist': 'list of strings',
    'bool': 'bool',
    'int': 'whole number',
    'real': 'number',
}

PROPERTY_RE = re.compile(r'Q_PROPERTY\(\s*([\w:<>]+)\s+(\w+)\s(.*)\)\s*$')
REVISION_RE = re.compile(r'\bREVISION\b\s*(\(\s*(\d+)\s*,\s*(\d+)\s*\))?')
REFERENCE_BEGIN = 'BEGIN property reference'
REFERENCE_END = 'END property reference'
NAME_RE = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*$')
# gui-v2 release tags. v1.1.29-test-tag and any other suffix are not releases.
RELEASE_TAG_RE = re.compile(r'^v\d+\.\d+\.\d+$')
RELEASED_PROPERTIES_PATH = 'tools/branding-properties.json'


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


def implementation_path_for(header_path):
    return os.path.join(os.path.dirname(header_path), 'branding.cpp')


def read_properties(header_path, module_version, implementation_path=None):
    if implementation_path is None:
        implementation_path = implementation_path_for(header_path)
    with open(header_path, encoding='utf-8') as file:
        properties = parse_properties(file.read(), header_path, module_version)
    with open(implementation_path, encoding='utf-8') as file:
        reference = parse_reference(file.read(), implementation_path)
    return attach_reference(properties, reference, header_path, implementation_path)


def parse_properties(header_text, header_path, module_version):
    """Returns the Q_PROPERTY declarations of header_text, in order, as a list of dicts.

    Each has the name, the type, and since: the (major, minor) version that added the property.
    That is its REVISION(major, minor), or the module's major.0 if it has none.
    """
    properties = []
    for line in header_text.splitlines():
        match = PROPERTY_RE.search(line)
        if not match:
            # A declaration this script cannot read would be missing from the property list.
            if 'Q_PROPERTY' in line:
                raise ValueError('%s: write each Q_PROPERTY on one line: %s' % (header_path, line.strip()))
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
        properties.append({
            'name': name,
            'type': TYPE_NAMES[cpp_type],
            'since': since,
        })
    if not properties:
        raise ValueError('%s: no Q_PROPERTY declarations found' % header_path)
    return properties


def parse_reference(implementation_text, implementation_path):
    """Returns the property reference entries of implementation_text, in order.

    Each entry is the property name, what it sets, and what is used when it is not set.
    """
    begin = implementation_text.find(REFERENCE_BEGIN)
    end = implementation_text.find(REFERENCE_END)
    if begin < 0 or end < begin or implementation_text.find(REFERENCE_BEGIN, begin + len(REFERENCE_BEGIN)) >= 0:
        raise ValueError('%s must contain %r once, followed by %r'
                         % (implementation_path, REFERENCE_BEGIN, REFERENCE_END))
    blocks = re.split(r'\n\s*\n', implementation_text[begin + len(REFERENCE_BEGIN):end].strip())
    if blocks and not NAME_RE.match(blocks[0].strip().splitlines()[0].strip()):
        blocks = blocks[1:]
    entries = []
    for block in blocks:
        lines = [line.strip() for line in block.splitlines() if line.strip()]
        if not lines:
            continue
        name = lines[0]
        if not NAME_RE.match(name):
            raise ValueError('%s: a property reference entry must start with the property name, not %r'
                             % (implementation_path, name))
        text = ' '.join(lines[1:])
        description, separator, if_not_set = text.partition(IF_NOT_SET)
        if not description.strip() or not separator or not if_not_set.strip() or IF_NOT_SET in if_not_set:
            raise ValueError('%s: property %s: the reference must say what it sets, then "%s" once, '
                             'and what is used then' % (implementation_path, name, IF_NOT_SET))
        entries.append({
            'name': name,
            'description': description.strip(),
            'if_not_set': if_not_set.strip(),
        })
    if not entries:
        raise ValueError('%s: the property reference has no entries' % implementation_path)
    return entries


def attach_reference(properties, reference, header_path, implementation_path):
    """Returns properties with each entry's description and if_not_set copied on.

    reference must name the same properties as properties, in the same order.
    """
    property_names = [prop['name'] for prop in properties]
    reference_names = [entry['name'] for entry in reference]
    if reference_names != property_names:
        if sorted(reference_names) == sorted(property_names):
            raise ValueError('%s: the property reference must list the properties in the same order as %s'
                             % (implementation_path, header_path))
        missing = [name for name in property_names if name not in reference_names]
        extra = [name for name in reference_names if name not in property_names]
        raise ValueError('%s: the property reference must list the same properties as %s. Missing: %s. Extra: %s.'
                         % (implementation_path, header_path,
                            ', '.join(missing) or 'none', ', '.join(extra) or 'none'))
    for prop, entry in zip(properties, reference):
        prop['description'] = entry['description']
        prop['if_not_set'] = entry['if_not_set']
    return properties


def read_victron_colors(theme_dir, color_property_names):
    """Returns {Branding property name: hex}: Victron's value of each branding color that Dark.json sets."""
    with open(os.path.join(theme_dir, 'Dark.json'), encoding='utf-8') as file:
        dark = json.load(file)
    with open(os.path.join(theme_dir, 'ColorDesign.json'), encoding='utf-8') as file:
        design = json.load(file)
    colors = {}
    for theme_key, enum_value in THEME_KEY_TO_BRANDING_COLOR.items():
        # The Branding property is named after the BrandingData::Color value: BackgroundPage is
        # color_background_page. The Theme key can differ (color_page_background).
        name = 'color_' + re.sub(r'(?<!^)(?=[A-Z])', '_', enum_value).lower()
        if name not in color_property_names:
            raise ValueError('BrandingData::%s has no Branding property %s' % (enum_value, name))
        value = dark.get(theme_key)
        if value is None:
            continue
        value = design.get(value, value)
        if not re.fullmatch(r'#[0-9A-Fa-f]{6}', value):
            raise ValueError('Dark.json: %s must be a #RRGGBB color, or the name of one in ColorDesign.json'
                             % theme_key)
        colors[name] = value
    return colors


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


def version_tuple(text):
    parts = text.split('.')
    if len(parts) != 2 or not all(part.isdigit() for part in parts):
        raise ValueError('not a major.minor version: %s' % text)
    return tuple(int(part) for part in parts)


def git_output(repo_dir, args):
    return subprocess.run(['git', '-C', repo_dir, *args], capture_output=True, text=True)


def read_released_branding_list(repo_dir):
    """Returns (tag, property list) for the latest gui-v2 release merged into HEAD, if that release
    contains the Branding property list. (None, None) if Victron.Branding has not been released.

    A missing git checkout has nothing to compare with. A shallow clone, or a tag whose commit
    cannot be read, is an error: skipping it would hide a property added after a release.
    """
    inside = git_output(repo_dir, ['rev-parse', '--is-inside-work-tree'])
    if inside.returncode != 0 or inside.stdout.strip() != 'true':
        return None, None
    shallow = git_output(repo_dir, ['rev-parse', '--is-shallow-repository'])
    if shallow.returncode != 0:
        raise ValueError('%s: cannot read the release tags (%s)' % (repo_dir, shallow.stderr.strip()))
    if shallow.stdout.strip() == 'true':
        raise ValueError('This is a shallow clone, so the released Victron.Branding API cannot be read. '
                         'Fetch the full history and the vX.Y.Z tags.')
    listed = git_output(repo_dir, ['tag', '--list', 'v*', '--merged', 'HEAD', '--sort=-v:refname'])
    if listed.returncode != 0:
        raise ValueError('%s: cannot list release tags (%s)' % (repo_dir, listed.stderr.strip()))
    tag = next((line.strip() for line in listed.stdout.splitlines() if RELEASE_TAG_RE.match(line.strip())), None)
    if tag is None:
        return None, None
    commit = git_output(repo_dir, ['rev-parse', '--verify', '--quiet', '%s^{commit}' % tag])
    if commit.returncode != 0:
        raise ValueError('Cannot read release tag %s. Fetch the full history and the vX.Y.Z tags.' % tag)
    shown = git_output(repo_dir, ['show', '%s:%s' % (tag, RELEASED_PROPERTIES_PATH)])
    if shown.returncode != 0:
        missing = 'not in' in shown.stderr or 'does not exist' in shown.stderr or 'exists on disk' in shown.stderr
        if missing:
            return None, None
        raise ValueError('Cannot read %s at %s: %s' % (RELEASED_PROPERTIES_PATH, tag, shown.stderr.strip()))
    try:
        released = json.loads(shown.stdout)
    except json.JSONDecodeError as error:
        raise ValueError('%s at %s is not valid JSON: %s' % (RELEASED_PROPERTIES_PATH, tag, error)) from error
    if not isinstance(released, dict) or 'version' not in released or not isinstance(released.get('properties'), list):
        raise ValueError('%s at %s has no version or properties' % (RELEASED_PROPERTIES_PATH, tag))
    try:
        version_tuple(released['version'])
    except ValueError as error:
        raise ValueError('%s at %s: %s' % (RELEASED_PROPERTIES_PATH, tag, error)) from error
    return tag, released


def properties_added_since_release(released_list, released_tag, module_version, properties):
    """Returns a message for each property that the latest release does not have, unless this module
    version is newer than that release and the property says so.

    An unrevisioned property is recorded as major.0. While the module is still that version, that
    equals the current version, so new_properties_without_revision() does not catch it. It is only
    wrong once that version has been released.
    """
    if not released_list:
        return []
    released_version = version_tuple(released_list['version'])
    released_names = {prop['name'] for prop in released_list['properties']}
    messages = []
    for prop in properties:
        if prop['name'] in released_names:
            continue
        if module_version <= released_version:
            messages.append('%s was added after Victron.Branding %s was released in %s, but the module version '
                            'is still %d.%d. Increase the minor version and set REVISION to that version.'
                            % (prop['name'], released_list['version'], released_tag,
                               module_version[0], module_version[1]))
        elif prop['since'] <= released_version:
            messages.append('%s was added after Victron.Branding %s was released in %s, but its version is %d.%d. '
                            'Set REVISION(%d, %d).'
                            % ((prop['name'], released_list['version'], released_tag) + prop['since'] + module_version))
    return messages


def generate_reference(properties, victron_colors):
    """Returns the property reference: the lines from DOCS_BEGIN to DOCS_END, ending with a newline."""
    lines = [DOCS_BEGIN]
    for prop in properties:
        lines += [
            '',
            '### `%s`' % prop['name'],
            '',
            prop['description'],
            '',
            '- Type: %s' % DOCS_TYPE_NAMES[prop['type']],
            '- Added in: %d.%d' % prop['since'],
            '- If not set: %s' % prop['if_not_set'],
        ]
        if prop['name'] in victron_colors:
            lines.append("- Victron's value: `%s`" % victron_colors[prop['name']])
    lines += ['', DOCS_END]
    return '\n'.join(lines) + '\n'


def replace_reference(docs_text, docs_path, reference):
    """Returns docs_text with its lines from DOCS_BEGIN to DOCS_END replaced by reference."""
    begin = docs_text.find(DOCS_BEGIN)
    end = docs_text.find(DOCS_END)
    if begin < 0 or end < begin or docs_text.find(DOCS_BEGIN, begin + 1) >= 0:
        raise ValueError('%s must contain these two lines once each, in this order:\n%s\n%s'
                         % (docs_path, DOCS_BEGIN, DOCS_END))
    end = docs_text.find('\n', end)
    end = len(docs_text) if end < 0 else end + 1
    return docs_text[:begin] + reference + docs_text[end:]


def read_text(path):
    try:
        with open(path, encoding='utf-8', newline='') as file:
            return file.read().replace('\r\n', '\n')
    except OSError:
        return None


def main():
    parser = argparse.ArgumentParser(description='Generates the Branding property list for the plugin compiler, '
                                                 'and the property reference')
    parser.add_argument('--header', default=DEFAULT_HEADER)
    parser.add_argument('--cmake-file', default=DEFAULT_CMAKE_FILE)
    parser.add_argument('--theme-dir', default=DEFAULT_THEME_DIR)
    parser.add_argument('--output', default=DEFAULT_OUTPUT)
    parser.add_argument('--docs', default=DEFAULT_DOCS)
    parser.add_argument('--check', action='store_true', help='Fail if an output file is out of date')
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
    # Not skipped by --allow-breaking-changes: that flag is for a property no released GUI has.
    # Claiming a new property was in a version that has already been tagged is the opposite.
    try:
        released_tag, released_list = read_released_branding_list(SOURCE_DIR)
        added_since_release = properties_added_since_release(
            released_list, released_tag, module_version, properties)
    except ValueError as error:
        print(error)
        return 1
    for message in added_since_release:
        print('%s: %s' % (args.header, message))
    if breaking or unversioned or added_since_release:
        return 1

    color_property_names = [prop['name'] for prop in properties if prop['type'] == 'color']
    victron_colors = read_victron_colors(args.theme_dir, color_property_names)
    current_docs = read_text(args.docs)
    if current_docs is None:
        print('Cannot read %s' % args.docs)
        return 1
    outputs = {
        args.output: generate_json(module_version, properties),
        args.docs: replace_reference(current_docs, args.docs, generate_reference(properties, victron_colors)),
    }

    if args.check:
        stale = [path for path, contents in outputs.items() if read_text(path) != contents]
        for path in stale:
            print('%s is out of date. Run tools/brandingproperties.py to regenerate it.' % path)
        if not stale:
            print('%s are up to date.' % ' and '.join(outputs))
        return 1 if stale else 0

    for path, contents in outputs.items():
        with open(path, 'w', encoding='utf-8', newline='\n') as file:
            file.write(contents)
    return 0


if __name__ == '__main__':
    sys.exit(main())
