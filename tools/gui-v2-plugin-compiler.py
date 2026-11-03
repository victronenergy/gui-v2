import bisect
import json
import os
import re
import shlex
import sys
import subprocess
import argparse
import base64
import shutil
import xml.etree.ElementTree as ET

# The Branding property list (name and version), generated from src/branding/branding.h by
# tools/brandingproperties.py. It is installed next to this script. The compiler uses it to
# write requiredBrandingVersion. It does not check property values against it.
BRANDING_PROPERTIES_FILE = 'branding-properties.json'
BRANDING_IMPORTS = ('Victron.Branding', 'QtQml', 'QtQuick')
BRANDING_INTEGRATION_TYPE = 6
# Image, animation and font files packed from the plugin directory. Paths in Branding.qml are not read.
BRANDING_ASSET_EXTENSIONS = ('.svg', '.png', '.gif', '.ttf', '.otf')
# A text search, not a complete ban. See .github/branding-plugins.md.
BRANDING_FORBIDDEN_WORDS = (
    'XMLHttpRequest',
    'createQmlObject',
    'createObject',
    'createComponent',
    'WorkerScript',
    'WebSocket',
    'LocalStorage',
    'openUrlExternally',
    'setContextProperty',
)
_IMPORT_LINE_RE = re.compile(
    r'^[ \t]*import[ \t]+(?P<module>"[^"]*"|\'[^\']*\'|[A-Za-z_][\w.]*)'
    r'(?:[ \t]+(?P<version>\d+(?:\.\d+)*))?'
    r'(?:[ \t]+as[ \t]+(?P<qualifier>[A-Za-z_]\w*))?'
    r'[ \t]*;?[ \t]*$'
)
_FORBIDDEN_RE = re.compile(
    r'\b(?:%s)\b|\bQt\s*\.\s*(?:include|quit|exit)\b' % '|'.join(BRANDING_FORBIDDEN_WORDS)
)

def _exists_with_exact_case(base_dir, path):
    """Returns whether a file exists at path ("/" separators) under base_dir. Unlike
    os.path.isfile, the case of each name must match, as on the device."""
    current = base_dir or '.'
    for part in path.split('/'):
        try:
            entries = os.listdir(current)
        except OSError:
            return False
        if part not in entries:
            return False
        current = os.path.join(current, part)
    return os.path.isfile(current)


_URL_SCHEME_RE = re.compile(r'[A-Za-z][A-Za-z0-9+.\-]*:')


def check_branding_path(value, extensions, file_exists):
    """Returns an error message if value is not a relative path to an existing file with
    one of the given extensions, else None. file_exists(path) returns whether a file exists
    at path, which is relative and uses "/" separators."""
    if value == '':
        return 'the path must not be empty.'
    if _URL_SCHEME_RE.match(value):
        return ('"%s" is a URL. Write a path relative to Branding.qml, for example "%s".'
                % (value, 'logo' + extensions[0]))
    if value.startswith('/'):
        return '"%s" is absolute. Write a path relative to Branding.qml, without the leading "/".' % value
    if '\\' in value:
        return '"%s" contains "\\". Use "/" to separate directories.' % value
    if '?' in value or '#' in value:
        return '"%s" must be a plain file path, without "?" or "#".' % value
    parts = value.split('/')
    if '..' in parts:
        return '"%s" contains "..". Files must be inside the plugin directory.' % value
    if not value.lower().endswith(extensions):
        return '"%s" must be a %s file.' % (value, ' or '.join(extensions))
    if not file_exists('/'.join(part for part in parts if part not in ('', '.'))):
        return ('"%s" was not found relative to Branding.qml. Paths are case-sensitive on '
                'the device.' % value)
    return None


def _mask_comments(text):
    """Replaces comments with spaces, keeping newlines, so later searches keep line numbers.

    This is not a QML parser. "//" or "/*" inside a string is treated as a comment too.
    """
    def mask(match):
        return re.sub(r'[^\n]', ' ', match.group(0))
    text = re.sub(r'/\*.*?\*/', mask, text, flags=re.S)
    return re.sub(r'//[^\n]*', mask, text)


def _line_col(text, offset):
    line = text.count('\n', 0, offset) + 1
    return line, offset - text.rfind('\n', 0, offset)


def _format_error(filename, line, col, message):
    return '%s:%d:%d: %s' % (filename, line, col, message)


def _property_names(properties):
    if isinstance(properties, dict):
        return list(properties.keys())
    return list(properties)


def check_branding_imports(text):
    """Returns (line, col, message) for import and pragma problems."""
    errors = []
    masked = _mask_comments(text)
    seen = {}
    for line_no, line in enumerate(masked.splitlines(), 1):
        if re.match(r'^[ \t]*pragma\b', line):
            errors.append((line_no, line.find('pragma') + 1,
                           'pragma is not allowed in a Branding file. Remove it.'))
            continue
        if not re.match(r'^[ \t]*import\b', line):
            continue
        match = _IMPORT_LINE_RE.match(line)
        col = line.find('import') + 1
        if not match:
            errors.append((line_no, col, 'invalid import. Write "import Victron.Branding".'))
            continue
        module = match.group('module')
        if module.startswith('"') or module.startswith("'"):
            errors.append((line_no, col, 'importing a file or directory (%s) is not allowed. A Branding file '
                           'may import only %s.' % (module, ', '.join(BRANDING_IMPORTS))))
            continue
        if match.group('qualifier'):
            errors.append((line_no, col, 'qualified imports ("as") are not allowed. Remove "as" and '
                           'the qualifier, so that the root object is written as Branding.'))
            continue
        if module not in BRANDING_IMPORTS:
            errors.append((line_no, col, 'importing %s is not allowed. A Branding file may import only %s.'
                           % (module, ', '.join(BRANDING_IMPORTS))))
            continue
        if module in seen:
            errors.append((line_no, col, '%s is imported more than once (first on line %d). Remove the '
                           'repeated import.' % (module, seen[module])))
            continue
        seen[module] = line_no
    if 'Victron.Branding' not in seen:
        errors.append((1, 1, 'missing "import Victron.Branding".'))
    return errors


