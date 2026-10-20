#!/usr/bin/env python3
#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Writes tools/guiplugins-api.json: the checked-in record of the Victron.GuiPlugins API. It lists
# every type that plugins can use, and each type's properties, signals, methods and enums, with the
# module version that added each one. It also writes those versions into the type reference in
# .github/gui-plugins.md, between the BEGIN and END lines below. The script reads them from the
# module's source files (the
# files in the VictronGuiPlugins_... variables in cmake/), and the module version from
# cmake/ModuleGuiPlugins.cmake:
#  - a QML file's API is its root type, and the property, signal, function and enum declarations
#    directly inside its root object. The rest of the file (child objects, ids and bindings) is
#    hidden from plugins;
#  - a C++ header's API is the class or namespace that it registers with QML_ELEMENT or
#    QML_NAMED_ELEMENT: its Q_PROPERTY, Q_INVOKABLE, signal and Q_ENUM declarations.
#
# A plugin built for one version must keep working with each later version that has the same major
# version. So the script refuses a change that would break such a plugin, such as removing a member
# or changing its type, unless the major version goes up (see --allow-breaking-changes). It also
# refuses a type that plugins cannot use, such as a Victron.VenusOS type, anywhere in the API.
#
# It cannot see a change to a property's initial value, or to what a function does. Those can still
# break a plugin, and they need a new major version too.
#
# A member that the record does not have yet gets the current module version. Increase
# VICTRON_GUIPLUGINS_VERSION_MINOR before adding to the API. If it is not already higher than the
# version in the record, the script refuses to write the record, and prints what to do.
#
# The plugin compiler, gui-v2-plugin-compiler.py, reads the record (installed next to it) to work
# out a plugin's requiredGuiPluginsVersion.
#
# Usage:
#   guipluginsapi.py           regenerate the record and the list of versions
#   guipluginsapi.py --check   exit non-zero if either is out of date, if the sources break the record,
#                              or if a new member would be saved without a newer module version

import argparse
import glob
import json
import os
import re
import sys

from moduledependencies import module_files

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.dirname(TOOLS_DIR)
DEFAULT_OUTPUT = os.path.join(TOOLS_DIR, 'guiplugins-api.json')
DEFAULT_DOCS = os.path.join(SOURCE_DIR, '.github', 'gui-plugins.md')
MODULE_CMAKE_FILE = 'cmake/ModuleGuiPlugins.cmake'
MODULE_TARGET = 'VictronGuiPlugins'
MODULE_URI = 'Victron.GuiPlugins'

# The list of versions in the type reference in .github/gui-plugins.md is between these two lines.
DOCS_BEGIN = ('<!-- BEGIN versions. tools/guipluginsapi.py writes this part from tools/guiplugins-api.json: '
              'do not edit it. -->')
DOCS_END = '<!-- END versions -->'

# Besides its own types, the API may use only QML's basic types and these Qt types, because plugins
# import only Victron.GuiPlugins, QtQml and QtQuick.
BASIC_TYPES = {'bool', 'int', 'real', 'string', 'url', 'color', 'var', 'date', 'point', 'size', 'rect', 'void',
               'alias'}
QT_TYPES = {'QtObject', 'Item', 'FocusScope', 'Component'}

QML_TYPE_NAMES = {'double': 'real', 'variant': 'var'}
CPP_TYPE_NAMES = {
    'QString': 'string',
    'QVariant': 'var',
    'QJSValue': 'var',
    'QUrl': 'url',
    'QColor': 'color',
    'bool': 'bool',
    'int': 'int',
    'double': 'real',
    'qreal': 'real',
    'float': 'real',
    'QStringList': 'list<string>',
    'QVariantList': 'list<var>',
    'QDateTime': 'date',
    'QPointF': 'point',
    'QSizeF': 'size',
    'QRectF': 'rect',
    'void': 'void',
    'QObject': 'QtObject',
    'QQuickItem': 'Item',
}
CPP_NAMESPACE_PREFIX = 'Victron::GuiPlugins::'

QML_ROOT_RE = re.compile(r'([A-Z][\w.]*)\s*\{')
# A line that starts with one of these words, then a name, declares a member.
QML_DECLARATION_RE = re.compile(r'(property|readonly|required|default|signal|function|enum|component)\s+\w')
QML_PROPERTY_RE = re.compile(r'((?:(?:default|required|readonly)\s+)*)property\s+([\w.]+(?:<[\w.]+>)?)\s+(\w+)'
                             r'\s*(?::|;|$)')
QML_SIGNAL_RE = re.compile(r'signal\s+(\w+)\s*(?:\(([^()]*)\))?\s*;?$')
QML_FUNCTION_RE = re.compile(r'function\s+(\w+)\s*\(([^()]*)\)\s*(?::\s*([\w.]+(?:<[\w.]+>)?)\s*)?\{')
QML_ENUM_RE = re.compile(r'enum\s+(\w+)\s*\{')
QML_COMPONENT_RE = re.compile(r'component\s+(\w+)')

