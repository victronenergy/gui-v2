import json
import os
import sys
import subprocess
import argparse
import base64
import re
import shlex
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


def _load_json_next_to_script(file_name, description):
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), file_name)
    try:
        with open(path, encoding='utf-8') as file:
            return json.load(file)
    except (OSError, ValueError) as e:
        print("\n\nERROR: cannot read the %s %s: %s" % (description, path, e))
        sys.exit(1)


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
    """Checks the Branding file. Returns image and font files to pack, and the
    plugin's requiredBrandingVersion."""
    if not brandingPath.endswith('.qml'):
        print("\n\nERROR: Invalid branding file specified, must be a .qml file")
        sys.exit(1)
    pathError = check_branding_path(brandingPath, ('.qml',),
                                    lambda relative_path: _exists_with_exact_case('.', relative_path))
    if pathError:
        print("\n\nERROR: Invalid branding file: " + pathError.replace('Branding.qml', 'the plugin directory'))
        sys.exit(1)
    assigned = []
    propertyList = load_branding_property_list()
    names = [prop['name'] for prop in propertyList['properties']]
    errors, files = check_branding_file(brandingPath, names, assigned)
    if errors:
        print("\n\nERROR: " + brandingPath + " failed the branding check:")
        for error in errors:
            print(error)
        sys.exit(1)
    run_qmllint(brandingPath, importPath)
    return branding_packed_paths(brandingPath, files), required_branding_version(propertyList, assigned)


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