def check_branding_forbidden(text):
    """Returns (line, col, message) for a few obvious calls. Comments are ignored."""
    errors = []
    for match in _FORBIDDEN_RE.finditer(_mask_comments(text)):
        line, col = _line_col(text, match.start())
        found = re.sub(r'\s+', '', match.group(0))
        errors.append((line, col, '"%s" is not allowed in a Branding file. '
                       'Do not start other objects, load scripts, or do I/O from this file.' % found))
    return errors


def assigned_branding_properties(text, property_names):
    """Property names assigned as `name:` at the start of a line, after spaces."""
    if not property_names:
        return []
    pattern = re.compile(r'(?m)^[ \t]*(%s)[ \t]*:' % '|'.join(
        re.escape(name) for name in sorted(property_names, key=len, reverse=True)))
    seen = []
    for match in pattern.finditer(_mask_comments(text)):
        name = match.group(1)
        if name not in seen:
            seen.append(name)
    return seen


def collect_branding_assets(directory):
    """Image, animation and font files under directory, relative to directory, with "/" separators."""
    if not directory:
        directory = '.'
    found = []
    for root, dirnames, filenames in os.walk(directory):
        dirnames[:] = [name for name in dirnames if not name.startswith('.')]
        for name in filenames:
            if name.lower().endswith(BRANDING_ASSET_EXTENSIONS):
                rel = os.path.relpath(os.path.join(root, name), directory)
                found.append(rel.replace('\\', '/'))
    return sorted(found)


def branding_packed_paths(branding_path, assets):
    """Resource paths for assets next to branding_path, relative to the working directory."""
    base = os.path.dirname(branding_path)
    return [os.path.normpath(os.path.join(base, asset) if base else asset).replace('\\', '/')
            for asset in assets]


def check_branding_text(filename, text, properties, assigned=None):
    """Checks imports and a few obvious calls in a Branding QML file.

    Does not check property values. If assigned is a list, the property names
    written as `name:` at the start of a line are appended to it.
    Returns the formatted error messages.
    """
    errors = check_branding_imports(text) + check_branding_forbidden(text)
    if assigned is not None:
        assigned.extend(assigned_branding_properties(text, _property_names(properties)))
    return [_format_error(filename, line, col, message)
            for line, col, message in sorted(errors, key=lambda item: (item[0], item[1]))]


def check_branding_file(path, properties, assigned=None):
    """Reads a Branding QML file and checks it.

    Returns (errors, files). files are the image, animation and font files under the same
    directory, relative to that directory, to be packed. Paths in the QML are not read.
    """
    try:
        with open(path, encoding='utf-8') as file:
            text = file.read()
    except UnicodeDecodeError:
        return ['%s:1:1: the file is not valid UTF-8.' % path], []
    directory = os.path.dirname(path) or '.'
    return check_branding_text(path, text, properties, assigned), collect_branding_assets(directory)


# The Victron.GuiPlugins API record: each type and member, with the version that added it. It is
# generated from the module's sources by tools/guipluginsapi.py, and installed next to this script.
GUIPLUGINS_API_FILE = 'guiplugins-api.json'

_NUMBER_RE = re.compile(r'(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?')
_HANDLER_NAME_RE = re.compile(r'on([A-Z_][\w$]*)$')
_IDENTIFIER_RE = re.compile(r'[A-Za-z_$][\w$]*')
_BRACKET_KEY_RE = re.compile(r'''\[[\'"]([A-Za-z_$][\w$]*)[\'"]\]''')
_SIMPLE_ESCAPES = {'n': '\n', 't': '\t', 'r': '\r', 'b': '\b', 'f': '\f', 'v': '\v', '0': '\0'}


class QmlToken:
    def __init__(self, kind, value, line, col):
        self.kind = kind    # 'ident', 'string', 'number', 'template', 'invalid' or 'punct'
        self.value = value
        self.line = line
        self.col = col

    def is_punct(self, value):
        return self.kind == 'punct' and self.value == value

    def is_ident(self, value=None):
        return self.kind == 'ident' and (value is None or self.value == value)


def _read_qml_string(text, i):
    """Reads the QML string starting at text[i]. Returns (end, value, error).

    A quoted string may contain a raw newline. An unclosed string runs to the end of the file.
    """
    quote = text[i]
    i += 1
    chars = []
    error = None
    n = len(text)
    while i < n:
        c = text[i]
        if c == quote:
            return i + 1, ''.join(chars), error
        if c != '\\':
            chars.append(c)
            i += 1
            continue
        i += 1
        if i >= n:
            break
        e = text[i]
        if e in _SIMPLE_ESCAPES:
            chars.append(_SIMPLE_ESCAPES[e])
            i += 1
        elif e in '\r\n':
            # Line continuation.
            i += 2 if text.startswith('\r\n', i) else 1
        elif e == 'x' or e == 'u':
            if e == 'u' and text.startswith('{', i + 1):
                end = text.find('}', i + 2)
                digits = text[i + 2:end] if end >= 0 else ''
                next_i = end + 1
            else:
                length = 2 if e == 'x' else 4
                digits = text[i + 1:i + 1 + length]
                digits = digits if len(digits) == length else ''
                next_i = i + 1 + length
            if digits and all(d in '0123456789abcdefABCDEF' for d in digits) and int(digits, 16) <= 0x10FFFF:
                chars.append(chr(int(digits, 16)))
                i = next_i
            else:
                error = error or 'invalid \\%s escape in string.' % e
                i += 1
        else:
            chars.append(e)
            i += 1
    return i, ''.join(chars), 'unterminated string; add the closing %s.' % quote