QML_MACRO_RE = re.compile(r'\b(QML_\w+)\b(?:\s*\(([^)]*)\))?')
SUPPORTED_QML_MACROS = ('QML_ELEMENT', 'QML_NAMED_ELEMENT', 'QML_SINGLETON', 'QML_UNCREATABLE')
CPP_SCOPE_RE = re.compile(r'\b(?:(?:class|struct)\s+(?:\w+\s+)*?(\w+)\s*(?:final\s*)?(?::([^{;]*))?'
                          r'|namespace\s+(\w+)\s*)\{')
Q_PROPERTY_KEYWORDS = {'READ', 'WRITE', 'MEMBER', 'RESET', 'NOTIFY', 'REVISION', 'DESIGNABLE', 'SCRIPTABLE',
                       'STORED', 'USER', 'BINDABLE', 'CONSTANT', 'FINAL', 'REQUIRED', 'VIRTUAL', 'OVERRIDE'}
CPP_SECTION_RE = re.compile(r'\b(?:(?:public|protected|private)\s*(Q_SLOTS|slots)?|(Q_SIGNALS|signals)'
                            r'|(Q_SLOTS|slots))\s*:(?!:)')
CPP_INVOKABLE_RE = re.compile(r'Q_INVOKABLE\s+([^;{}()]*?)\s*\b(\w+)\s*\(([^()]*)\)')
CPP_SIGNAL_RE = re.compile(r'void\s+(\w+)\s*\(([^()]*)\)')
ENUM_VALUE_RE = re.compile(r'(\w+)(?:\s*=\s*(-?(?:0[xX][0-9a-fA-F]+|\d+)))?')


def strip_comments(text, path, keep_strings):
    """Returns text without its comments, and also without the contents of its string literals unless
    keep_strings. A comment becomes a space and the line breaks that it had, so that each line stays
    on the same line number."""
    parts = []
    position = 0
    length = len(text)
    while position < length:
        char = text[position]
        if text.startswith('//', position):
            end = text.find('\n', position)
            position = length if end < 0 else end
        elif text.startswith('/*', position):
            end = text.find('*/', position + 2)
            if end < 0:
                raise ValueError('%s: a /* comment is not closed' % path)
            parts.append(' ' + '\n' * text.count('\n', position, end))
            position = end + 2
        elif char in '"\'`':
            end = position + 1
            while end < length and text[end] != char:
                end += 2 if text[end] == '\\' else 1
            if end >= length:
                raise ValueError('%s: a string is not closed' % path)
            contents = text[position + 1:end]
            parts.append(char + (contents if keep_strings else '\n' * contents.count('\n')) + char)
            position = end + 1
        else:
            parts.append(char)
            position += 1
    return ''.join(parts)


def cpp_type_name(cpp_type):
    """Returns the QML name of a C++ type, or the C++ name (without the Victron::GuiPlugins:: prefix)
    if it has no QML name."""
    name = ' '.join(re.sub(r'\bconst\b|[&*]', ' ', cpp_type).split()).replace(CPP_NAMESPACE_PREFIX, '')
    match = re.fullmatch(r'(?:QList|QVector|QQmlListProperty)\s*<(.+)>', name)
    if match:
        return 'list<%s>' % cpp_type_name(match.group(1))
    return CPP_TYPE_NAMES.get(name, name.replace('::', '.'))


def qml_type_name(qml_type):
    match = re.fullmatch(r'list<(.+)>', qml_type)
    if match:
        return 'list<%s>' % qml_type_name(match.group(1))
    return QML_TYPE_NAMES.get(qml_type, qml_type)


def parse_parameters(text, path, where, cpp):
    """Returns the parameters in text (the part between a declaration's parentheses), each as a
    "name: type" string, or as "name" for a QML parameter without a type."""
    text = text.strip()
    if text in ('', 'void'):
        return []
    parameters = []
    for part in text.split(','):
        part = part.split('=')[0].strip()
        name = type_name = None
        if cpp:
            match = re.search(r'(\w+)$', part)
            if match and part[:match.start()].strip():
                name, type_name = match.group(1), cpp_type_name(part[:match.start()])
        else:
            match = (re.fullmatch(r'(\w+)\s*:\s*([\w.]+(?:<[\w.]+>)?)', part)
                     or re.fullmatch(r'(\w+)', part))
            if match:
                name, type_name = match.group(1), match.group(2) if match.lastindex == 2 else None
            else:
                match = re.fullmatch(r'([\w.]+(?:<[\w.]+>)?)\s+(\w+)', part)
                if match:
                    name, type_name = match.group(2), match.group(1)
            if type_name:
                type_name = qml_type_name(type_name)
        if name is None:
            raise ValueError('%s: %s: cannot read the parameter "%s". Give it a name and a type.' % (path, where, part))
        parameters.append('%s: %s' % (name, type_name) if type_name else name)
    return parameters


