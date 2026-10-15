import json
import math
import os
import sys
import subprocess
import argparse
import base64
import bisect
import difflib
import re
import shlex
import shutil
import xml.etree.ElementTree as ET

# The Branding property list (name and type), generated from src/branding/branding.h by
# tools/brandingproperties.py. It is installed next to this script.
BRANDING_PROPERTIES_FILE = 'branding-properties.json'
BRANDING_IMPORTS = ('Victron.Branding', 'QtQml', 'QtQuick')
BRANDING_DECLARATION_KEYWORDS = ('property', 'readonly', 'required', 'default', 'signal', 'function', 'enum', 'component')
BRANDING_IMAGE_EXTENSIONS = ('.svg', '.png')
BRANDING_FONT_EXTENSIONS = ('.ttf', '.otf')
BRANDING_FONT_FILE_PROPERTIES = ('font_files',)
BRANDING_BACKGROUND_FACTOR_PROPERTY = 'light_mode_background_factor'
BRANDING_BACKGROUND_PRIMARY_PROPERTY = 'color_background_primary'
BRANDING_MAXIMUM_BACKGROUND_FACTOR = 2
BRANDING_INTEGRATION_TYPE = 6

SVG_COLOR_NAMES = frozenset((
    'aliceblue', 'antiquewhite', 'aqua', 'aquamarine', 'azure', 'beige', 'bisque', 'black',
    'blanchedalmond', 'blue', 'blueviolet', 'brown', 'burlywood', 'cadetblue', 'chartreuse',
    'chocolate', 'coral', 'cornflowerblue', 'cornsilk', 'crimson', 'cyan', 'darkblue', 'darkcyan',
    'darkgoldenrod', 'darkgray', 'darkgreen', 'darkgrey', 'darkkhaki', 'darkmagenta',
    'darkolivegreen', 'darkorange', 'darkorchid', 'darkred', 'darksalmon', 'darkseagreen',
    'darkslateblue', 'darkslategray', 'darkslategrey', 'darkturquoise', 'darkviolet', 'deeppink',
    'deepskyblue', 'dimgray', 'dimgrey', 'dodgerblue', 'firebrick', 'floralwhite', 'forestgreen',
    'fuchsia', 'gainsboro', 'ghostwhite', 'gold', 'goldenrod', 'gray', 'grey', 'green',
    'greenyellow', 'honeydew', 'hotpink', 'indianred', 'indigo', 'ivory', 'khaki', 'lavender',
    'lavenderblush', 'lawngreen', 'lemonchiffon', 'lightblue', 'lightcoral', 'lightcyan',
    'lightgoldenrodyellow', 'lightgray', 'lightgreen', 'lightgrey', 'lightpink', 'lightsalmon',
    'lightseagreen', 'lightskyblue', 'lightslategray', 'lightslategrey', 'lightsteelblue',
    'lightyellow', 'lime', 'limegreen', 'linen', 'magenta', 'maroon', 'mediumaquamarine',
    'mediumblue', 'mediumorchid', 'mediumpurple', 'mediumseagreen', 'mediumslateblue',
    'mediumspringgreen', 'mediumturquoise', 'mediumvioletred', 'midnightblue', 'mintcream',
    'mistyrose', 'moccasin', 'navajowhite', 'navy', 'oldlace', 'olive', 'olivedrab', 'orange',
    'orangered', 'orchid', 'palegoldenrod', 'palegreen', 'paleturquoise', 'palevioletred',
    'papayawhip', 'peachpuff', 'peru', 'pink', 'plum', 'powderblue', 'purple', 'red', 'rosybrown',
    'royalblue', 'saddlebrown', 'salmon', 'sandybrown', 'seagreen', 'seashell', 'sienna', 'silver',
    'skyblue', 'slateblue', 'slategray', 'slategrey', 'snow', 'springgreen', 'steelblue', 'tan',
    'teal', 'thistle', 'tomato', 'turquoise', 'violet', 'wheat', 'white', 'whitesmoke', 'yellow',
    'yellowgreen',
))

_NUMBER_RE = re.compile(r'(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?')
_HEX_COLOR_RE = re.compile(r'#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})')
_URL_SCHEME_RE = re.compile(r'[A-Za-z][A-Za-z0-9+.\-]*:')
_SIGNAL_HANDLER_RE = re.compile(r'on[A-Z_]')
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
    """Reads the JavaScript string starting at text[i]. Returns (end, value, error)."""
    quote = text[i]
    i += 1
    chars = []
    error = None
    n = len(text)
    while i < n:
        c = text[i]
        if c == quote:
            return i + 1, ''.join(chars), error
        if c == '\n':
            break
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
                tokens.append(QmlToken('number', float(text[start:i]), *position(start)))
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