# After one of these keywords, / starts a regex. After any other name, / is division.
_REGEX_AFTER_KEYWORDS = {
    'return', 'case', 'throw', 'else', 'do', 'typeof', 'void', 'delete', 'in', 'instanceof',
    'new', 'yield', 'await', 'of', 'default',
}
_REGEX_FLAGS = set('gimsuyvd')


def _paren_closes_control_header(tokens):
    """True if tokens ends with the ) of if/while/for/with/switch/catch (...).

    A statement can follow that ), so / can start a regex. A ) that closes a call or a
    grouped expression is followed by division. obj.if(x) is a call, not a header.
    """
    depth = 0
    for index in range(len(tokens) - 1, -1, -1):
        token = tokens[index]
        if token.is_punct(')'):
            depth += 1
        elif token.is_punct('('):
            depth -= 1
            if depth == 0:
                if index == 0 or tokens[index - 1].kind != 'ident':
                    return False
                if index >= 2 and tokens[index - 2].is_punct('.'):
                    return False
                keyword = tokens[index - 1].value
                if keyword in ('if', 'while', 'for', 'with', 'switch', 'catch'):
                    return True
                return (keyword == 'await' and index >= 2 and tokens[index - 2].is_ident('for')
                        and not (index >= 3 and tokens[index - 3].is_punct('.')))
    return False


def _slash_starts_regex(tokens):
    """True if a / here can start a regex, rather than division.

    // and /* where a token starts are still comments. A / after a value is division, so
    a / b does not hide b. A / after an operator, such as text: /a/, is a regex. A / after
    if (ready) is a regex too. A / after any other ) is division. A / after a member is
    division, including when the member is a keyword: d.of / x and d?.of / x are division.
    """
    if not tokens:
        return True
    prev = tokens[-1]
    if prev.kind in ('number', 'string', 'template', 'invalid', 'regex'):
        return False
    if prev.kind == 'ident':
        if prev.value not in _REGEX_AFTER_KEYWORDS:
            return False
        # ?. is '?' then '.'. A name after either form of member access is not a keyword.
        if len(tokens) >= 2 and tokens[-2].is_punct('.'):
            return False
        return True
    if prev.is_punct(')'):
        return _paren_closes_control_header(tokens)
    if prev.is_punct(']') or prev.is_punct('}'):
        return False
    # a++ / b and a-- / b are division. a + /b/ is a regex.
    if (prev.is_punct('+') or prev.is_punct('-')) and len(tokens) >= 2 and tokens[-2].is_punct(prev.value):
        return False
    return True


def _read_regex(text, i):
    """Reads the regex starting at text[i]. Returns (end, error).

    Escapes and character classes are part of the regex, so /\\// and /[/*]/ do not start
    a comment. ] closes a class, including an empty one (/[]/ and /[^]/). An unclosed regex
    stops at the end of the line, so later lines are still read.
    """
    i += 1
    n = len(text)
    in_class = False
    while i < n:
        c = text[i]
        if c == '\n':
            return i, 'unterminated regex; add the closing /.'
        if c == '\\':
            i += 2 if i + 1 < n and text[i + 1] != '\n' else 1
            continue
        if c == '[' and not in_class:
            in_class = True
            i += 1
            continue
        if c == ']' and in_class:
            in_class = False
            i += 1
            continue
        if c == '/' and not in_class:
            i += 1
            while i < n and text[i] in _REGEX_FLAGS:
                i += 1
            return i, None
        i += 1
    return i, 'unterminated regex; add the closing /.'


def tokenize_qml(text):
    """Splits QML source into tokens, skipping whitespace and comments.

    Returns (tokens, errors, end_position), where errors is a list of (line, col, message)
    and end_position is the (line, col) of the end of the text.
    """
    line_starts = [0]
    for index, char in enumerate(text):
        if char == '\n':
            line_starts.append(index + 1)

    def position(offset):
        line = bisect.bisect_right(line_starts, offset)
        return line, offset - line_starts[line - 1] + 1

    tokens = []
    errors = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        start = i
        if c in ' \t\r\n\f\v\ufeff':
            i += 1
        elif c == '/':
            # A regex is one token. Comment markers inside it, such as /\// and /[/*]/, are not comments.
            # // and /* where a token starts are comments, including after return.
            if _slash_starts_regex(tokens) and not text.startswith('//', i) and not text.startswith('/*', i):
                i, error = _read_regex(text, i)
                if error:
                    errors.append(position(start) + (error,))
                tokens.append(QmlToken('regex', text[start:i], *position(start)))
            elif text.startswith('//', i):
                end = text.find('\n', i)
                i = n if end < 0 else end
            elif text.startswith('/*', i):
                end = text.find('*/', i + 2)
                if end < 0:
                    errors.append(position(start) + ('unterminated /* comment; add the closing */.',))
                    i = n
                else:
                    i = end + 2
            else:
                tokens.append(QmlToken('punct', '/', *position(start)))
                i += 1
        elif c.isalpha() or c in '_$':
            while i < n and (text[i].isalnum() or text[i] in '_$'):
                i += 1
            tokens.append(QmlToken('ident', text[start:i], *position(start)))
        elif c in '0123456789' or (c == '.' and i + 1 < n and text[i + 1] in '0123456789'):
            i = _NUMBER_RE.match(text, i).end()
            if i < n and (text[i].isalnum() or text[i] in '_$'):
                # For example 0x10 or 10px: not a decimal literal.
                while i < n and (text[i].isalnum() or text[i] in '_$.'):
                    i += 1
                tokens.append(QmlToken('invalid', text[start:i], *position(start)))
            else:
                # Keep the source text. float("1.10") is 1.1, and a number token is only used to quote
                # an import version in an error. It is not parsed as a major and minor version.
                tokens.append(QmlToken('number', text[start:i], *position(start)))
        elif c in '"\'':
            i, value, error = _read_qml_string(text, i)
            if error:
                errors.append(position(start) + (error,))
            tokens.append(QmlToken('string', value, *position(start)))
        elif c == '`':
            i += 1
            while i < n and text[i] != '`':
                i += 2 if text[i] == '\\' else 1
            i = min(i + 1, n)
            tokens.append(QmlToken('template', text[start:i], *position(start)))
        else:
            tokens.append(QmlToken('punct', c, *position(start)))
            i += 1
    return tokens, errors, position(n)