def parse_enum_values(body, path, enum_name):
    values = []
    next_value = 0
    for part in body.split(','):
        part = part.strip()
        if not part:
            continue
        match = ENUM_VALUE_RE.fullmatch(part)
        if not match:
            raise ValueError('%s: enum %s: cannot read "%s". Give each value a name, and if needed "= <whole number>".'
                             % (path, enum_name, part))
        number = match.group(2)
        value = next_value if number is None else int(number, 16 if number.lower().lstrip('-').startswith('0x')
                                                      else 10)
        values.append({'name': match.group(1), 'value': value})
        next_value = value + 1
    if not values:
        raise ValueError('%s: enum %s has no values' % (path, enum_name))
    return values


def new_type(name, kind, base):
    api_type = {'name': name, 'kind': kind}
    if base is not None:
        api_type['base'] = base
    api_type.update({'properties': [], 'signals': [], 'methods': [], 'enums': []})
    return api_type


def finish_type(api_type, path):
    """Sorts the members of api_type by name (but keeps enum values in order), checks that no name is
    used twice, and drops the empty lists."""
    for section in ('properties', 'signals', 'methods', 'enums'):
        names = [member['name'] for member in api_type[section]]
        twice = sorted({name for name in names if names.count(name) > 1})
        if twice:
            raise ValueError('%s: %s declares %s more than once. Overloads are not supported in the plugin API.'
                             % (path, api_type['name'], ', '.join(twice)))
        api_type[section].sort(key=lambda member: member['name'])
        if not api_type[section]:
            del api_type[section]
    return api_type


def parse_qml_type(name, text, path):
    """Returns the API of the QML type called name, whose file at path has the given text."""
    text = strip_comments(text, path, keep_strings=False)
    singleton = False
    root = None
    members = {'properties': [], 'signals': [], 'methods': [], 'enums': []}
    depth = 0
    position = 0
    for line in text.split('\n'):
        stripped = line.strip()
        if stripped and depth == 0:
            if re.fullmatch(r'pragma\s+Singleton\s*;?', stripped):
                singleton = True
            elif not re.match(r'(import|pragma)\s', stripped):
                match = QML_ROOT_RE.match(stripped)
                if not match or root is not None:
                    raise ValueError('%s: cannot read this line outside the root object: %s' % (path, stripped))
                root = match.group(1)
        elif stripped and depth == 1 and QML_DECLARATION_RE.match(stripped):
            parse_qml_declaration(stripped, text, position + line.index(stripped), members, path)
        depth += line.count('{') - line.count('}')
        if depth < 0:
            raise ValueError('%s: has a } that closes nothing' % path)
        position += len(line) + 1
    if root is None:
        raise ValueError('%s: has no root object' % path)
    api_type = new_type(name, 'singleton' if singleton else 'object', root)
    api_type.update(members)
    return finish_type(api_type, path)


def parse_qml_declaration(line, text, position, members, path):
    """Adds the member that line declares to members. position is where line starts in text."""
    match = QML_PROPERTY_RE.match(line)
    if match:
        prop = {'name': match.group(3), 'type': qml_type_name(match.group(2))}
        for flag in ('readonly', 'required', 'default'):
            if flag in match.group(1).split():
                prop[flag] = True
        members['properties'].append(prop)
        return
    match = QML_SIGNAL_RE.match(line)
    if match:
        members['signals'].append({
            'name': match.group(1),
            'parameters': parse_parameters(match.group(2) or '', path, 'signal ' + match.group(1), cpp=False),
        })
        return
    match = QML_FUNCTION_RE.match(line)
    if match:
        method = {
            'name': match.group(1),
            'parameters': parse_parameters(match.group(2), path, 'function ' + match.group(1), cpp=False),
        }
        if match.group(3):
            method['returns'] = qml_type_name(match.group(3))
        members['methods'].append(method)
        return
    match = QML_ENUM_RE.match(line)
    if match:
        start = position + match.end()
        end = text.find('}', start)
        if end < 0:
            raise ValueError('%s: enum %s is not closed' % (path, match.group(1)))
        members['enums'].append({'name': match.group(1),
                                 'values': parse_enum_values(text[start:end], path, match.group(1))})
        return
    match = QML_COMPONENT_RE.match(line)
    if match:
        raise ValueError('%s: inline component %s: plugins could use it, but this script cannot record it. Put it '
                         'in its own file instead.' % (path, match.group(1)))
    raise ValueError('%s: cannot read this declaration. Write its first line as "[readonly|required|default] '
                     'property <type> <name>", "signal <name>(<parameters>)", "function <name>(<parameters>) {" '
                     'or "enum <name> {": %s' % (path, line))


def matching_brace(text, start, path):
    """Returns the position of the } that closes the { at start."""
    depth = 0
    for position in range(start, len(text)):
        if text[position] == '{':
            depth += 1
        elif text[position] == '}':
            depth -= 1
            if depth == 0:
                return position
    raise ValueError('%s: a { is not closed' % path)