def check_branding_color(value):
    """Returns an error message if value is not an opaque QML color string, else None."""
    if value.lower() == 'transparent':
        return '"transparent" is not allowed; branding colors must be opaque.'
    match = _HEX_COLOR_RE.fullmatch(value)
    if match:
        digits = match.group(1)
        if len(digits) == 8 and digits[:2].lower() != 'ff':
            return ('"%s" is not opaque. QML reads 8-digit colors as #AARRGGBB, with alpha first '
                    '(CSS puts it last), so its alpha is %s. Branding colors must be opaque: '
                    'write "#RRGGBB".' % (value, digits[:2]))
        return None
    if value.lower() in SVG_COLOR_NAMES:
        return None
    return ('"%s" is not a color. Write "#RGB", "#RRGGBB", "#FFRRGGBB" or an SVG color name '
            'such as "navy".' % value)


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


class BrandingChecker:
    """The literal-only check for Branding QML files (see the plan, section 10.G).

    It accepts only a small allowlisted grammar: imports of Victron.Branding, QtQml and
    QtQuick, then one Branding object whose body contains only "property: literal"
    assignments. Anything that QML could compile into a binding is rejected.
    """

    def __init__(self, filename, text, properties, file_exists):
        self.filename = filename
        self.properties = properties
        self.base_dir = os.path.dirname(filename)
        self.file_exists = file_exists
        self.tokens, lex_errors, self.end_position = tokenize_qml(text)
        self.pos = 0
        self.errors = [(line, col, None, message) for line, col, message in lex_errors]
        self.values = {}
        self.files = []
        self.warnings = []

    def peek(self, offset=0):
        index = self.pos + offset
        return self.tokens[index] if index < len(self.tokens) else None

    def error(self, token, prop, message):
        line, col = (token.line, token.col) if token is not None else self.end_position
        self.errors.append((line, col, prop, message))

    def warning(self, token, prop, message):
        self.warnings.append((token.line, token.col, prop, message))

    def format(self, entries):
        result = []
        for line, col, prop, message in sorted(entries, key=lambda e: (e[0], e[1])):
            prefix = '%s:%d:%d: ' % (self.filename, line, col)
            result.append(prefix + (prop + ': ' if prop else '') + message)
        return result

    def formatted_errors(self):
        return self.format(self.errors)

    def formatted_warnings(self):
        return self.format(self.warnings)

    def check(self):
        self.parse_imports()
        self.parse_root()
        self.check_values()
        return self.formatted_errors()

    def skip_statement(self):
        """Skips to the end of the current statement, for error recovery."""
        depth = 0
        previous = None
        while self.pos < len(self.tokens):
            token = self.tokens[self.pos]
            if depth == 0 and token.is_punct('}'):
                return
            if depth == 0 and previous is not None:
                if token.is_punct(';'):
                    self.pos += 1
                    return
                if token.kind == 'ident' and token.line > previous.line:
                    return
            if token.kind == 'punct' and token.value in '([{':
                depth += 1
            elif token.kind == 'punct' and token.value in ')]}' and depth > 0:
                depth -= 1
            previous = token
            self.pos += 1

    def skip_line(self, line):
        while self.peek() is not None and self.peek().line == line:
            self.pos += 1

    def read_dotted_name(self):
        name = self.peek().value
        self.pos += 1
        while self.peek() is not None and self.peek().is_punct('.') \
                and self.peek(1) is not None and self.peek(1).kind == 'ident':
            name += '.' + self.peek(1).value
            self.pos += 2
        return name

    def describe_expression(self):
        """Describes the expression at the current position, for an error message."""
        token = self.peek()
        if token.kind == 'ident':
            saved = self.pos
            name = self.read_dotted_name()
            following = self.peek()
            self.pos = saved
            if following is not None and following.is_punct('('):
                return 'a call to ' + name
            if '.' in name:
                return 'a reference to ' + name
            if name in ('undefined', 'null'):
                return name
            return 'the identifier ' + name
        if token.kind == 'string':
            return 'a string'
        if token.kind == 'number':
            return 'a number'
        if token.kind == 'template':
            return 'a template literal (backticks)'
        if token.kind == 'invalid':
            return 'the invalid number %s' % token.value
        if token.is_punct('{'):
            return 'a block ({ ... })'
        if token.is_punct('('):
            return 'a parenthesised expression'
        if token.is_punct('['):
            return 'a nested list'
        return 'an expression starting with "%s"' % token.value

    def expected_value(self, prop):
        kind = self.properties.get(prop)
        if kind in ('color', 'url', 'string'):
            return 'a string literal'
        if kind == 'bool':
            return 'true or false'
        if kind == 'stringlist':
            return 'a list of string literals'
        if kind in ('int', 'real'):
            return 'a number'
        return 'a literal'

    def value_hint(self, prop):
        kind = self.properties.get(prop)
        if kind == 'color':
            return 'Write a color string, for example "#003366".'
        if kind == 'url':
            return 'Write "logo.svg"; the path is relative to Branding.qml.'
        if kind == 'string':
            return 'Write a string, for example "My Font".'
        if kind == 'bool':
            return 'Write true or false.'
        if kind == 'stringlist':
            return 'Write a list of strings, for example ["MyFont-Regular.ttf"].'
        if kind == 'int':
            return 'Write a number, for example 10.'
        if kind == 'real':
            return 'Write a number, for example 0.5.'
        return 'Write a literal value.'

    def parse_imports(self):
        seen = {}
        while self.peek() is not None:
            token = self.peek()
            if token.is_ident('pragma'):
                self.error(token, None, 'pragma is not allowed in a Branding file. Remove it.')
                self.skip_line(token.line)
                continue
            if not token.is_ident('import'):
                break
            self.pos += 1
            module = self.peek()
            if module is None or module.line != token.line:
                self.error(token, None, 'import without a module name. Write "import Victron.Branding".')
                continue
            if module.kind == 'string':
                self.error(module, None, 'importing a file or directory ("%s") is not allowed. A Branding file '
                           'may import only %s.' % (module.value, ', '.join(BRANDING_IMPORTS)))
                self.skip_line(token.line)
                continue
            if module.kind != 'ident':
                self.error(module, None, 'invalid import. Write "import Victron.Branding".')
                self.skip_line(token.line)
                continue
            name = self.read_dotted_name()
            version = self.peek()
            if version is not None and version.line == token.line and version.kind == 'number':
                self.pos += 1
            qualifier = self.peek()
            if qualifier is not None and qualifier.line == token.line and qualifier.is_ident('as'):
                self.error(qualifier, None, 'qualified imports ("as") are not allowed. Remove "as" and '
                           'the qualifier, so that the root object is written as Branding.')
                self.pos += 1
                if self.peek() is not None and self.peek().line == token.line and self.peek().kind == 'ident':
                    self.pos += 1
            if self.peek() is not None and self.peek().line == token.line and self.peek().is_punct(';'):
                self.pos += 1
            if self.peek() is not None and self.peek().line == token.line:
                self.error(self.peek(), None, 'unexpected "%s" after the import.' % self.peek().value)
                self.skip_line(token.line)
            if name not in BRANDING_IMPORTS:
                self.error(module, None, 'importing %s is not allowed. A Branding file may import only %s.'
                           % (name, ', '.join(BRANDING_IMPORTS)))
            elif name in seen:
                self.error(module, None, '%s is imported more than once (first on line %d). Remove the '
                           'repeated import.' % (name, seen[name].line))
            else:
                seen[name] = module
        if 'Victron.Branding' not in seen:
            first = self.tokens[0] if self.tokens else None
            line, col = (first.line, first.col) if first is not None else (1, 1)
            self.errors.append((line, col, None, 'missing "import Victron.Branding".'))

    def parse_root(self):
        token = self.peek()
        if token is None:
            self.error(None, None, 'expected the Branding object, for example Branding { color_brand: "#003366" }.')
            return
        if token.kind != 'ident':
            self.error(token, None, 'expected the Branding object, found "%s".' % token.value)
            return
        name = self.read_dotted_name()
        if name != 'Branding':
            self.error(token, None, 'the root object must be Branding, found %s.' % name)
        opening = self.peek()
        if opening is None or not opening.is_punct('{'):
            self.error(opening, None, 'expected "{" after %s.' % name)
            return
        self.pos += 1
        self.parse_body(name == 'Branding')
        extra = self.peek()
        if extra is not None:
            self.error(extra, None, 'only one root object is allowed. Remove everything after the '
                       'closing "}" of Branding.')

    def parse_body(self, check_properties):
        while True:
            token = self.peek()
            if token is None:
                self.error(None, None, 'missing the closing "}" of Branding.')
                return
            if token.is_punct('}'):
                self.pos += 1
                return
            if token.kind != 'ident':
                self.error(token, None, 'unexpected "%s". Expected a property assignment, for example '
                           'color_brand: "#003366".' % token.value)
                self.skip_statement()
                continue
            following = self.peek(1)
            word = token.value
            colon = following is not None and following.is_punct(':')
            if word in BRANDING_DECLARATION_KEYWORDS and not colon:
                self.error(token, None, '"%s" declarations are not allowed in a Branding file. Only '
                           'assignments to Branding properties are allowed.' % word)
                self.skip_statement()
            elif word == 'id' and colon:
                self.error(token, None, 'id is not allowed in a Branding file. Remove it.')
                self.skip_statement()
            elif following is not None and following.is_punct('.'):
                saved = self.pos
                name = self.read_dotted_name()
                self.pos = saved
                self.error(token, name, 'attached and grouped properties (such as Component.onCompleted) '
                           'are not allowed in a Branding file. Remove it.')
                self.skip_statement()
            elif following is not None and following.is_ident('on'):
                self.error(token, None, '"%s on ..." is not allowed in a Branding file. Remove it.' % word)
                self.skip_statement()
            elif following is not None and following.is_punct('{'):
                self.error(token, None, 'child objects (%s { }) are not allowed in a Branding file. '
                           'Remove it.' % word)
                self.skip_statement()
            elif not colon:
                self.error(token, word, 'expected ":" after the property name.')
                self.skip_statement()
            else:
                self.parse_assignment(token, check_properties)

    def parse_assignment(self, token, check_properties):
        prop = token.value
        self.pos += 2
        known = prop in self.properties
        if not known:
            if not check_properties:
                pass
            elif _SIGNAL_HANDLER_RE.match(prop):
                self.error(token, prop, 'signal handlers are not allowed in a Branding file. Remove it.')
            else:
                matches = difflib.get_close_matches(prop, list(self.properties), n=1)
                hint = (' Did you mean %s?' % matches[0]) if matches else ''
                self.error(token, prop, 'Branding has no property with this name.' + hint)
            self.skip_statement()
            return
        value = self.parse_value(prop)
        if value is None:
            return
        if prop in self.values:
            self.error(token, prop, 'assigned more than once (first on line %d). Remove one of the '
                       'assignments.' % self.values[prop][2].line)
            return
        kind = self.properties[prop]
        expected_kinds = {'color': 'string', 'url': 'string', 'string': 'string', 'bool': 'bool',
                          'stringlist': 'list', 'int': 'number', 'real': 'number'}
        if expected_kinds.get(kind) != value[0]:
            if value[0] == 'bool':
                found = 'true' if value[1] else 'false'
            else:
                found = {'string': 'a string', 'list': 'a list', 'number': 'a number'}[value[0]]
            self.error(value[2], prop, 'expected %s, found %s. %s'
                       % (self.expected_value(prop), found, self.value_hint(prop)))
            return
        self.values[prop] = value

    def parse_value(self, prop):
        """Parses a literal value. Returns (kind, value, token), or None after reporting an error."""
        token = self.peek()
        if token is None or token.is_punct('}') or token.is_punct(';'):
            self.error(token, prop, 'missing value. ' + self.value_hint(prop))
            self.skip_statement()
            return None
        last = token
        if token.kind == 'string':
            result = ('string', token.value, token)
            self.pos += 1
        elif token.kind == 'number':
            result = ('number', token.value, token)
            self.pos += 1
        elif token.is_punct('-') and self.peek(1) is not None and self.peek(1).kind == 'number':
            last = self.peek(1)
            result = ('number', -last.value, token)
            self.pos += 2
        elif token.is_ident('true') or token.is_ident('false'):
            result = ('bool', token.value == 'true', token)
            self.pos += 1
        elif token.is_punct('['):
            result = self.parse_list(prop)
            if result is None:
                return None
            last = self.tokens[self.pos - 1]
        else:
            self.error(token, prop, 'expected %s, found %s. %s'
                       % (self.expected_value(prop), self.describe_expression(), self.value_hint(prop)))
            self.skip_statement()
            return None

        following = self.peek()
        if following is None or following.is_punct('}'):
            return result
        if following.is_punct(';'):
            self.pos += 1
            return result
        if following.kind == 'ident' and following.line > last.line:
            return result
        found = 'a string' if following.kind == 'string' else '"%s"' % following.value
        self.error(token, prop, 'expected %s, found an expression (%s follows the value). The value must '
                   'be a single literal. %s' % (self.expected_value(prop), found, self.value_hint(prop)))
        self.skip_statement()
        return None

    def parse_list(self, prop):
        opening = self.peek()
        self.pos += 1
        items = []
        while True:
            token = self.peek()
            if token is None:
                self.error(opening, prop, 'the list is not closed. Add the closing "]".')
                return None
            if token.is_punct(']'):
                self.pos += 1
                return ('list', items, opening)
            if token.kind != 'string':
                self.error(token, prop, 'list entries must be string literals, found %s. %s'
                           % (self.describe_expression(), self.value_hint(prop)))
                self.skip_to_list_end()
                return None
            items.append((token.value, token))
            self.pos += 1
            separator = self.peek()
            if separator is not None and separator.is_punct(','):
                self.pos += 1
            elif separator is None or not separator.is_punct(']'):
                self.error(separator or token, prop, 'list entries must be string literals separated by ",". %s'
                           % self.value_hint(prop))
                self.skip_to_list_end()
                return None

    def skip_to_list_end(self):
        depth = 1
        while self.pos < len(self.tokens) and depth > 0:
            token = self.tokens[self.pos]
            self.pos += 1
            if token.kind == 'punct' and token.value in '([{':
                depth += 1
            elif token.kind == 'punct' and token.value in ')]}':
                depth -= 1
        if self.peek() is not None and self.peek().is_punct(';'):
            self.pos += 1

    def add_file(self, path):
        packed = os.path.normpath(os.path.join(self.base_dir, path)).replace('\\', '/')
        if packed not in self.files:
            self.files.append(packed)

    def check_values(self):
        fonts = {}
        for prop, (value_kind, value, token) in self.values.items():
            kind = self.properties[prop]
            if kind == 'color':
                message = check_branding_color(value)
                if message:
                    self.error(token, prop, message)
            elif kind == 'url':
                message = check_branding_path(value, BRANDING_IMAGE_EXTENSIONS, self.file_exists)
                if message:
                    self.error(token, prop, message)
                else:
                    self.add_file(value)
            elif kind == 'string':
                if value.strip() == '':
                    self.error(token, prop, 'must not be empty. Remove the assignment to keep the built-in value.')
            elif prop == BRANDING_BACKGROUND_FACTOR_PROPERTY:
                self.check_background_factor(prop, value, token)
            elif kind == 'stringlist' and prop in BRANDING_FONT_FILE_PROPERTIES:
                for entry, entry_token in value:
                    message = check_branding_path(entry, BRANDING_FONT_EXTENSIONS, self.file_exists)
                    key = os.path.normpath(entry).lower()
                    if message:
                        self.error(entry_token, prop, message)
                    elif key in fonts:
                        self.error(entry_token, prop, '"%s" is listed more than once. Remove the repeated '
                                   'entry.' % entry)
                    else:
                        fonts[key] = entry_token
                        self.add_file(entry)

    def check_background_factor(self, prop, value, token):
        # The same rule as the loader: rounded to thousandths (half up), more than 0 and at most 2.
        if not math.isfinite(value) or value <= 0 or value > BRANDING_MAXIMUM_BACKGROUND_FACTOR \
                or math.floor(value * 1000 + 0.5) < 1:
            self.error(token, prop, 'must be more than 0 and at most %d, for example 0.5. Remove the '
                       'assignment to keep the default, 1.' % BRANDING_MAXIMUM_BACKGROUND_FACTOR)
        elif BRANDING_BACKGROUND_PRIMARY_PROPERTY not in self.values:
            self.warning(token, prop, 'has no effect unless this file also sets %s: the factor is read only '
                         'from the Branding whose %s is used.'
                         % (BRANDING_BACKGROUND_PRIMARY_PROPERTY, BRANDING_BACKGROUND_PRIMARY_PROPERTY))


