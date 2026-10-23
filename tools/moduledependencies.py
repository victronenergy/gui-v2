#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Checks the rules on which Victron modules may use which (see "Module dependencies" in
# .github/architecture.md):
#  - Victron.VenusOS does not use Victron.GuiPlugins: none of its QML files imports it, its
#    qt_add_qml_module() does not list it in IMPORTS or DEPENDENCIES, none of its C++ files includes
#    a GuiPlugins header, and its library does not link the GuiPlugins library. (GuiPlugins uses
#    VenusOS, so the reverse would make a cycle.)
#  - Victron.Branding uses no other Victron module: no Victron QML import, no Victron entry in
#    IMPORTS or DEPENDENCIES, no include of another Victron module's header, and no Victron library
#    in its links. (Plugins compile against it alone.)
#  - No GuiPlugins header has the same file name as a VenusOS header, so that the include check
#    can tell them apart.
#
# A module's files are the .qml, .h, .hpp and .cpp files listed in the set() and list(APPEND) calls
# whose variable name starts with the module's target name and an underscore, for example
# VictronVenusOS_CPP_SOURCES, in CMakeLists.txt and cmake/*.cmake.
#
# Usage:
#   moduledependencies.py   exit non-zero, listing each problem, if a rule is broken

import argparse
import glob
import os
import re
import sys

SOURCE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

VENUSOS_TARGET = 'VictronVenusOS'
BRANDING_TARGET = 'VictronBranding'
GUIPLUGINS_TARGET = 'VictronGuiPlugins'
GUIPLUGINS_URI = 'Victron.GuiPlugins'

SOURCE_FILE_RE = re.compile(r'\.(qml|h|hpp|cpp)$')
HEADER_RE = re.compile(r'\.(h|hpp)$')
QML_IMPORT_RE = re.compile(r'^\s*import\s+([\w.]+)', re.MULTILINE)
INCLUDE_RE = re.compile(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]', re.MULTILINE)
CMAKE_COMMENT_RE = re.compile(r'#[^\n]*')
# The qt_add_qml_module() keywords that name other QML modules.
QML_MODULE_IMPORT_KEYWORDS = ('IMPORTS', 'OPTIONAL_IMPORTS', 'DEFAULT_IMPORTS', 'DEPENDENCIES')


def cmake_calls(text, command):
    """Returns the arguments of each call to command in the CMake text, as a list of lists of words."""
    text = CMAKE_COMMENT_RE.sub('', text)
    calls = []
    for match in re.finditer(r'\b%s\s*\(' % re.escape(command), text, re.IGNORECASE):
        depth = 1
        position = match.end()
        while position < len(text) and depth > 0:
            depth += {'(': 1, ')': -1}.get(text[position], 0)
            position += 1
        calls.append([word.strip('"') for word in text[match.end():position - 1].split()])
    return calls


def module_files(cmake_texts, target):
    """Returns the source files that the CMake texts list in variables named <target>_..., in order."""
    files = []
    for text in cmake_texts:
        calls = cmake_calls(text, 'set') + [args[1:] for args in cmake_calls(text, 'list')
                                            if args[:1] == ['APPEND']]
        for args in calls:
            if args and args[0].startswith(target + '_'):
                files += [word for word in args[1:] if SOURCE_FILE_RE.search(word) and word not in files]
    return files


def qml_module_imports(cmake_texts, target):
    """Returns the module names listed under the import keywords of qt_add_qml_module(target ...)."""
    names = []
    for text in cmake_texts:
        for args in cmake_calls(text, 'qt_add_qml_module'):
            if args[:1] != [target]:
                continue
            listing = False
            for word in args[1:]:
                if re.fullmatch(r'[A-Z_]+', word):
                    listing = word in QML_MODULE_IMPORT_KEYWORDS
                elif listing:
                    # An import can carry a version: Victron.GuiPlugins/1.0 or Victron.GuiPlugins/auto.
                    names.append(word.split('/')[0])
    return names


def linked_libraries(cmake_texts, target):
    """Returns the libraries named in target_link_libraries(target ...) calls."""
    libraries = []
    for text in cmake_texts:
        for args in cmake_calls(text, 'target_link_libraries'):
            if args[:1] == [target]:
                libraries += [word for word in args[1:] if word not in ('PUBLIC', 'PRIVATE', 'INTERFACE')]
    return libraries


def includes(text):
    return INCLUDE_RE.findall(text)