def parse_cpp_types(text, path):
    """Returns the API of the QML type that the C++ header at path registers, as a list of one type,
    or an empty list if the header registers none."""
    text = strip_comments(text, path, keep_strings=True)
    macros = list(QML_MACRO_RE.finditer(text))
    if not macros:
        return []
    for macro in macros:
        if macro.group(1) not in SUPPORTED_QML_MACROS:
            raise ValueError('%s: tools/guipluginsapi.py does not support %s, so the API record would miss what it '
                             'adds. Add support for it there first.' % (path, macro.group(1)))
    elements = [macro for macro in macros if macro.group(1) in ('QML_ELEMENT', 'QML_NAMED_ELEMENT')]
    if len(elements) != 1:
        raise ValueError('%s: register exactly one QML type in each header, with QML_ELEMENT or QML_NAMED_ELEMENT'
                         % path)
    element = elements[0]
    scopes = [scope for scope in CPP_SCOPE_RE.finditer(text) if scope.end() <= element.start()]
    if not scopes:
        raise ValueError('%s: %s is not inside a class or namespace' % (path, element.group(1)))
    scope = scopes[-1]
    body = text[scope.end():matching_brace(text, scope.end() - 1, path)]
    macro_names = [macro.group(1) for macro in macros]
    if scope.group(3):
        name, kind, base = scope.group(3), 'namespace', None
    else:
        name = scope.group(1)
        kind = ('singleton' if 'QML_SINGLETON' in macro_names
                else 'uncreatable' if 'QML_UNCREATABLE' in macro_names
                else 'object')
        bases = (scope.group(2) or '').split(',')[0].split()
        bases = [word for word in bases if word not in ('public', 'protected', 'private', 'virtual')]
        base = cpp_type_name(bases[0]) if bases else None
        if base is None:
            raise ValueError('%s: %s has no base class. QML types derive from QObject.' % (path, name))
    if element.group(1) == 'QML_NAMED_ELEMENT':
        name = (element.group(2) or '').strip()
    api_type = new_type(name, kind, base)

    for line in body.split('\n'):
        if 'Q_PROPERTY' in line:
            api_type['properties'].append(parse_cpp_property(line, path))
    default = re.search(r'\bQ_CLASSINFO\(\s*"DefaultProperty"\s*,\s*"(\w+)"\s*\)', body)
    if default:
        prop = next((prop for prop in api_type['properties'] if prop['name'] == default.group(1)), None)
        if prop is None:
            raise ValueError('%s: the DefaultProperty %s is not a Q_PROPERTY' % (path, default.group(1)))
        prop['default'] = True

    invokables = list(re.finditer(r'\bQ_INVOKABLE\b', body))
    for invokable in invokables:
        match = CPP_INVOKABLE_RE.match(body, invokable.start())
        if not match:
            raise ValueError('%s: write each Q_INVOKABLE as "Q_INVOKABLE <return type> <name>(<parameters>)", '
                             'without parentheses in its parameters' % path)
        returns = ' '.join(word for word in match.group(1).split() if word not in ('virtual', 'static', 'inline'))
        api_type['methods'].append({
            'name': match.group(2),
            'parameters': parse_parameters(match.group(3), path, match.group(2), cpp=True),
            'returns': cpp_type_name(returns),
        })

    sections = list(CPP_SECTION_RE.finditer(body))
    for index, section in enumerate(sections):
        if section.group(1) or section.group(3):
            raise ValueError('%s: %s has slots. Use Q_INVOKABLE for the methods that plugins can call.' % (path, name))
        if not section.group(2):
            continue
        end = sections[index + 1].start() if index + 1 < len(sections) else len(body)
        for statement in body[section.end():end].split(';'):
            statement = statement.strip()
            if not statement:
                continue
            match = CPP_SIGNAL_RE.fullmatch(statement)
            if not match:
                raise ValueError('%s: cannot read the signal "%s". Write it as "void <name>(<parameters>);".'
                                 % (path, ' '.join(statement.split())))
            api_type['signals'].append({
                'name': match.group(1),
                'parameters': parse_parameters(match.group(2), path, 'signal ' + match.group(1), cpp=True),
            })

    if re.search(r'\bQ_FLAGS?(_NS)?\b', body):
        raise ValueError('%s: tools/guipluginsapi.py does not support Q_FLAG. Add support for it there first.' % path)
    for registration in re.finditer(r'\bQ_ENUM(?:_NS)?\s*\(\s*(\w+)\s*\)', body):
        enum_name = registration.group(1)
        enum = re.search(r'\benum\s+(?:class\s+)?%s\s*(?::\s*[\w:]+\s*)?\{([^}]*)\}' % enum_name, body)
        if not enum:
            raise ValueError('%s: cannot find the enum %s' % (path, enum_name))
        api_type['enums'].append({'name': enum_name, 'values': parse_enum_values(enum.group(1), path, enum_name)})

    return [finish_type(api_type, path)]