def _load_json_next_to_script(file_name, description):
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), file_name)
    try:
        with open(path, encoding='utf-8') as file:
            return json.load(file)
    except (OSError, ValueError) as e:
        print("\n\nERROR: cannot read the %s %s: %s" % (description, path, e))
        sys.exit(1)


def load_guiplugins_api():
    """Reads the Victron.GuiPlugins API record that tools/guipluginsapi.py generates."""
    return _load_json_next_to_script(GUIPLUGINS_API_FILE, 'Victron.GuiPlugins API record')


def load_branding_property_list():
    """Reads the Branding property list that tools/brandingproperties.py generates."""
    return _load_json_next_to_script(BRANDING_PROPERTIES_FILE, 'Branding property list')


def _parse_version(text):
    return tuple(int(part) for part in text.split('.'))


def required_branding_version(property_list, assigned):
    """Returns the lowest Victron.Branding version, as "major.minor", that has every property in
    assigned: the latest version that added one of them. A plugin that requires it also loads on
    devices with a newer minor version of the same major version."""
    added_in = {prop['name']: _parse_version(prop['since']) for prop in property_list['properties']}
    module_major = _parse_version(property_list['version'])[0]
    return '%d.%d' % max([(module_major, 0)] + [added_in[name] for name in assigned])


def find_qt_tool(name):
    """Returns the path of a Qt tool, or None if it is not installed.

    lrelease is often on PATH when qmllint and rcc are not. Some Linux packages
    put those tools in /usr/libexec when lrelease is /usr/bin/lrelease. That
    rewrite must change the path: otherwise lrelease itself matches isfile()
    and would be run as the other tool.
    """
    path = shutil.which(name)
    if path:
        return path
    lreleasePath = shutil.which('lrelease')
    if not lreleasePath:
        return None
    path = shutil.which(name, path=os.path.dirname(lreleasePath))
    if path:
        return path
    libexecPath = lreleasePath.replace('/usr/bin/lrelease', '/usr/libexec/' + name)
    if libexecPath != lreleasePath and os.path.isfile(libexecPath):
        return libexecPath
    return None


def run_qmllint(brandingPath, importPath):
    if not os.path.isfile(os.path.join(importPath, 'Victron', 'Branding', 'qmldir')):
        print("    note: Victron.Branding module not found under " + importPath + ", skipping qmllint")
        return
    qmllintPath = find_qt_tool('qmllint')
    if qmllintPath is None:
        print("    note: qmllint not found, skipping it")
        return
    result = subprocess.run([qmllintPath, '-I', importPath, brandingPath], capture_output=True, text=True)
    output = (result.stdout + result.stderr).strip()
    if output:
        print("    qmllint output:", output)
    if result.returncode != 0:
        print("\n\nERROR: qmllint reported problems in " + brandingPath)
        sys.exit(1)


def check_branding(brandingPath, importPath):
    """Checks the Branding file of a custom branding plugin. Returns image and font files to pack, and the
    plugin's requiredBrandingVersion."""
    if not brandingPath.endswith('.qml'):
        print("\n\nERROR: Invalid custom branding file specified, must be a .qml file")
        sys.exit(1)
    pathError = check_branding_path(brandingPath, ('.qml',),
                                    lambda relative_path: _exists_with_exact_case('.', relative_path))
    if pathError:
        print("\n\nERROR: Invalid custom branding file: " + pathError.replace('Branding.qml', 'the plugin directory'))
        sys.exit(1)
    assigned = []
    propertyList = load_branding_property_list()
    names = [prop['name'] for prop in propertyList['properties']]
    errors, files = check_branding_file(brandingPath, names, assigned)
    if errors:
        print("\n\nERROR: " + brandingPath + " failed the custom branding check:")
        for error in errors:
            print(error)
        sys.exit(1)
    run_qmllint(brandingPath, importPath)
    return branding_packed_paths(brandingPath, files), required_branding_version(propertyList, assigned)


def _constant_bracket_key(tokens, index):
    """Returns the identifier in ident["key"], ident['key'], or ident?.["key"] at tokens[index], or None.

    The tokenizer emits '?' and '.' as separate punctuation, so an optional chain sits between the
    name and the bracket. A key that is not a constant, such as PluginWords[word] or
    PluginWords?.[word], is not a name the compiler can see. PluginWords??["reset"] is not a member
    access: '??' is nullish coalescing, and the brackets are an array.
    """
    bracket = index + 1
    if (bracket + 1 < len(tokens) and tokens[bracket].is_punct('?')
            and tokens[bracket + 1].is_punct('.')):
        bracket += 2
    if (bracket + 2 < len(tokens) and tokens[bracket].is_punct('[')
            and tokens[bracket + 1].kind == 'string' and tokens[bracket + 2].is_punct(']')
            and _IDENTIFIER_RE.fullmatch(tokens[bracket + 1].value)):
        return tokens[bracket + 1].value
    return None


def _add_ident(names, name):
    """Adds name, and the property a change signal refers to.

    onCheckedChanged uses checkedChanged and checked. checkedChanged.connect uses checked
    too: a QML property's change signal is not a separate API member."""
    names.add(name)
    handler = _HANDLER_NAME_RE.match(name)
    if handler:
        signal = handler.group(1)[0].lower() + handler.group(1)[1:]
        names.add(signal)
        name = signal
    if name.endswith('Changed') and len(name) > len('Changed'):
        names.add(name[:-len('Changed')])