def check_branding_text(filename, text, properties, file_exists, warnings=None, assigned=None):
    """Runs the literal-only check on the text of a Branding QML file.

    filename is the file's path, used in messages and to locate the files it refers to.
    file_exists(path) returns whether a file exists at path, relative to the Branding file's
    directory, with "/" separators.

    Returns (errors, files): the formatted error messages, and the files that the Branding
    file refers to (relative to the current directory, with "/" separators), to be packed.
    If warnings is a list, the formatted warnings are appended to it.
    If assigned is a list, the names of the properties that the file sets are appended to it.
    """
    checker = BrandingChecker(filename, text, properties, file_exists)
    errors = checker.check()
    if warnings is not None:
        warnings.extend(checker.formatted_warnings())
    if assigned is not None:
        assigned.extend(checker.values.keys())
    return errors, checker.files


def check_branding_file(path, properties, warnings=None, assigned=None):
    """Reads a Branding QML file and runs check_branding_text on it."""
    try:
        with open(path, encoding='utf-8') as file:
            text = file.read()
    except UnicodeDecodeError:
        return ['%s:1:1: the file is not valid UTF-8.' % path], []
    base_dir = os.path.dirname(path)
    return check_branding_text(path, text, properties,
                               lambda relative_path: _exists_with_exact_case(base_dir, relative_path), warnings,
                               assigned)