def parse_cpp_property(line, path):
    match = re.search(r'\bQ_PROPERTY\((.*)\)\s*;?\s*$', line)
    words = match.group(1).split() if match else []
    keyword = next((index for index, word in enumerate(words) if word in Q_PROPERTY_KEYWORDS), None)
    declaration = ' '.join(words[:keyword]) if keyword else ''
    name = re.search(r'(\w+)$', declaration)
    if not name or not declaration[:name.start()].strip():
        raise ValueError('%s: write each Q_PROPERTY on one line, as "Q_PROPERTY(<type> <name> READ ...)": %s'
                         % (path, line.strip()))
    keywords = set(words[keyword:])
    prop = {'name': name.group(1), 'type': cpp_type_name(declaration[:name.start()])}
    if ('WRITE' not in keywords and 'MEMBER' not in keywords) or 'CONSTANT' in keywords:
        prop['readonly'] = True
    if 'REQUIRED' in keywords:
        prop['required'] = True
    return prop


def read_types(read_file, files):
    """Returns the API types in files, sorted by name. read_file(path) returns the text of a file, or
    None if it cannot be read."""
    types = []
    for path in files:
        text = read_file(path)
        if text is None:
            raise ValueError('%s: cannot read this file' % path)
        if path.endswith('.qml'):
            types.append(parse_qml_type(os.path.splitext(os.path.basename(path))[0], text, path))
        elif re.search(r'\.(h|hpp)$', path):
            types += parse_cpp_types(text, path)
    names = [api_type['name'] for api_type in types]
    twice = sorted({name for name in names if names.count(name) > 1})
    if twice:
        raise ValueError('%s is declared more than once in %s' % (', '.join(twice), MODULE_URI))
    return sorted(types, key=lambda api_type: api_type['name'])


def parse_module_version(cmake_text, path):
    """Returns (major, minor) from the VICTRON_GUIPLUGINS_VERSION_* lines of cmake_text."""
    version = []
    for part in ('MAJOR', 'MINOR'):
        match = re.search(r'set\(VICTRON_GUIPLUGINS_VERSION_%s\s+(\d+)\)' % part, cmake_text)
        if not match:
            raise ValueError('%s: no set(VICTRON_GUIPLUGINS_VERSION_%s <number>) line' % (path, part))
        version.append(int(match.group(1)))
    return tuple(version)


def parse_version(text):
    return tuple(int(part) for part in text.split('.'))


def format_version(version):
    return '%d.%d' % version


def disallowed_types(types):
    """Returns a message for each place where the API uses a type that plugins cannot use."""
    api_names = {api_type['name'] for api_type in types}
    enum_names = {'%s.%s' % (api_type['name'], enum['name'])
                  for api_type in types for enum in api_type.get('enums', [])}

    def allowed(type_name):
        match = re.fullmatch(r'list<(.+)>', type_name)
        if match:
            return allowed(match.group(1))
        return type_name in BASIC_TYPES | QT_TYPES | api_names | enum_names

    messages = []
    for api_type in types:
        uses = []
        if 'base' in api_type:
            uses.append(('its base type', api_type['base']))
        uses += [('property ' + prop['name'], prop['type']) for prop in api_type.get('properties', [])]
        for section, word in (('signals', 'signal'), ('methods', 'method')):
            for member in api_type.get(section, []):
                uses += [('%s %s' % (word, member['name']), parameter.partition(': ')[2])
                         for parameter in member['parameters'] if ': ' in parameter]
                if 'returns' in member:
                    uses.append(('%s %s' % (word, member['name']), member['returns']))
        messages += ['%s: %s uses %s' % (api_type['name'], where, type_name)
                     for where, type_name in uses if not allowed(type_name)]
    return messages


def parameters_break(old, new, compare_names):
    """Returns True if a caller (or, with compare_names, a signal handler) written for the old
    parameters may not work with the new ones."""
    if len(old) != len(new):
        return True
    for old_parameter, new_parameter in zip(old, new):
        old_name, _, old_type = old_parameter.partition(': ')
        new_name, _, new_type = new_parameter.partition(': ')
        if (compare_names and old_name != new_name) or (old_type and old_type != new_type):
            return True
    return False


def breaking_changes(old_record, module_version, types):
    """Returns a message for each change from old_record (the checked-in record, or None) that could
    break a plugin built for it. A new major version may make such changes.

    This does not see a change to a property's initial value, or to what a function does. Those can
    still break a plugin, and they need a new major version too."""
    if old_record is None:
        return []
    old_version = parse_version(old_record['version'])
    if module_version[0] > old_version[0]:
        return []
    messages = []
    if module_version < old_version:
        messages.append('the module version went down, from %s to %s'
                        % (format_version(old_version), format_version(module_version)))
    new_types = {api_type['name']: api_type for api_type in types}
    for old_type in old_record['types']:
        type_name = old_type['name']
        api_type = new_types.get(type_name)
        if api_type is None:
            messages.append('%s was removed or renamed' % type_name)
            continue
        if api_type['kind'] != old_type['kind']:
            messages.append('%s changed kind, from %s to %s' % (type_name, old_type['kind'], api_type['kind']))
        if api_type.get('base') != old_type.get('base'):
            messages.append('%s changed its base type, from %s to %s'
                            % (type_name, old_type.get('base', 'none'), api_type.get('base', 'none')))
        messages += member_changes(type_name, old_type, api_type)
    return messages