def guiplugins_names(tokens):
    """Reads the tokens of a QML file. Returns (imports, names): whether the file imports
    Victron.GuiPlugins, and the set of names that the file uses. A signal handler name also uses
    the signal (onClicked uses clicked), and a change handler also uses the property
    (onCheckedChanged uses checked). A direct connection does too (checkedChanged.connect uses
    checked). PluginWords["reset"] and PluginWords?.["reset"] use reset, as PluginWords.reset
    does; PluginWords[word] and PluginWords?.[word] do not, because the key is not a constant.
    Names inside template strings count; names inside other strings and comments do not."""
    imports = False
    names = set()
    for i, token in enumerate(tokens):
        if token.kind == 'template':
            for name in _IDENTIFIER_RE.findall(token.value):
                _add_ident(names, name)
            names.update(_BRACKET_KEY_RE.findall(token.value))
            continue
        if token.kind != 'ident':
            continue
        _add_ident(names, token.value)
        key = _constant_bracket_key(tokens, i)
        if key:
            names.add(key)
        if (token.value == 'import' and i + 3 < len(tokens) and tokens[i + 1].is_ident('Victron')
                and tokens[i + 2].is_punct('.') and tokens[i + 3].is_ident('GuiPlugins')
                and not (i + 4 < len(tokens) and tokens[i + 4].is_punct('.'))):
            imports = True
    return imports, names


def versioned_guiplugins_import(tokens):
    """Returns 'import Victron.GuiPlugins <version>' if the tokens have one, or None.

    The required version comes from the names the file uses, not from this import. A version here
    is rejected: an older GUI could accept the plugin, and then fail to load the file.
    """
    for i, token in enumerate(tokens):
        if (token.is_ident('import') and i + 4 < len(tokens) and tokens[i + 1].is_ident('Victron')
                and tokens[i + 2].is_punct('.') and tokens[i + 3].is_ident('GuiPlugins')
                and tokens[i + 4].kind == 'number'):
            return 'import Victron.GuiPlugins %s' % tokens[i + 4].value
    return None


def reject_tokenizer_errors(path, errors):
    """Exits if the QML tokenizer reported errors.

    A name after an error can be missed, so the required version would be too low, and the file
    would not load."""
    if not errors:
        return
    print("\n\nERROR: %s: cannot read this QML file:" % path)
    for line, col, message in errors:
        print("    line %d, column %d: %s" % (line, col, message))
    sys.exit(1)


def reject_versioned_import(path, tokens):
    """Exits if the tokens import Victron.GuiPlugins with a version."""
    versioned = versioned_guiplugins_import(tokens)
    if not versioned:
        return
    print("\n\nERROR: %s: %s has a version. Import Victron.GuiPlugins without a version. "
          "The required version is written from the types and members that the files use."
          % (path, versioned))
    sys.exit(1)


def _member_type_names(member):
    """Returns the names in a member's type, parameter types and return type, such as PluginUnit
    in "list<PluginUnit.Unit>"."""
    types = [member.get('type', ''), member.get('returns', '')]
    types += [parameter.split(':')[-1] for parameter in member.get('parameters', [])]
    return {name for type_text in types for name in _IDENTIFIER_RE.findall(type_text)}


def _api_uses(api, names):
    """Returns (since, qualified name, record) for each type and member that names may use.

    It cannot tell which object a name refers to, so a name matches every member with that name
    on a type the plugin can reach: the types it names, their base types, and the types of the
    members it uses. A reached type counts too, so its own version is not missed."""
    types = {apiType['name']: apiType for apiType in api['types']}
    uses = []
    reached = {name for name in names if name in types}

    def add_type(name):
        uses.append((types[name]['since'], name, types[name]))

    for name in reached:
        add_type(name)
    pending = sorted(reached)
    while pending:
        apiType = types[pending.pop()]
        nextTypes = {apiType.get('base', '')}
        for section in ('properties', 'signals', 'methods', 'roles'):
            for member in apiType.get(section, []):
                if member['name'] in names:
                    uses.append((member['since'], apiType['name'] + '.' + member['name'], member))
                    nextTypes |= _member_type_names(member)
        for enum in apiType.get('enums', []):
            for item in [enum] + enum['values']:
                if item['name'] in names:
                    uses.append((item['since'], apiType['name'] + '.' + item['name'], item))
        for name in sorted(nextTypes):
            if name in types and name not in reached:
                reached.add(name)
                pending.append(name)
                add_type(name)
    return uses


def required_guiplugins_version(api, names):
    """Returns the lowest Victron.GuiPlugins version, as "major.minor", that has every type and
    member that a plugin with these names may use. Also returns the uses that need that version
    (such as "PluginListSwitch.checked"), if it is newer than <major>.0.

    The version is never too old, but it is newer than needed if one of the plugin's own names
    matches a newer member. See _api_uses()."""
    floor = (_parse_version(api['version'])[0], 0)
    uses = [(_parse_version(since), name) for since, name, _record in _api_uses(api, names)]
    version = max([floor] + [use[0] for use in uses])
    needs = sorted(use[1] for use in uses if use[0] == version and version > floor)
    return '%d.%d' % version, needs


def deprecated_uses(api, names):
    """Returns the qualified names of the deprecated types and members that names may use.

    A record marks one with "deprecated": true. The match is the same as for the required version,
    so a plugin's own name can be reported if it matches a deprecated member."""
    return sorted(name for _since, name, record in _api_uses(api, names) if record.get('deprecated'))


