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
# An import or include inside a comment or a string is not a use. The scan ignores those, and
# still sees a real import after a string that contains a comment marker. An escaped backtick
# does not end a template literal. A comment before or inside a directive is whitespace, so the
# directive is still seen. A C++ digit separator is not a character literal, including in a
# 0b literal. A CMake bracket comment is not a call, and neither is a command written inside a
# quoted or bracket argument.
#
# Usage:
#   moduledependencies.py   exit non-zero, listing each problem, if a rule is broken.
#   A --source-dir with no CMakeLists.txt is a problem too. Otherwise a missing
#   tree would pass, because no module files would be found.

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
# The qt_add_qml_module() keywords that name other QML modules.
QML_MODULE_IMPORT_KEYWORDS = ('IMPORTS', 'OPTIONAL_IMPORTS', 'DEFAULT_IMPORTS', 'DEPENDENCIES')


def _cmake_quoted_end(text, start):
    """Returns the index after a CMake quoted argument at start, or None if it is not closed."""
    position = start + 1
    length = len(text)
    while position < length:
        if text[position] == '\\' and position + 1 < length:
            position += 2
            continue
        if text[position] == '"':
            return position + 1
        position += 1
    return None


def _cmake_bracket_end(text, start):
    """Returns the index after a bracket argument at start, or None if start is not a closed one.

    start points at the opening [. The closer is ]=*] with the same number of = signs. An unclosed
    bracket is not a comment here, so a call after a missing closer is still found.
    """
    if start >= len(text) or text[start] != '[':
        return None
    equals = 0
    position = start + 1
    while position < len(text) and text[position] == '=':
        equals += 1
        position += 1
    if position >= len(text) or text[position] != '[':
        return None
    close = ']' + ('=' * equals) + ']'
    end = text.find(close, position + 1)
    if end < 0:
        return None
    return end + len(close)


def _strip_cmake_comments(text):
    """Returns text with CMake comments removed. Quoted arguments are left as written.

    A bracket comment is # immediately followed by [[=*[ ... ]=*]]. Any other # removes the rest
    of that line. A # inside a quoted argument does not start a comment.
    """
    parts = []
    position = 0
    length = len(text)
    while position < length:
        if text[position] == '"':
            end = _cmake_quoted_end(text, position)
            if end is None:
                parts.append(text[position:])
                break
            parts.append(text[position:end])
            position = end
            continue
        if text[position] == '#':
            end = _cmake_bracket_end(text, position + 1)
            if end is not None:
                parts.append(' ')
                position = end
                continue
            newline = text.find('\n', position)
            if newline < 0:
                break
            position = newline
            continue
        parts.append(text[position])
        position += 1
    return ''.join(parts)


def _cmake_argument_spans(text):
    """Returns [start, end) of each quoted or closed bracket argument.

    A command or parenthesis inside one is text, not CMake syntax. An unclosed quote runs to the
    end of the text. An unclosed bracket is not an argument, so a call after a missing closer is
    still found.
    """
    spans = []
    position = 0
    length = len(text)
    while position < length:
        if text[position] == '"':
            end = _cmake_quoted_end(text, position)
            if end is None:
                spans.append((position, length))
                break
            spans.append((position, end))
            position = end
            continue
        if text[position] == '[':
            end = _cmake_bracket_end(text, position)
            if end is not None:
                spans.append((position, end))
                position = end
                continue
        position += 1
    return spans


def _span_end_at(spans, position):
    """Returns the end of the argument span that starts at position, or None."""
    for start, end in spans:
        if start == position:
            return end
        if start > position:
            break
    return None


def _in_argument(spans, position):
    """True if position is inside a quoted or bracket argument."""
    return any(start <= position < end for start, end in spans)