def qml_imports(text):
    return QML_IMPORT_RE.findall(text)


def check(read_file, cmake_paths):
    """Returns a message for each broken rule. read_file(path) returns the text of the file at path,
    relative to the source directory, or None if there is none. cmake_paths are the CMake files.
    """
    cmake_texts = [read_file(path) or '' for path in cmake_paths]
    venus_files = module_files(cmake_texts, VENUSOS_TARGET)
    branding_files = module_files(cmake_texts, BRANDING_TARGET)
    guiplugins_headers = {os.path.basename(path): path for path in module_files(cmake_texts, GUIPLUGINS_TARGET)
                          if HEADER_RE.search(path)}
    branding_headers = {os.path.basename(path) for path in branding_files if HEADER_RE.search(path)}
    # The headers of every other module, including the veutil ones in VEUTIL_* variables.
    other_headers = set()
    for text in cmake_texts:
        for args in cmake_calls(text, 'set') + cmake_calls(text, 'list'):
            other_headers |= {os.path.basename(word) for word in args[1:] if HEADER_RE.search(word)}
    other_headers -= branding_headers

    problems = []

    for path in venus_files:
        text = read_file(path) or ''
        if path.endswith('.qml'):
            if GUIPLUGINS_URI in qml_imports(text):
                problems.append('%s imports %s. Victron.VenusOS must not use it.' % (path, GUIPLUGINS_URI))
        else:
            for name in includes(text):
                header = guiplugins_headers.get(os.path.basename(name))
                if header:
                    problems.append('%s includes %s, from %s. Victron.VenusOS must not use it.'
                                    % (path, header, GUIPLUGINS_URI))
    if GUIPLUGINS_URI in qml_module_imports(cmake_texts, VENUSOS_TARGET):
        problems.append('qt_add_qml_module(%s) lists %s. Victron.VenusOS must not use it.'
                        % (VENUSOS_TARGET, GUIPLUGINS_URI))
    for library in linked_libraries(cmake_texts, VENUSOS_TARGET):
        if library.startswith(GUIPLUGINS_TARGET):
            problems.append('%s links %s. Victron.VenusOS must not use %s.'
                            % (VENUSOS_TARGET, library, GUIPLUGINS_URI))

    for path in branding_files:
        text = read_file(path) or ''
        if path.endswith('.qml'):
            for name in qml_imports(text):
                if name.startswith('Victron.') and name != 'Victron.Branding':
                    problems.append('%s imports %s. Victron.Branding must not use another Victron module.'
                                    % (path, name))
        else:
            for name in includes(text):
                basename = os.path.basename(name)
                if basename not in branding_headers and basename in other_headers:
                    problems.append('%s includes %s, from another Victron module. Victron.Branding must not '
                                    'use one.' % (path, name))
    for name in qml_module_imports(cmake_texts, BRANDING_TARGET):
        if name.startswith('Victron.'):
            problems.append('qt_add_qml_module(%s) lists %s. Victron.Branding must not use another Victron '
                            'module.' % (BRANDING_TARGET, name))
    for library in linked_libraries(cmake_texts, BRANDING_TARGET):
        if library.startswith('Victron'):
            problems.append('%s links %s. Victron.Branding must not use another Victron module.'
                            % (BRANDING_TARGET, library))

    for path in venus_files:
        header = guiplugins_headers.get(os.path.basename(path))
        if header and HEADER_RE.search(path):
            problems.append('%s and %s have the same file name. Rename one, so that an include of it shows '
                            'which module it is from.' % (path, header))

    return problems


def check_source_dir(source_dir):
    """Returns a message for each broken rule in the source tree at source_dir."""
    def read_file(path):
        try:
            with open(os.path.join(source_dir, path), encoding='utf-8') as file:
                return file.read()
        except OSError:
            return None

    cmake_paths = ['CMakeLists.txt'] + sorted('cmake/' + os.path.basename(path)
                                              for path in glob.glob(os.path.join(source_dir, 'cmake', '*.cmake')))
    return check(read_file, cmake_paths)


def main():
    parser = argparse.ArgumentParser(description='Checks which Victron modules use which')
    parser.add_argument('--source-dir', default=SOURCE_DIR)
    args = parser.parse_args()

    problems = check_source_dir(args.source_dir)
    for problem in problems:
        print(problem)
    if not problems:
        print('The Victron modules follow the dependency rules.')
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