def check_guiplugins_version(qmlFiles):
    """Returns the plugin's requiredGuiPluginsVersion, worked out from its QML files, or '' if
    none of them imports Victron.GuiPlugins. Exits if a file cannot be tokenized, or imports
    Victron.GuiPlugins with a version."""
    imports = False
    names = set()
    for path in qmlFiles:
        with open(path, encoding='utf-8', errors='replace') as file:
            text = file.read()
        tokens, errors, _end = tokenize_qml(text)
        reject_tokenizer_errors(path, errors)
        reject_versioned_import(path, tokens)
        fileImports, fileNames = guiplugins_names(tokens)
        imports = imports or fileImports
        names |= fileNames
    if not imports:
        print("    no file imports Victron.GuiPlugins")
        return ''
    api = load_guiplugins_api()
    version, needs = required_guiplugins_version(api, names)
    print("    requiredGuiPluginsVersion: " + version + (" (for " + ", ".join(needs) + ")" if needs else ""))
    deprecated = deprecated_uses(api, names)
    if deprecated:
        print("    WARNING: uses deprecated Victron.GuiPlugins API: " + ", ".join(deprecated)
              + ". It will be removed in a later major version.")
    return version


# Returns the JSON integration for the args of one --card option.
def card_integration(integration, pluginName, qmlFiles):
    if len(integration) != 2:
        print("\n\nERROR: --card requires 2 args: page.qml cardType (1=controls, 2=switches)")
        sys.exit(1)
    pageQml = integration[0]
    try:
        cardType = int(integration[1])
    except ValueError:
        print("\n\nERROR: Card type must be an integer (1=controls, 2=switches)")
        sys.exit(1)
    if cardType not in (1, 2):
        print("\n\nERROR: Card type must be 1 (controls) or 2 (switches)")
        sys.exit(1)
    if not pageQml.endswith('.qml'):
        print("\n\nERROR: Card page must be a .qml file")
        sys.exit(1)
    require_packed_file(pageQml, qmlFiles, "Card page")
    return {
        "type": 5,
        "url": "qrc:/" + pluginName + "/" + pageQml,
        "cardType": cardType
    }

def require_packed_file(path, packedFiles, description):
    # Only the files directly in the current directory are packed, and resource paths are
    # case-sensitive, so the name must match a packed file exactly.
    if path not in packedFiles:
        print(f"\n\nERROR: {description} \"{path}\" is not a file in the current directory. It must not be"
              " in a subdirectory, and its name must have the same case as the file name.")
        sys.exit(1)

def collect_filenames(directory, suffix):
    files = []
    for filename in os.listdir(directory):
        if filename.endswith(suffix):
            files.append(filename)
    return files