def load_branding_property_list():
    """Reads the Branding property list that tools/brandingproperties.py generates."""
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), BRANDING_PROPERTIES_FILE)
    try:
        with open(path, encoding='utf-8') as file:
            return json.load(file)
    except (OSError, ValueError) as e:
        print("\n\nERROR: cannot read the Branding property list %s: %s" % (path, e))
        sys.exit(1)


def branding_property_types(property_list):
    return {prop['name']: prop['type'] for prop in property_list['properties']}


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
    path = shutil.which(name)
    if path:
        return path
    lreleasePath = shutil.which('lrelease')
    if lreleasePath:
        path = shutil.which(name, path=os.path.dirname(lreleasePath))
        if path:
            return path
        libexecPath = lreleasePath.replace('/usr/bin/lrelease', '/usr/libexec/' + name)
        if os.path.isfile(libexecPath):
            return libexecPath
    return None


def run_qmllint(brandingPath, importPath):
    if not os.path.isfile(os.path.join(importPath, 'Victron', 'Branding', 'qmldir')):
        print("    note: Victron.Branding module not found under " + importPath + ", skipping qmllint")
        return
    qmllintPath = find_qt_tool('qmllint')
    if qmllintPath is None:
        print("    note: qmllint not found, skipping it (the literal-only check has passed)")
        return
    result = subprocess.run([qmllintPath, '-I', importPath, brandingPath], capture_output=True, text=True)
    output = (result.stdout + result.stderr).strip()
    if output:
        print("    qmllint output:", output)
    if result.returncode != 0:
        print("\n\nERROR: qmllint reported problems in " + brandingPath)
        sys.exit(1)