def cmake_calls(text, command):
    """Returns the arguments of each call to command in the CMake text, as a list of lists of words.

    Command text inside a quoted or bracket argument is not a call. A parenthesis inside one does
    not end the call, so a library named after it is still seen.
    """
    text = _strip_cmake_comments(text)
    spans = _cmake_argument_spans(text)
    calls = []
    for match in re.finditer(r'\b%s\s*\(' % re.escape(command), text, re.IGNORECASE):
        if _in_argument(spans, match.start()):
            continue
        depth = 1
        position = match.end()
        while position < len(text) and depth > 0:
            span_end = _span_end_at(spans, position)
            if span_end is not None:
                position = span_end
                continue
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


def _raw_string_end(text, start):
    """Returns the index after a C++ raw string at start, or None if text[start:] is not one."""
    if text.startswith('u8R"', start):
        prefix = 3
    elif text.startswith(('uR"', 'UR"', 'LR"'), start):
        prefix = 2
    elif text.startswith('R"', start):
        prefix = 1
    else:
        return None
    if start > 0 and (text[start - 1].isalnum() or text[start - 1] == '_'):
        return None
    delimiter_start = start + prefix + 1
    paren = text.find('(', delimiter_start)
    # A raw-string delimiter is at most 16 characters, and cannot contain whitespace or parentheses.
    if paren < 0 or paren - delimiter_start > 16:
        return None
    delimiter = text[delimiter_start:paren]
    if any(char.isspace() or char in '()\\' for char in delimiter):
        return None
    end = text.find(')' + delimiter + '"', paren + 1)
    if end < 0:
        return None
    return end + len(delimiter) + 2


def _quoted_end(text, start):
    """Returns the index after a quoted string at start, or None if it is not closed on this line.

    A template literal (`) may cover more than one line. A backslash escapes the next character,
    including a backtick, so \\` does not end it. An unclosed string is left as code, so that a
    real import after it is still found.
    """
    quote = text[start]
    position = start + 1
    while position < len(text):
        if text[position] == '\\' and position + 1 < len(text):
            position += 2
            continue
        if text[position] == quote:
            return position + 1
        if text[position] == '\n' and quote != '`':
            return None
        position += 1
    return None


def _is_char_literal_prefix(text, position):
    """True if an encoding prefix (L, u, U, or u8) is the token immediately before position."""
    for prefix in ('u8', 'u', 'U', 'L'):
        start = position - len(prefix)
        if start < 0 or text[start:position] != prefix:
            continue
        if start == 0 or not (text[start - 1].isalnum() or text[start - 1] == '_'):
            return True
    return False


def _is_hex_digit(char):
    return char.isdigit() or char in 'abcdefABCDEF'


def _is_binary_digit(char):
    return char in '01'


def _is_digit_separator(text, position):
    """True if the apostrophe at position is a C++ digit separator, not a character literal.

    1'000, 0xFF'AA and 0b1010'0001 are separators. u8'1' is a character literal even though a digit
    precedes the quote, and digits at the end of an identifier are not a number.
    """
    if position == 0 or position + 1 >= len(text) or _is_char_literal_prefix(text, position):
        return False
    before = text[position - 1]
    after = text[position + 1]
    if before.isdigit() and after.isdigit() and _in_decimal_literal(text, position):
        return True
    return _is_hex_digit(before) and _is_hex_digit(after) and _in_base_prefixed_literal(text, position)


def _in_decimal_literal(text, quote):
    """True if the apostrophe at quote sits in a decimal or floating literal, not an identifier."""
    index = quote - 1
    saw_digit = False
    while index >= 0:
        char = text[index]
        if char.isdigit() or char == "'":
            saw_digit = saw_digit or char.isdigit()
            index -= 1
            continue
        if char == '.':
            index -= 1
            if index >= 0 and text[index].isdigit():
                continue
            break
        if char in '+-' and index > 0 and text[index - 1] in 'eEpP':
            index -= 1
            continue
        if char in 'eEpP' and index > 0 and (text[index - 1].isdigit() or text[index - 1] == '.'):
            saw_digit = True
            index -= 1
            continue
        break
    if not saw_digit:
        return False
    start = index + 1
    # Digits that continue an identifier, as in xu8'1', are not a numeric literal. A leading dot
    # is: foo.5'0 is the literal .5'0.
    if text[start].isdigit() and start > 0 and (text[start - 1].isalnum() or text[start - 1] == '_'):
        return False
    return text[start].isdigit() or text[start] == '.'