def run_lupdate(qmlFiles, tsFiles, name):
    cmd = ['lupdate']
    cmd.extend(qmlFiles)
    if len(tsFiles) > 0:
        cmd.extend(['-ts'])
        for tsFile in tsFiles:
            cmd.extend([tsFile])
    else:
        defaultTsName = "" + name + "_en.ts"
        cmd.extend(['-ts', defaultTsName])
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if result.stdout:
            print("    lupdate output:", result.stdout)
        if result.stderr:
            print("    lupdate stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"    lupdate returncode: {e.returncode}")
        print("    lupdate error:", e.stderr, file=sys.stderr)

def run_lrelease(tsFiles, name):
    if len(tsFiles) == 0:
        tsFiles.append("" + name + "_en.ts")
    for filename in tsFiles:
        qmFile = filename[:-2] + "qm"
        cmd = ['lrelease']
        cmd.extend([filename])
        cmd.extend(['-idbased'])
        cmd.extend(['-qm', qmFile])
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            if result.stdout:
                print("    lrelease output:", result.stdout)
            if result.stderr:
                print("    lrelease stderr:", result.stderr)
        except subprocess.CalledProcessError as e:
            print(f"    lrelease returncode: {e.returncode}")
            print("    lrelease error:", e.stderr, file=sys.stderr)

def write_qrc(qmlFiles, qmFiles, imageFiles, name):
    # Keep the order, but list each file once (Branding files may also be collected as top-level files).
    allFiles = list(dict.fromkeys(qmlFiles + qmFiles + imageFiles))
    contents = "<RCC>\n<qresource prefix=\"/" + name + "\">\n"
    for filename in allFiles:
        contents += "<file>" + filename + "</file>\n"
    contents += "</qresource>\n</RCC>\n"
    try:
        filename = "" + name + ".qrc"
        with open(filename, 'w') as file:
            file.write(contents)
    except IOError as e:
        print(f"    Error writing to file: {e}")

def run_rcc(name):
    rccPath = find_qt_tool('rcc')
    if not rccPath:
        print("\n\nERROR: rcc not found, perhaps generate .rcc manually from .qrc then pass it with --rcc <filename>")
        sys.exit(1)

    qrcFile = "" + name + ".qrc"
    rccFile = "" + name + ".rcc"
    cmd = [rccPath]
    cmd.extend(['-binary'])
    cmd.extend(['-compress-algo', 'zlib'])
    cmd.extend(['-o', rccFile])
    cmd.extend([qrcFile])
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if result.stdout:
            print("    rcc output:", result.stdout)
        if result.stderr:
            print("    rcc stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print("\n\nERROR: rcc failed: " + (e.stderr or ''), file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print("\n\nERROR: rcc not found, perhaps generate .rcc manually from .qrc then pass it with --rcc <filename>")
        sys.exit(1)

def b64_encode_rcc(name):
    rccFile = "" + name + ".rcc"
    base64Str = ""
    try:
        with open(rccFile, 'rb') as file:
            data = file.read()
            base64data = base64.b64encode(data)
            base64Str = base64data.decode('utf-8')
    except FileNotFoundError:
        print("    cannot open " + rccFile + " for reading!")
    return base64Str

def write_compiled_json(name, version, minRequiredVersion, maxRequiredVersion, translations, integrations, resource,
                        requiredGuiPluginsVersion='', requiredBrandingVersion=''):
    dataDict = {
        "name": name,
        "version": version,
        "minRequiredVersion": minRequiredVersion,
        "maxRequiredVersion": maxRequiredVersion,
    }
    if requiredGuiPluginsVersion:
        dataDict["requiredGuiPluginsVersion"] = requiredGuiPluginsVersion
    if requiredBrandingVersion:
        dataDict["requiredBrandingVersion"] = requiredBrandingVersion
    dataDict.update({
        "translations": translations,
        "integrations": integrations,
        "resource": resource
    })
    with open(name+'.json', 'w', encoding='utf-8') as file:
        json.dump(dataDict, file, indent=4)
        file.write('\n')

def strip_empty_sources(tsFiles):
    """
    Remove <message> entries with empty/whitespace <source> from .ts files.
    """
    for filename in tsFiles:
        try:
            tree = ET.parse(filename)
            root = tree.getroot()
            changed = False
            for context in list(root.findall('context')):
                for message in list(context.findall('message')):
                    source = message.find('source')
                    if source is None or (source.text is None) or (source.text.strip() == ''):
                        context.remove(message)
                        changed = True
                # remove empty contexts
                if len(context.findall('message')) == 0:
                    root.remove(context)
                    changed = True
            if changed:
                tree.write(filename, encoding='utf-8', xml_declaration=True)
                print("    stripped empty translations from", filename)
        except Exception as e:
            print("    failed to process", filename, e, file=sys.stderr)


# A plugin name is a directory name, a JSON file name, a qrc prefix and a translation stem.
# The GUI rejects the same names. See GuiPluginLoader::checkPluginName().
_PLUGIN_NAME_RE = re.compile(r'[A-Za-z][A-Za-z0-9_]{0,63}\Z')
_GX_HOST_RE = re.compile(r'[A-Za-z0-9][A-Za-z0-9.-]*\Z')
_SSH_OPTIONS = ['-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes', '-o', 'StrictHostKeyChecking=accept-new']


def plugin_name_error(name):
    """Returns an error if name is not a valid plugin name, or None."""
    if _PLUGIN_NAME_RE.fullmatch(name):
        return None
    return ('plugin name %r must start with a letter, contain only letters, digits and underscores, '
            'and be at most 64 characters' % name)


def gx_install_command(name, host, key_path):
    """Returns (ssh argv, remote JSON path) for a testing install. Does not run ssh.

    Connects as root with key_path. The remote command reads the JSON on stdin, writes
    /data/apps/available/<name>/gui-v2/<name>.json, and symlinks
    /data/apps/available/<name> to /data/apps/enabled/<name>. It will not replace a
    real directory at the enabled path.
    """
    host = host.strip()
    if host.startswith('root@'):
        host = host[len('root@'):]
    elif '@' in host:
        raise ValueError('connects as root; pass the device address, not another user@host')
    if not _GX_HOST_RE.fullmatch(host):
        raise ValueError('invalid device address %r' % host)
    error = plugin_name_error(name)
    if error:
        raise ValueError(error)
    available = '/data/apps/available/' + name
    gui_dir = available + '/gui-v2'
    remote_json = gui_dir + '/' + name + '.json'
    enabled = '/data/apps/enabled/' + name
    quoted = [shlex.quote(path) for path in (
        gui_dir, '/data/apps/enabled', enabled, enabled, enabled, remote_json, available, enabled)]
    script = (
        'mkdir -p %s %s && '
        'if [ -e %s ] && [ ! -L %s ]; then '
        'echo "ERROR: %s exists and is not a symlink" >&2; exit 1; '
        'fi && cat > %s && ln -sfn %s %s' % tuple(quoted))
    argv = ['ssh', '-i', key_path] + _SSH_OPTIONS + ['root@' + host, script]
    return argv, remote_json


def install_on_gx(name, host, key_path, json_path=''):
    """Copies the compiled JSON to a GX device and enables the app. For testing only."""
    json_path = json_path or (name + '.json')
    if not os.path.isfile(json_path):
        print("\n\nERROR: cannot install %s: the compiled JSON was not written" % json_path)
        sys.exit(1)
    if not key_path or not os.path.isfile(key_path):
        print("\n\nERROR: --ssh-key must be the private key file used to connect as root")
        sys.exit(1)
    try:
        argv, remote_json = gx_install_command(name, host, key_path)
    except ValueError as e:
        print("\n\nERROR: --install: %s" % e)
        sys.exit(1)
    print("--- installing on the GX device for testing")
    print("    copying %s to root@%s:%s" % (json_path, argv[-2][len('root@'):], remote_json))
    with open(json_path, 'rb') as json_file:
        payload = json_file.read()
    try:
        result = subprocess.run(argv, input=payload, capture_output=True, check=True)
    except FileNotFoundError:
        print("\n\nERROR: ssh was not found. Install OpenSSH, then run --install again.")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print("\n\nERROR: install failed:", (e.stderr or b'').decode('utf-8', 'replace'), file=sys.stderr)
        sys.exit(1)
    if result.stderr:
        print("    ssh stderr:", result.stderr.decode('utf-8', 'replace'))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='gui-v2-plugin-compiler',
        description='Compiles plugins for gui-v2 into json files')

    parser.add_argument('--rcc', nargs='?', default='') # debugging only...
    parser.add_argument('-n', '--name', default=os.path.basename(os.getcwd()),
                        help='Plugin name: a letter, then letters, digits and underscores, at most 64 characters')
    parser.add_argument('-v', '--version', default='1.0', help='The version of your plugin')
    parser.add_argument('-z', '--min-required-version', default='', help='The minimum gui-v2 version required for the plugin')
    parser.add_argument('-x', '--max-required-version', default='', help='The maximum gui-v2 version compatible with this plugin')
    parser.add_argument('-s', '--settings', default='', help='The main settings page .qml associated with your plugin')
    parser.add_argument('-d', '--devicelist', required=False, nargs='+', action='append', help='Triplet of product id, settings page .qml, and title text (or translation id)')
    parser.add_argument('-g', '--navigation', default='')
    parser.add_argument('-q', '--quickaccess', default='')
    parser.add_argument('-c', '--card', required=False, nargs='+', action='append', help='Pair of page .qml and card type (1=controls, 2=switches)')
    parser.add_argument('-b', '--branding', default='',     help='The Branding .qml file of a custom branding plugin')
    parser.add_argument('--qml-import-path', default=os.path.dirname(os.path.abspath(__file__)),
                        help='The directory containing Victron/Branding/qmldir, used by qmllint '
                             '(default: the directory of this script)')
    parser.add_argument('-f', '--filter-empty-sources', action='store_true', help='Strip empty source entries from .ts files')
    parser.add_argument('--install', metavar='HOST', default='',
                        help='For testing only: install the compiled JSON on a GX device as root. '
                             'HOST is the device address, or root@HOST')
    parser.add_argument('--ssh-key', metavar='FILE', default='',
                        help='Private key for --install. Required with --install')

    args = parser.parse_args()
    if bool(args.install) != bool(args.ssh_key):
        print("\n\nERROR: --install and --ssh-key must be given together")
        sys.exit(1)

    nameError = plugin_name_error(args.name)
    if nameError:
        print("\n\nERROR:", nameError)
        sys.exit(1)
    if args.name != os.path.basename(os.getcwd()):
        print("\n\nERROR: plugin name does not match working directory name!")
        sys.exit(1)

    # The custom branding check runs first, so that a rejected Branding file never produces an RCC.
    brandingFiles = []
    requiredBrandingVersion = ''
    if len(args.branding) > 0:
        print("--- checking custom branding")
        brandingFiles, requiredBrandingVersion = check_branding(args.branding, args.qml_import_path)
        brandingFiles.append(os.path.normpath(args.branding).replace('\\', '/'))

    imageFiles = collect_filenames('.', '.svg')
    imageFiles += collect_filenames('.', '.png')
    fontFiles = collect_filenames('.', '.ttf')
    fontFiles += collect_filenames('.', '.otf')
    qmlFiles = collect_filenames('.', '.qml')
    tsFiles = collect_filenames('.', '.ts')

    print("--- checking the Victron.GuiPlugins version")
    requiredGuiPluginsVersion = check_guiplugins_version(qmlFiles)

    print("--- running lupdate")
    run_lupdate(qmlFiles, tsFiles, args.name)

    if args.filter_empty_sources and tsFiles:
        strip_empty_sources(tsFiles)

    print("--- running lrelease")
    run_lrelease(tsFiles, args.name)
    qmFiles = collect_filenames('.', '.qm')

    print("--- writing .qrc")
    write_qrc(qmlFiles, qmFiles, imageFiles + fontFiles + brandingFiles, args.name)

    print("--- running rcc")
    if len(args.rcc) == 0:
        run_rcc(args.name)

    print("--- base64 encoding rcc data")
    resource = b64_encode_rcc(args.name)
    if not resource:
        print("\n\nERROR: no rcc data to pack, so the plugin json was not written")
        sys.exit(1)

    print("--- building translations array")
    translations = []
    for qmFile in qmFiles:
        translations.append("qrc:/" + args.name + "/" + qmFile)

    print("--- building integrations dictionary")
    integrations = []
    if len(args.settings) > 0:
        if not args.settings.endswith('.qml'):
            print("\n\nERROR: Invalid settings page specified, must be a .qml file")
            sys.exit(1)
        if not os.path.exists(args.settings):
            print(f"\n\nERROR: Settings page \"{args.settings}\" not found in current directory ({os.path.dirname(os.path.abspath(args.settings))})")
            sys.exit(1)
        settingsIntegration = {
            "type": 1,
            "url": "qrc:/" + args.name + "/" + args.settings
        }
        integrations.append(settingsIntegration)
    if args.devicelist:
        if len(args.devicelist) > 0:
            for integration in args.devicelist:
                if len(integration) != 3:
                    print("\n\nERROR: Invalid devicelist triplet!")
                    sys.exit(1)
                if not integration[0].startswith(('0x', '0X')):
                    print("\n\nERROR: Invalid product id specified in devicelist triplet, must be a hex string starting with 0x")
                    sys.exit(1)
                if not integration[1].endswith('.qml'):
                    print("\n\nERROR: Invalid settings page specified in devicelist triplet, must be a .qml file")
                    sys.exit(1)
                if not os.path.exists(integration[1]):
                    print(f"\n\nERROR: Settings page \"{integration[1]}\" not found in current directory ({os.path.dirname(os.path.abspath(integration[1]))})")
                    sys.exit(1)
                devicelistIntegration = {
                    "type": 2,
                    "productId": integration[0],
                    "url": "qrc:/" + args.name + "/" + integration[1],
                    "title": integration[2]
                }
                integrations.append(devicelistIntegration)
    if len(args.navigation) > 0:
        print("TODO: navigation...")
    if len(args.quickaccess) > 0:
        print("TODO: quick access...")
    if args.card:
        for integration in args.card:
            integrations.append(card_integration(integration, args.name, qmlFiles))
    if len(args.branding) > 0:
        brandingIntegration = {
            "type": BRANDING_INTEGRATION_TYPE,
            "url": "qrc:/" + args.name + "/" + brandingFiles[-1]
        }
        integrations.append(brandingIntegration)

    print("--- writing compiled json")
    write_compiled_json(args.name, args.version, args.min_required_version, args.max_required_version, translations,
                        integrations, resource, requiredGuiPluginsVersion, requiredBrandingVersion)

    if args.install:
        install_on_gx(args.name, args.install, args.ssh_key)

    print("--- done!")
    sys.exit(0)
