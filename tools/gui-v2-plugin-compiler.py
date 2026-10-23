import bisect
import json
import os
import re
import sys
import subprocess
import argparse
import base64
import shutil
import xml.etree.ElementTree as ET

# The Victron.GuiPlugins API record: each type and member, with the version that added it. It is
# generated from the module's sources by tools/guipluginsapi.py, and installed next to this script.
GUIPLUGINS_API_FILE = 'guiplugins-api.json'

_NUMBER_RE = re.compile(r'(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?')
_HANDLER_NAME_RE = re.compile(r'on([A-Z_][\w$]*)$')
_IDENTIFIER_RE = re.compile(r'[A-Za-z_$][\w$]*')
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


def _parse_version(text):
    return tuple(int(part) for part in text.split('.'))


def guiplugins_names(text):
    """Reads the text of a QML file. Returns (imports, names): whether the file imports
    Victron.GuiPlugins, and the set of names that the file uses. A signal handler name also uses
    the signal (onClicked uses clicked), and a change handler also uses the property
    (onCheckedChanged uses checked). Names inside template strings count; names inside other
    strings and comments do not."""
    tokens = tokenize_qml(text)[0]
    imports = False
    names = set()
    for i, token in enumerate(tokens):
        if token.kind == 'template':
            names.update(_IDENTIFIER_RE.findall(token.value))
            continue
        if token.kind != 'ident':
            continue
        names.add(token.value)
        handler = _HANDLER_NAME_RE.match(token.value)
        if handler:
            signal = handler.group(1)[0].lower() + handler.group(1)[1:]
            names.add(signal)
            if signal.endswith('Changed'):
                names.add(signal[:-len('Changed')])
        if (token.value == 'import' and i + 3 < len(tokens) and tokens[i + 1].is_ident('Victron')
                and tokens[i + 2].is_punct('.') and tokens[i + 3].is_ident('GuiPlugins')
                and not (i + 4 < len(tokens) and tokens[i + 4].is_punct('.'))):
            imports = True
    return imports, names


def _member_type_names(member):
    """Returns the names in a member's type, parameter types and return type, such as PluginUnit
    in "list<PluginUnit.Unit>"."""
    types = [member.get('type', ''), member.get('returns', '')]
    types += [parameter.split(':')[-1] for parameter in member.get('parameters', [])]
    return {name for type_text in types for name in _IDENTIFIER_RE.findall(type_text)}


def required_guiplugins_version(api, names):
    """Returns the lowest Victron.GuiPlugins version, as "major.minor", that has every type and
    member that a plugin with these names may use. Also returns the uses that need that version
    (such as "PluginListSwitch.checked"), if it is newer than <major>.0.

    It cannot tell which object a name refers to, so it counts a name as a use of every member
    with that name on a type that the plugin can reach: the types that it names, their base
    types, and the types of the members that it uses. So the version is never too old, but it is
    newer than needed if one of the plugin's own names matches a newer member."""
    types = {apiType['name']: apiType for apiType in api['types']}
    floor = (_parse_version(api['version'])[0], 0)
    uses = []
    reached = {name for name in names if name in types}
    for name in reached:
        uses.append((_parse_version(types[name]['since']), name))
    pending = sorted(reached)
    while pending:
        apiType = types[pending.pop()]
        nextTypes = {apiType.get('base', '')}
        for section in ('properties', 'signals', 'methods'):
            for member in apiType.get(section, []):
                if member['name'] in names:
                    uses.append((_parse_version(member['since']), apiType['name'] + '.' + member['name']))
                    nextTypes |= _member_type_names(member)
        for enum in apiType.get('enums', []):
            for item in [enum] + enum['values']:
                if item['name'] in names:
                    uses.append((_parse_version(item['since']), apiType['name'] + '.' + item['name']))
        for name in sorted(nextTypes):
            if name in types and name not in reached:
                reached.add(name)
                pending.append(name)
    version = max([floor] + [use[0] for use in uses])
    needs = sorted(use[1] for use in uses if use[0] == version and version > floor)
    return '%d.%d' % version, needs


def check_guiplugins_version(qmlFiles):
    """Returns the plugin's requiredGuiPluginsVersion, worked out from its QML files, or '' if
    none of them imports Victron.GuiPlugins."""
    imports = False
    names = set()
    for path in qmlFiles:
        with open(path, encoding='utf-8', errors='replace') as file:
            fileImports, fileNames = guiplugins_names(file.read())
        imports = imports or fileImports
        names |= fileNames
    if not imports:
        print("    no file imports Victron.GuiPlugins")
        return ''
    version, needs = required_guiplugins_version(load_guiplugins_api(), names)
    print("    requiredGuiPluginsVersion: " + version + (" (for " + ", ".join(needs) + ")" if needs else ""))
    return version


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
    allFiles = qmlFiles + qmFiles + imageFiles
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
                        requiredGuiPluginsVersion=''):
    dataDict = {
        "name": name,
        "version": version,
        "minRequiredVersion": minRequiredVersion,
        "maxRequiredVersion": maxRequiredVersion,
    }
    if requiredGuiPluginsVersion:
        dataDict["requiredGuiPluginsVersion"] = requiredGuiPluginsVersion
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
    parser.add_argument('-f', '--filter-empty-sources', action='store_true', help='Strip empty source entries from .ts files')

    args = parser.parse_args()

    if args.name != os.path.basename(os.getcwd()):
        print("\n\nERROR: plugin name does not match working directory name!")
        sys.exit(1)

    imageFiles = collect_filenames('.', '.svg')
    imageFiles += collect_filenames('.', '.png')
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
    write_qrc(qmlFiles, qmFiles, imageFiles, args.name)

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

    print("--- writing compiled json")
    write_compiled_json(args.name, args.version, args.min_required_version, args.max_required_version, translations,
                        integrations, resource, requiredGuiPluginsVersion)

    print("--- done!")
    sys.exit(0)