def member_changes(type_name, old_type, api_type):
    messages = []

    def by_name(record_type, section):
        return {member['name']: member for member in record_type.get(section, [])}

    old_properties = by_name(old_type, 'properties')
    new_properties = by_name(api_type, 'properties')
    for name, old in old_properties.items():
        prop = new_properties.get(name)
        if prop is None:
            messages.append('%s.%s was removed or renamed' % (type_name, name))
        elif prop['type'] != old['type']:
            messages.append('%s.%s changed type, from %s to %s' % (type_name, name, old['type'], prop['type']))
        elif prop.get('readonly') and not old.get('readonly'):
            messages.append('%s.%s became read-only' % (type_name, name))
    for name, prop in new_properties.items():
        if prop.get('required') and not old_properties.get(name, {}).get('required'):
            messages.append('%s.%s is required, so a plugin that does not set it would fail' % (type_name, name))
    old_default = next((name for name, old in old_properties.items() if old.get('default')), None)
    new_default = next((name for name, prop in new_properties.items() if prop.get('default')), None)
    if old_default is not None and new_default != old_default:
        messages.append('%s changed its default property, from %s to %s'
                        % (type_name, old_default, new_default or 'none'))

    for section, word, compare_names in (('signals', 'signal', True), ('methods', 'method', False)):
        new_members = by_name(api_type, section)
        for name, old in by_name(old_type, section).items():
            member = new_members.get(name)
            if member is None:
                messages.append('%s.%s was removed or renamed' % (type_name, name))
            elif parameters_break(old['parameters'], member['parameters'], compare_names):
                messages.append('%s.%s changed its parameters, from (%s) to (%s)'
                                % (type_name, name, ', '.join(old['parameters']), ', '.join(member['parameters'])))
            elif 'returns' in old and member.get('returns') != old['returns']:
                messages.append('%s.%s changed its return type, from %s to %s'
                                % (type_name, name, old['returns'], member.get('returns', 'none')))

    new_enums = by_name(api_type, 'enums')
    for name, old in by_name(old_type, 'enums').items():
        enum = new_enums.get(name)
        if enum is None:
            messages.append('%s.%s was removed or renamed' % (type_name, name))
            continue
        new_values = {value['name']: value['value'] for value in enum['values']}
        for value in old['values']:
            if value['name'] not in new_values:
                messages.append('%s.%s.%s was removed or renamed' % (type_name, name, value['name']))
            elif new_values[value['name']] != value['value']:
                messages.append('%s.%s.%s changed value, from %d to %d'
                                % (type_name, name, value['name'], value['value'], new_values[value['name']]))
    return messages


def make_record(old_record, module_version, types):
    """Returns the record of types, as a dict. Each type and member keeps the version that
    old_record gives it, or gets module_version if it is new. A new major version raises the
    versions to at least <major>.0."""
    def since(old):
        if old is None:
            return format_version(module_version)
        version = max(parse_version(old['since']), (module_version[0], 0))
        return format_version(min(version, module_version))

    def find(members, name):
        return next((member for member in members if member['name'] == name), None) if members is not None else None

    def recorded(member, old):
        """Returns member as stored: its since version, and a deprecated mark kept from old.

        The sources have no way to say that a member is deprecated, so the mark lives in the record."""
        result = dict(member, since=since(old))
        if old and old.get('deprecated'):
            result['deprecated'] = True
        return result

    record_types = []
    for api_type in types:
        old_type = find(old_record['types'] if old_record else None, api_type['name'])
        record_type = {'name': api_type['name'], 'kind': api_type['kind']}
        if 'base' in api_type:
            record_type['base'] = api_type['base']
        record_type['since'] = since(old_type)
        if old_type and old_type.get('deprecated'):
            record_type['deprecated'] = True
        for section in ('properties', 'signals', 'methods'):
            if section in api_type:
                old_members = old_type.get(section, []) if old_type else None
                record_type[section] = [recorded(member, find(old_members, member['name']))
                                        for member in api_type[section]]
        if 'enums' in api_type:
            record_type['enums'] = []
            for enum in api_type['enums']:
                old_enum = find(old_type.get('enums', []) if old_type else None, enum['name'])
                old_values = old_enum['values'] if old_enum else None
                recorded_enum = {
                    'name': enum['name'],
                    'since': since(old_enum),
                    'values': [recorded(value, find(old_values, value['name'])) for value in enum['values']],
                }
                if old_enum and old_enum.get('deprecated'):
                    recorded_enum['deprecated'] = True
                record_type['enums'].append(recorded_enum)
        record_types.append(record_type)
    return {'module': MODULE_URI, 'version': format_version(module_version), 'types': record_types}