def check_branding(brandingPath, importPath):
    """Checks the Branding file. Returns the paths of the files to pack for it, and the
    plugin's requiredBrandingVersion."""
    if not brandingPath.endswith('.qml'):
        print("\n\nERROR: Invalid branding file specified, must be a .qml file")
        sys.exit(1)
    pathError = check_branding_path(brandingPath, ('.qml',),
                                    lambda relative_path: _exists_with_exact_case('.', relative_path))
    if pathError:
        print("\n\nERROR: Invalid branding file: " + pathError.replace('Branding.qml', 'the plugin directory'))
        sys.exit(1)
    warnings = []
    assigned = []
    propertyList = load_branding_property_list()
    errors, files = check_branding_file(brandingPath, branding_property_types(propertyList), warnings, assigned)
    for warning in warnings:
        print("    warning: " + warning)
    if errors:
        print("\n\nERROR: " + brandingPath + " failed the literal-only check:")
        for error in errors:
            print(error)
        sys.exit(1)
    run_qmllint(brandingPath, importPath)
    return files, required_branding_version(propertyList, assigned)


def install_plugin(name, host):
    """Development helper: copies the compiled plugin to a GX device and enables it."""
    if not re.fullmatch(r'[A-Za-z0-9_.\-]+', name) or name in ('.', '..'):
        print("\n\nERROR: --install needs a plugin name made of letters, digits, '_', '-' and '.'")
        sys.exit(1)
    if host.startswith('-'):
        print("\n\nERROR: Invalid --install host: " + host)
        sys.exit(1)
    available = '/data/apps/available/' + name
    commands = [
        ['ssh', host, 'mkdir -p ' + shlex.quote(available + '/gui-v2')],
        ['scp', name + '.json', host + ':' + available + '/gui-v2/'],
        ['ssh', host, 'mkdir -p /data/apps/enabled && ln -sfn ' + shlex.quote(available) + ' '
            + shlex.quote('/data/apps/enabled/' + name)],
    ]
    for cmd in commands:
        try:
            subprocess.run(cmd, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            print("\n\nERROR: install failed: " + str(e))
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
    # Keep the order, but list each file once (branding files may also be collected as top-level files).
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
    if shutil.which('rcc'):
        rccPath = 'rcc'
    else:
        lreleasePath = shutil.which('lrelease')
        rccPath = lreleasePath.replace('/usr/bin/lrelease', '/usr/libexec/rcc')

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
        print("    rcc error:", e.stderr, file=sys.stderr)
    except FileNotFoundError:
        print("    rcc not found, perhaps generate .rcc manually from .qrc then pass it with --rcc <filename>")

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
                        requiredBrandingVersion=''):
    dataDict = {
        "name": name,
        "version": version,
        "minRequiredVersion": minRequiredVersion,
        "maxRequiredVersion": maxRequiredVersion,
    }
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

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='gui-v2-plugin-compiler',
        description='Compiles plugins for gui-v2 into json files')

    parser.add_argument('--rcc', nargs='?', default='') # debugging only...
    parser.add_argument('-n', '--name', default=os.path.basename(os.getcwd()), help='The name of your plugin')
    parser.add_argument('-v', '--version', default='1.0', help='The version of your plugin')
    parser.add_argument('-z', '--min-required-version', default='', help='The minimum gui-v2 version required for the plugin')
    parser.add_argument('-x', '--max-required-version', default='', help='The maximum gui-v2 version compatible with this plugin')
    parser.add_argument('-s', '--settings', default='', help='The main settings page .qml associated with your plugin')
    parser.add_argument('-d', '--devicelist', required=False, nargs='+', action='append', help='Triplet of product id, settings page .qml, and title text (or translation id)')
    parser.add_argument('-g', '--navigation', default='')
    parser.add_argument('-q', '--quickaccess', default='')
    parser.add_argument('-c', '--card', default='')
    parser.add_argument('-b', '--branding', default='', help='The Branding .qml file of an OEM branding plugin')
    parser.add_argument('--qml-import-path', default=os.path.dirname(os.path.abspath(__file__)),
                        help='The directory containing Victron/Branding/qmldir, used by qmllint '
                             '(default: the directory of this script)')
    parser.add_argument('--install', default='', metavar='HOST',
                        help='Development only: copy the compiled plugin to a GX device over ssh and enable it')
    parser.add_argument('-f', '--filter-empty-sources', action='store_true', help='Strip empty source entries from .ts files')

    args = parser.parse_args()

    if args.name != os.path.basename(os.getcwd()):
        print("\n\nERROR: plugin name does not match working directory name!")
        sys.exit(1)

    # The branding check runs first, so that a rejected Branding file never produces an RCC.
    brandingFiles = []
    requiredBrandingVersion = ''
    if len(args.branding) > 0:
        print("--- checking branding")
        brandingFiles, requiredBrandingVersion = check_branding(args.branding, args.qml_import_path)
        brandingFiles.append(os.path.normpath(args.branding).replace('\\', '/'))

    imageFiles = collect_filenames('.', '.svg')
    imageFiles += collect_filenames('.', '.png')
    fontFiles = collect_filenames('.', '.ttf')
    fontFiles += collect_filenames('.', '.otf')
    qmlFiles = collect_filenames('.', '.qml')
    tsFiles = collect_filenames('.', '.ts')

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
    if len(args.card) > 0:
        print("TODO: card...")
    if len(args.branding) > 0:
        brandingIntegration = {
            "type": BRANDING_INTEGRATION_TYPE,
            "url": "qrc:/" + args.name + "/" + brandingFiles[-1]
        }
        integrations.append(brandingIntegration)

    print("--- writing compiled json")
    write_compiled_json(args.name, args.version, args.min_required_version, args.max_required_version, translations,
                        integrations, resource, requiredBrandingVersion)

    if len(args.install) > 0:
        print("--- installing to " + args.install)
        install_plugin(args.name, args.install)

    print("--- done!")
    sys.exit(0)