def _in_prefixed_literal(text, quote, letters, is_digit):
    """True if the apostrophe at quote sits in a 0<letter> literal whose digits pass is_digit."""
    index = quote - 1
    while index >= 0 and (is_digit(text[index]) or text[index] == "'"):
        index -= 1
    if index < 1 or text[index] not in letters or text[index - 1] != '0':
        return False
    prefix = index - 1
    return prefix == 0 or not (text[prefix - 1].isalnum() or text[prefix - 1] == '_')


def _in_base_prefixed_literal(text, quote):
    """True if the apostrophe at quote sits in a 0x or 0b literal.

    The prefixes are recognized separately. A hex walk would consume the b of a 0b prefix, because
    b is a hex digit, and the separator would look like a character literal. A b inside a hex
    literal, as in 0x0b'11, is still a hex digit.
    """
    return (_in_prefixed_literal(text, quote, 'bB', _is_binary_digit)
            or _in_prefixed_literal(text, quote, 'xX', _is_hex_digit))


def code_mask(text):
    """Returns a string of the same length: '1' where text is code, 'c' in a comment, '0' in a string.

    An unclosed comment or string is treated as code from there on, so a real import after it is
    still found. A C++ digit separator is code, so it does not stop that masking.
    """
    mask = []
    position = 0
    length = len(text)
    while position < length:
        if text.startswith('//', position):
            end = text.find('\n', position)
            if end < 0:
                mask.append('c' * (length - position))
                break
            mask.append('c' * (end - position))
            position = end
            continue
        if text.startswith('/*', position):
            end = text.find('*/', position + 2)
            if end < 0:
                mask.append('1' * (length - position))
                break
            mask.append('c' * (end + 2 - position))
            position = end + 2
            continue
        raw_end = _raw_string_end(text, position)
        if raw_end is not None:
            mask.append('0' * (raw_end - position))
            position = raw_end
            continue
        if text[position] == "'" and _is_digit_separator(text, position):
            mask.append('1')
            position += 1
            continue
        if text[position] in '"\'`':
            quoted_end = _quoted_end(text, position)
            if quoted_end is None:
                mask.append('1' * (length - position))
                break
            mask.append('0' * (quoted_end - position))
            position = quoted_end
            continue
        mask.append('1')
        position += 1
    return ''.join(mask)


def _matches_in_code(pattern, text):
    """Returns the first groups of pattern matches that start in code.

    Comments are spaces here, newlines kept, so a comment before or inside a directive is
    whitespace. Quoted text is unchanged, and a match that starts in a string is ignored.
    """
    mask = code_mask(text)
    normalized = ''.join(' ' if mask[index] == 'c' and char != '\n' else char
                         for index, char in enumerate(text))
    found = []
    for match in pattern.finditer(normalized):
        # Leading comments are spaces, so the match can start in one. The directive itself must
        # be code: an include written inside a string still starts in that string.
        token = match.start()
        while token < match.end() and normalized[token].isspace():
            token += 1
        if token < len(mask) and mask[token] == '1':
            found.append(match.group(1))
    return found


def includes(text):
    return _matches_in_code(INCLUDE_RE, text)


def qml_imports(text):
    return _matches_in_code(QML_IMPORT_RE, text)


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
    """Returns a message for each broken rule in the source tree at source_dir.

    A source directory with no CMakeLists.txt is itself a problem. Reading it as
    empty would find no module files, and a missing tree would pass.
    """
    def read_file(path):
        try:
            with open(os.path.join(source_dir, path), encoding='utf-8') as file:
                return file.read()
        except OSError:
            return None

    if read_file('CMakeLists.txt') is None:
        return ['No CMakeLists.txt in %s. The module files cannot be found.' % source_dir]

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