def display_path(path):
    """Returns path relative to the source tree when it is inside it, with forward slashes."""
    normalized = path.replace('\\', '/')
    if not os.path.isabs(path):
        return normalized
    try:
        relative = os.path.relpath(path, SOURCE_DIR)
    except ValueError:
        return normalized
    if relative.startswith('..'):
        return normalized
    return relative.replace('\\', '/')


def unbumped_additions(old_record, module_version, record):
    """Returns new member names that must not be saved, because module_version is not newer than the
    version already in old_record. Empty if there is no old record, or the version was increased."""
    if old_record is None or tuple(module_version) > parse_version(old_record['version']):
        return []
    return new_members(old_record, record)


def unbumped_additions_message(old_record, module_version, record, output_path, docs_path):
    """Returns what to print when new members must not be saved. Empty if they may be saved."""
    added = unbumped_additions(old_record, module_version, record)
    if not added:
        return ''
    output_path = display_path(output_path)
    docs_path = display_path(docs_path)
    old_version = old_record['version']
    current = format_version(module_version)
    if tuple(module_version) == parse_version(old_version):
        version_text = 'is still %s, the same version as in %s' % (current, output_path)
    else:
        version_text = 'is %s, which is older than %s in %s' % (current, old_version, output_path)
    which = 'this new type or member cannot' if len(added) == 1 else 'these new types or members cannot'
    return (
        'Refusing to write %s.\n'
        '\n'
        'The version in %s %s, so %s be saved:\n'
        '%s\n'
        '\n'
        'A new type or member must be saved at a newer version. If %s saved at %s, the compiler can say a '
        'plugin only needs %s, and that plugin will fail on a GUI that has %s but not %s.\n'
        '\n'
        'Do this:\n'
        '  1. Increase VICTRON_GUIPLUGINS_VERSION_MINOR in %s, so the module version is newer than %s.\n'
        '  2. Run this script again.\n'
        '\n'
        'Do not edit %s by hand. This script did not change %s or %s.'
        % (output_path, MODULE_CMAKE_FILE, version_text, which,
           '\n'.join('  ' + name for name in added),
           'it is' if len(added) == 1 else 'these are', current, current, current,
           'this member' if len(added) == 1 else 'these',
           MODULE_CMAKE_FILE, old_version, output_path, output_path, docs_path)
    )


def new_members(old_record, record):
    """Returns the names of the types and members in record that old_record does not have."""
    def names(some_record):
        result = set()
        for record_type in some_record['types']:
            result.add(record_type['name'])
            for section in ('properties', 'signals', 'methods', 'enums'):
                for member in record_type.get(section, []):
                    result.add('%s.%s' % (record_type['name'], member['name']))
                    result |= {'%s.%s.%s' % (record_type['name'], member['name'], value['name'])
                               for value in member.get('values', [])}
        return result
    return sorted(names(record) - names(old_record))


def format_json(value, indent=0):
    """Returns value as JSON, with each list of members on its own lines, and each member on one line."""
    def is_scalar(item):
        return not isinstance(item, (dict, list))

    def is_flat(item):
        return is_scalar(item) or (isinstance(item, list) and all(is_scalar(element) for element in item))

    padding = '    ' * indent
    inner = '    ' * (indent + 1)
    if isinstance(value, dict) and not all(is_flat(item) for item in value.values()):
        items = ['%s%s: %s' % (inner, json.dumps(key), format_json(item, indent + 1)) for key, item in value.items()]
        return '{\n' + ',\n'.join(items) + '\n' + padding + '}'
    if isinstance(value, list) and value and not all(is_scalar(item) for item in value):
        return '[\n' + ',\n'.join(inner + format_json(item, indent + 1) for item in value) + '\n' + padding + ']'
    return json.dumps(value)


def generate_json(record):
    return format_json(record) + '\n'


def generate_versions(record):
    """Returns the list of versions for the type reference: the lines from DOCS_BEGIN to DOCS_END,
    ending with a newline. Each type has the version that added it, and is followed by the
    members, enums and enum values that a later version added."""
    lines = [DOCS_BEGIN, '']
    for record_type in record['types']:
        later = []
        for section in ('properties', 'signals', 'methods', 'enums'):
            for member in record_type.get(section, []):
                if parse_version(member['since']) > parse_version(record_type['since']):
                    later.append((parse_version(member['since']), member['name']))
                for value in member.get('values', []):
                    if parse_version(value['since']) > parse_version(member['since']):
                        later.append((parse_version(value['since']), value['name']))
        text = '- `%s`: %s' % (record_type['name'], record_type['since'])
        if later:
            items = ['`%s` (%s)' % (name, format_version(version)) for version, name in sorted(later)]
            text += ', except ' + (items[0] if len(items) == 1 else ', '.join(items[:-1]) + ' and ' + items[-1])
        lines.append(text)
    lines += ['', DOCS_END]
    return '\n'.join(lines) + '\n'


def replace_versions(docs_text, docs_path, versions):
    """Returns docs_text with its lines from DOCS_BEGIN to DOCS_END replaced by versions."""
    begin = docs_text.find(DOCS_BEGIN)
    end = docs_text.find(DOCS_END)
    if begin < 0 or end < begin or docs_text.find(DOCS_BEGIN, begin + 1) >= 0:
        raise ValueError('%s must contain these two lines once each, in this order:\n%s\n%s'
                         % (docs_path, DOCS_BEGIN, DOCS_END))
    end = docs_text.find('\n', end)
    end = len(docs_text) if end < 0 else end + 1
    return docs_text[:begin] + versions + docs_text[end:]


def read_source_file(source_dir, path):
    try:
        with open(os.path.join(source_dir, path), encoding='utf-8', newline='') as file:
            return file.read().replace('\r\n', '\n')
    except OSError:
        return None


def read_api(source_dir):
    """Returns (the module version, the API types) of the source tree at source_dir."""
    cmake_paths = ['CMakeLists.txt'] + sorted('cmake/' + os.path.basename(path)
                                              for path in glob.glob(os.path.join(source_dir, 'cmake', '*.cmake')))
    cmake_texts = [read_source_file(source_dir, path) or '' for path in cmake_paths]
    module_text = read_source_file(source_dir, MODULE_CMAKE_FILE)
    if module_text is None:
        raise ValueError('cannot read %s' % MODULE_CMAKE_FILE)
    files = module_files(cmake_texts, MODULE_TARGET)
    if not files:
        raise ValueError('no files are listed in the %s_... variables in cmake/' % MODULE_TARGET)
    return (parse_module_version(module_text, MODULE_CMAKE_FILE),
            read_types(lambda path: read_source_file(source_dir, path), files))


def main():
    parser = argparse.ArgumentParser(description='Generates the record of the Victron.GuiPlugins API')
    parser.add_argument('--source-dir', default=SOURCE_DIR)
    parser.add_argument('--output', default=DEFAULT_OUTPUT)
    parser.add_argument('--docs', default=DEFAULT_DOCS)
    parser.add_argument('--check', action='store_true',
                        help='Fail if the record or the list of versions is out of date, if the sources break the '
                             'record, or if a new member would be saved without a newer module version')
    parser.add_argument('--allow-breaking-changes', action='store_true',
                        help='Allow a change that could break plugins, without a new major version. Only do this '
                             'for a type or member that no released GUI has.')
    args = parser.parse_args()

    try:
        module_version, types = read_api(args.source_dir)
    except ValueError as error:
        print(error)
        return 1

    disallowed = disallowed_types(types)
    if disallowed:
        print('The %s API uses types that plugins cannot use:' % MODULE_URI)
        for message in disallowed:
            print('  ' + message)
        print('Plugins import only %s, QtQml and QtQuick. So the API may use only QML\'s basic types, %s, and %s '
              'types. Wrap a Victron.VenusOS type in a %s type instead.'
              % (MODULE_URI, ', '.join(sorted(QT_TYPES)), MODULE_URI, MODULE_URI))
        return 1

    current = read_source_file('', args.output)
    old_record = json.loads(current) if current is not None else None
    breaking = [] if args.allow_breaking_changes else breaking_changes(old_record, module_version, types)
    if breaking:
        print('The %s sources break the API in %s:' % (MODULE_URI, args.output))
        for message in breaking:
            print('  ' + message)
        print('Plugins built for %s %s may use these. Keep them as they were, or increase '
              'VICTRON_GUIPLUGINS_VERSION_MAJOR in %s. If no released GUI has them, run this script with '
              '--allow-breaking-changes.' % (MODULE_URI, old_record['version'], MODULE_CMAKE_FILE))
        return 1

    record = make_record(old_record, module_version, types)
    refused = unbumped_additions_message(old_record, module_version, record, args.output, args.docs)
    if refused:
        print(refused)
        return 1

    current_docs = read_source_file('', args.docs)
    if current_docs is None:
        print('Cannot read %s' % args.docs)
        return 1
    try:
        outputs = {
            args.output: generate_json(record),
            args.docs: replace_versions(current_docs, args.docs, generate_versions(record)),
        }
    except ValueError as error:
        print(error)
        return 1
    if args.check:
        stale = [path for path, contents in outputs.items() if read_source_file('', path) != contents]
        for path in stale:
            print('%s is out of date. Run tools/guipluginsapi.py to regenerate it.' % path)
        if not stale:
            print('%s are up to date.' % ' and '.join(outputs))
        return 1 if stale else 0

    if old_record is not None and current != outputs[args.output]:
        added = new_members(old_record, record)
        if added:
            print('Added to the API in %s: %s' % (format_version(module_version), ', '.join(added)))
    for path, contents in outputs.items():
        with open(path, 'w', encoding='utf-8', newline='\n') as file:
            file.write(contents)
    return 0


if __name__ == '__main__':
    sys.exit(main())
