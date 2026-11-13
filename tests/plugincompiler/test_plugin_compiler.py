#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/gui-v2-plugin-compiler.py: the requiredGuiPluginsVersion that it writes,
# the warning it prints for a deprecated type or member, the Branding import and name checks,
# the image and font files it packs, the requiredBrandingVersion that it writes, the card
# integration that it writes for each --card option, and the escaping of file names in the
# resource URLs and the .qrc file that it writes.

import contextlib
import copy
import importlib.util
import io
import json
import os
import subprocess
import sys
import unittest
import xml.etree.ElementTree as ET
from unittest import mock
from unittest.mock import mock_open, patch

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')
EXAMPLES_DIR = os.path.join(TOOLS_DIR, '..', 'examples')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('plugincompiler', os.path.join(TOOLS_DIR, 'gui-v2-plugin-compiler.py'))
compiler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compiler)

def tokens(text):
    return compiler.tokenize_qml(text)[0]


class RequiredGuiPluginsVersionTest(unittest.TestCase):
    API = {
        'module': 'Victron.GuiPlugins',
        'version': '1.3',
        'types': [
            {'name': 'PluginListItem', 'since': '1.0', 'properties': [
                {'name': 'text', 'type': 'string', 'since': '1.0'},
                {'name': 'caption', 'type': 'string', 'since': '1.2'},
            ]},
            {'name': 'PluginListSwitch', 'base': 'PluginListItem', 'since': '1.0',
             'properties': [{'name': 'checked', 'type': 'bool', 'since': '1.1'}],
             'signals': [{'name': 'toggled', 'parameters': [], 'since': '1.3'}]},
            {'name': 'PluginListGauge', 'base': 'PluginListItem', 'since': '1.2'},
            {'name': 'PluginDataItem', 'since': '1.0', 'methods': [
                {'name': 'setValue', 'parameters': ['value: var'], 'returns': 'void', 'since': '1.1'},
            ]},
            {'name': 'PluginReading', 'since': '1.0', 'properties': [
                {'name': 'dataItem', 'type': 'PluginDataItem', 'since': '1.0'},
            ]},
            {'name': 'PluginUnit', 'since': '1.0', 'enums': [
                {'name': 'Unit', 'since': '1.0', 'values': [
                    {'name': 'Volt', 'value': 1, 'since': '1.0'},
                    {'name': 'Watt', 'value': 2, 'since': '1.2'},
                ]},
            ]},
            {'name': 'PluginWords', 'since': '1.0', 'properties': [
                {'name': 'yes', 'type': 'string', 'since': '1.0'},
                {'name': 'reset', 'type': 'string', 'since': '1.3'},
            ]},
            {'name': 'PluginDeviceModel', 'base': 'QAbstractListModel', 'since': '1.1', 'roles': [
                {'name': 'serviceUid', 'type': 'string', 'since': '1.1'},
                {'name': 'productId', 'type': 'int', 'since': '1.2'},
            ]},
        ],
    }

    def test_import(self):
        cases = {
            'import Victron.GuiPlugins': True,
            'import Victron.GuiPlugins 1.0': True,
            'import Victron.GuiPlugins as Plugins': True,
            'import QtQuick\nimport Victron.GuiPlugins\nItem {}': True,
            'import QtQuick\nItem {}': False,
            'import Victron.VenusOS': False,
            'import Victron.GuiPlugins.Other': False,
            '// import Victron.GuiPlugins': False,
        }
        for qml, expected in cases.items():
            with self.subTest(qml=qml):
                self.assertEqual(compiler.guiplugins_names(tokens(qml))[0], expected)

    def test_lowest_version_that_has_every_use(self):
        cases = {
            'PluginReading {}': ('1.0', []),
            'PluginListGauge {}': ('1.2', ['PluginListGauge']),
            'PluginListSwitch { checked: true }': ('1.1', ['PluginListSwitch.checked']),
            'PluginListSwitch { caption: "x" }': ('1.2', ['PluginListItem.caption']),
            'PluginListGauge { caption: "x" }': ('1.2', ['PluginListGauge', 'PluginListItem.caption']),
            'PluginListSwitch { onToggled: {} }': ('1.3', ['PluginListSwitch.toggled']),
            'PluginListSwitch { onCheckedChanged: {} }': ('1.1', ['PluginListSwitch.checked']),
            'PluginListSwitch { Component.onCompleted: checkedChanged.connect(function() {}) }':
                ('1.1', ['PluginListSwitch.checked']),
            'PluginReading { Component.onCompleted: dataItem.setValue(1) }': ('1.1', ['PluginDataItem.setValue']),
            'PluginListItem { text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: PluginWords["reset"] }': ('1.3', ['PluginWords.reset']),
            "PluginListItem { text: PluginWords['reset'] }": ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: `${PluginWords["reset"]}` }': ('1.3', ['PluginWords.reset']),
            # Optional chaining does not hide a constant bracket key. A dynamic key still does not
            # count, and '??' is not an optional chain.
            'PluginListItem { text: PluginWords?.["reset"] }': ('1.3', ['PluginWords.reset']),
            "PluginListItem { text: PluginWords?.['reset'] }": ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: PluginWords?. ["reset"] }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: `${PluginWords?.["reset"]}` }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: PluginWords?.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: PluginWords?.[word] }': ('1.0', []),
            'PluginListItem { text: PluginWords??["reset"] }': ('1.0', []),
            'PluginListItem { text: PluginWords?.["not-a-name"] }': ('1.0', []),
            'PluginListItem { property int unit: PluginUnit.Watt }': ('1.2', ['PluginUnit.Watt']),
            'PluginListItem { text: `${PluginWords.reset}` }': ('1.3', ['PluginWords.reset']),
            # A key that is not a constant is not a member name. Nor is the same text in a string.
            'PluginListItem { text: PluginWords[word] }': ('1.0', []),
            'PluginListItem { text: "PluginWords[\\"reset\\"]" }': ('1.0', []),
            # Names of members on types that the plugin does not use, or in strings and comments.
            'PluginListItem { property bool checked; function setValue() {} }': ('1.0', []),
            'PluginListItem { text: "PluginListGauge" } // PluginWords.reset': ('1.0', []),
            # A regex is not a comment. Markers inside it must not hide a later name.
            # A slash after a value is division, so that name still counts.
            'PluginListItem { text: /\\// ; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: /[/*]/ ; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: /[]/ ; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: /[^]/ ; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: /[]]/ ; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            # A regex may follow a control header. A / after a call or a group is division.
            'PluginListItem { Component.onCompleted: if (ready) /\\//.test(path); text: PluginWords.reset }':
                ('1.3', ['PluginWords.reset']),
            'PluginListItem { Component.onCompleted: for (;;) /\\//.test(path); text: PluginWords.reset }':
                ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: (width) / PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: foo(width) / PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: obj.if(width) / PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: width / PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: /unterminated\n text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            # A keyword used as a member is not a keyword, so / after it is division.
            # return with no dot still starts a regex, and the name inside it does not count.
            'PluginListItem { property real x: d.x / PluginWords.reset / 2 }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: d.of / PluginWords.reset / 2 }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property real x: d?.of / PluginWords.reset / 2 }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { text: return /PluginWords.reset/ }': ('1.0', []),
            # A quoted string may span lines. A name inside it does not count. A name after it does.
            'PluginListItem { text: "line 1\nPluginWords.reset\nline2" }': ('1.0', []),
            'PluginListItem { text: "line 1\nline2"; text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            # A model's role names are members, so a delegate that reads a newer one needs its version.
            'Repeater { model: PluginDeviceModel {} delegate: Item { required property string serviceUid } }':
                ('1.1', ['PluginDeviceModel', 'PluginDeviceModel.serviceUid']),
            'Repeater { model: PluginDeviceModel {} delegate: Item { required property int productId } }':
                ('1.2', ['PluginDeviceModel.productId']),
        }
        for qml, expected in cases.items():
            with self.subTest(qml=qml):
                imports, names = compiler.guiplugins_names(tokens('import Victron.GuiPlugins\n' + qml))
                self.assertTrue(imports)
                self.assertEqual(compiler.required_guiplugins_version(self.API, names), expected)

    def test_examples(self):
        """Examples that do not use a newer type still work with the first version.

        FullApiExample shows every type, so it needs the current module version.
        """
        api = compiler.load_guiplugins_api()
        firstVersion = api['version'].split('.')[0] + '.0'
        expected = {
            'DeviceListExample': firstVersion,
            'FullApiExample': api['version'],
            'SimpleExample': firstVersion,
            'SimpleTrExample': firstVersion,
        }
        for name, version in expected.items():
            with self.subTest(example=name):
                directory = os.path.join(EXAMPLES_DIR, name)
                paths = [os.path.join(directory, file) for file in os.listdir(directory) if file.endswith('.qml')]
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(compiler.check_guiplugins_version(paths), version)

    def test_no_import(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(compiler.check_guiplugins_version([]), '')

    def test_versioned_import_is_rejected(self):
        self.assertIsNone(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins\nItem {}')))
        self.assertIsNone(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins as Plugins')))
        self.assertIsNone(compiler.versioned_guiplugins_import(tokens('// import Victron.GuiPlugins 1.0')))
        self.assertIsNone(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins.Other 1.0')))
        self.assertEqual(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins 1.3')),
                         'import Victron.GuiPlugins 1.3')
        self.assertEqual(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins 1.10')),
                         'import Victron.GuiPlugins 1.10')
        self.assertEqual(compiler.versioned_guiplugins_import(tokens('import Victron.GuiPlugins 1.0 as Plugins')),
                         'import Victron.GuiPlugins 1.0')
        with self.assertRaises(SystemExit) as raised:
            with contextlib.redirect_stdout(io.StringIO()) as out:
                compiler.reject_versioned_import('Page.qml', tokens('import Victron.GuiPlugins 1.0\nItem {}'))
        self.assertEqual(raised.exception.code, 1)
        self.assertIn('Page.qml', out.getvalue())
        self.assertIn('without a version', out.getvalue())
        with self.assertRaises(SystemExit):
            with contextlib.redirect_stdout(io.StringIO()) as out:
                compiler.reject_versioned_import('Page.qml', tokens('import Victron.GuiPlugins 1.10\nItem {}'))
        self.assertIn('import Victron.GuiPlugins 1.10', out.getvalue())

    def test_tokenizer_error_fails_the_compile(self):
        qml = 'import Victron.GuiPlugins\n/* unterminated\nPluginListSwitch {}'
        with self.assertRaises(SystemExit) as raised:
            with mock.patch('builtins.open', mock.mock_open(read_data=qml)), \
                    contextlib.redirect_stdout(io.StringIO()) as output:
                compiler.check_guiplugins_version(['Page.qml'])
        self.assertEqual(raised.exception.code, 1)
        text = output.getvalue()
        self.assertIn('Page.qml', text)
        self.assertIn('line 2, column 1', text)
        self.assertIn('unterminated /* comment', text)

    def test_multiline_string_is_one_string(self):
        parsed, errors, _end = compiler.tokenize_qml('text: "line 1\n           line2"')
        self.assertEqual(errors, [])
        self.assertEqual([token.value for token in parsed if token.kind == 'string'],
                         ['line 1\n           line2'])
        qml = 'import Victron.GuiPlugins\nPluginListItem { text: "no end'
        with self.assertRaises(SystemExit) as raised:
            with mock.patch('builtins.open', mock.mock_open(read_data=qml)), \
                    contextlib.redirect_stdout(io.StringIO()) as output:
                compiler.check_guiplugins_version(['Page.qml'])
        self.assertEqual(raised.exception.code, 1)
        self.assertIn('unterminated string', output.getvalue())

    def test_reached_type_version_counts(self):
        api = copy.deepcopy(self.API)
        next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListItem')['since'] = '1.3'
        _imports, names = compiler.guiplugins_names(tokens('import Victron.GuiPlugins\nPluginListSwitch {}'))
        self.assertEqual(compiler.required_guiplugins_version(api, names), ('1.3', ['PluginListItem']))

    def test_deprecated_use_is_warned(self):
        api = copy.deepcopy(self.API)
        next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListItem')['deprecated'] = True
        switch = next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListSwitch')
        switch['properties'][0]['deprecated'] = True
        words = next(api_type for api_type in api['types'] if api_type['name'] == 'PluginWords')
        next(prop for prop in words['properties'] if prop['name'] == 'reset')['deprecated'] = True

        def uses(qml):
            _imports, names = compiler.guiplugins_names(tokens('import Victron.GuiPlugins\n' + qml))
            return compiler.deprecated_uses(api, names)

        self.assertEqual(uses('PluginListSwitch { checked: true }'),
                         ['PluginListItem', 'PluginListSwitch.checked'])
        self.assertEqual(uses('PluginListItem { text: PluginWords["reset"] }'),
                         ['PluginListItem', 'PluginWords.reset'])
        self.assertEqual(uses('PluginListItem { text: PluginWords[word] }'), ['PluginListItem'])
        self.assertEqual(uses('PluginListGauge {}'), ['PluginListItem'])

        qml = 'import Victron.GuiPlugins\nPluginListSwitch { checked: true }\n'
        with mock.patch.object(compiler, 'load_guiplugins_api', return_value=api), \
                mock.patch('builtins.open', mock.mock_open(read_data=qml)), \
                contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(compiler.check_guiplugins_version(['Page.qml']), '1.1')
        self.assertIn('WARNING: uses deprecated Victron.GuiPlugins API: PluginListItem, PluginListSwitch.checked',
                      output.getvalue())
        self.assertIn('later major version', output.getvalue())


class GxInstallCommandTest(unittest.TestCase):
    def test_connects_as_root_and_enables_the_app(self):
        argv, remote_json = compiler.gx_install_command('OemName', 'root@gx.local', 'id_ed25519')
        self.assertEqual(argv[0], 'ssh')
        self.assertEqual(argv[argv.index('-i') + 1], 'id_ed25519')
        self.assertIn('root@gx.local', argv)
        self.assertNotIn('root@root@gx.local', argv)
        self.assertIn('BatchMode=yes', argv)
        self.assertIn('IdentitiesOnly=yes', argv)
        self.assertEqual(remote_json, '/data/apps/available/OemName/gui-v2/OemName.json')
        script = argv[-1]
        self.assertIn('mkdir -p', script)
        self.assertIn('/data/apps/available/OemName/gui-v2', script)
        self.assertIn('ln -sfn', script)
        self.assertIn('/data/apps/available/OemName', script)
        self.assertIn('/data/apps/enabled/OemName', script)
        self.assertIn('is not a symlink', script)

    def test_plugin_name_rule(self):
        self.assertIsNone(compiler.plugin_name_error('PluginName'))
        self.assertIsNone(compiler.plugin_name_error('Plugin_Name'))
        self.assertIsNone(compiler.plugin_name_error('A'))
        self.assertIsNone(compiler.plugin_name_error('A' + 'b' * 63))
        for name in ('', 'Plugin-Name', '1Plugin', 'Plugin.Name', 'Plugin Name', 'A' + 'b' * 64, '_Plugin', '../Plugin'):
            with self.subTest(name=name):
                self.assertIsNotNone(compiler.plugin_name_error(name))

    def test_rejects_another_user_or_an_unsafe_name(self):
        with self.assertRaises(ValueError):
            compiler.gx_install_command('OemName', 'user@gx.local', 'key')
        with self.assertRaises(ValueError):
            compiler.gx_install_command('OemName', 'gx.local;rm -rf /', 'key')
        with self.assertRaises(ValueError):
            compiler.gx_install_command('../OemName', 'gx.local', 'key')
        with self.assertRaises(ValueError):
            compiler.gx_install_command('Plugin-Name', 'gx.local', 'key')
        argv, remote_json = compiler.gx_install_command('Plugin_Name', 'gx.local', 'key')
        self.assertEqual(remote_json, '/data/apps/available/Plugin_Name/gui-v2/Plugin_Name.json')
        self.assertIn('root@gx.local', argv)

    def test_sends_the_json_on_stdin(self):
        payload = b'{"name":"OemName"}\n'
        with mock.patch.object(compiler.os.path, 'isfile', return_value=True), \
                mock.patch('builtins.open', mock.mock_open(read_data=payload)), \
                mock.patch.object(compiler.subprocess, 'run', return_value=mock.Mock(stderr=b'')) as run, \
                contextlib.redirect_stdout(io.StringIO()):
            compiler.install_on_gx('OemName', 'gx.local', 'id_test', 'OemName.json')
        run.assert_called_once()
        self.assertEqual(run.call_args.kwargs['input'], payload)
        self.assertEqual(run.call_args.args[0][0], 'ssh')
        self.assertIn('root@gx.local', run.call_args.args[0])


class CardIntegrationTest(unittest.TestCase):
    QML_FILES = ['Card.qml', 'OtherCard.qml', 'Card#1.qml']

    def integration(self, args):
        return compiler.card_integration(args, 'Cards', self.QML_FILES)

    def test_fields(self):
        cases = [
            (['Card.qml', '1'], {'type': 5, 'url': 'qrc:/Cards/Card.qml', 'cardType': 1}),
            (['Card.qml', '2'], {'type': 5, 'url': 'qrc:/Cards/Card.qml', 'cardType': 2}),
            (['Card#1.qml', '1'], {'type': 5, 'url': 'qrc:/Cards/Card%231.qml', 'cardType': 1}),
        ]
        for args, integration in cases:
            with self.subTest(args=args):
                self.assertEqual(self.integration(args), integration)

    def test_repeated_options(self):
        options = [['Card.qml', '1'], ['OtherCard.qml', '2'], ['Card.qml', '2']]
        self.assertEqual([self.integration(args) for args in options], [
            {'type': 5, 'url': 'qrc:/Cards/Card.qml', 'cardType': 1},
            {'type': 5, 'url': 'qrc:/Cards/OtherCard.qml', 'cardType': 2},
            {'type': 5, 'url': 'qrc:/Cards/Card.qml', 'cardType': 2},
        ])

    def test_errors(self):
        cases = [
            (['Card.qml'], '--card requires 2 args'),
            (['Card.qml', '1', '2'], '--card requires 2 args'),
            (['Card.qml', 'controls'], 'Card type must be an integer'),
            (['Card.qml', '1.0'], 'Card type must be an integer'),
            (['Card.qml', '0'], 'Card type must be 1 (controls) or 2 (switches)'),
            (['Card.qml', '3'], 'Card type must be 1 (controls) or 2 (switches)'),
            (['Card.txt', '1'], 'Card page must be a .qml file'),
            (['Missing.qml', '1'], 'Card page "Missing.qml" is not a file in the current directory'),
            (['sub/Card.qml', '1'], 'Card page "sub/Card.qml" is not a file in the current directory'),
            (['card.qml', '1'], 'Card page "card.qml" is not a file in the current directory'),
        ]
        for args, message in cases:
            with self.subTest(args=args):
                with contextlib.redirect_stdout(io.StringIO()) as output:
                    with self.assertRaises(SystemExit) as raised:
                        self.integration(args)
                self.assertEqual(raised.exception.code, 1)
                self.assertIn(message, output.getvalue())


class ResourceUrlTest(unittest.TestCase):
    def test_encodes_file_name(self):
        cases = [
            ('Page.qml', 'qrc:/Plugin/Page.qml'),
            ('Page#1.qml', 'qrc:/Plugin/Page%231.qml'),
            ('Page?.qml', 'qrc:/Plugin/Page%3F.qml'),
            ('Page%20.qml', 'qrc:/Plugin/Page%2520.qml'),
            ('My Page.qml', 'qrc:/Plugin/My%20Page.qml'),
            ('branding/Branding.qml', 'qrc:/Plugin/branding/Branding.qml'),
        ]
        for fileName, url in cases:
            with self.subTest(fileName=fileName):
                self.assertEqual(compiler.resource_url('Plugin', fileName), url)


class WriteQrcTest(unittest.TestCase):
    def test_escapes_file_names(self):
        with patch('builtins.open', mock_open()) as opened:
            compiler.write_qrc(['A&B.qml', '<Card>.qml'], ['Plugin_en.qm'], ['logo.svg'], 'Plugin')
        opened.assert_called_once_with('Plugin.qrc', 'w')
        contents = ''.join(call.args[0] for call in opened().write.call_args_list)
        files = [element.text for element in ET.fromstring(contents).iter('file')]
        self.assertEqual(files, ['A&B.qml', '<Card>.qml', 'Plugin_en.qm', 'logo.svg'])


with open(os.path.join(TOOLS_DIR, 'branding-properties.json'), encoding='utf-8') as propertiesFile:
    PROPERTIES = {prop['name']: prop['type'] for prop in json.load(propertiesFile)['properties']}

ALLOWED_WITH_EXPRESSIONS = '''// createObject is allowed in a comment.
import QtQuick 2.15
import Victron.Branding 1.0; // Qt.quit
import QtQml

/* createQmlObject
   XMLHttpRequest */
Branding {
    color_brand: "#00" + "3366"
    color_success: Qt.rgba(0, 1, 0, 1)
    color_warning: color_success
    splash_logo_icon: Qt.resolvedUrl("logo.svg")
    font_family: qsTr("Brand")
    font_files: ["a" + ".ttf"]
    light_mode_background_factor: true ? 0.45 : 1
    id: branding
    Component.onCompleted: console.log("x")
}
'''


class BrandingCheckTest(unittest.TestCase):
    def check(self, text, assigned=None):
        errors = compiler.check_branding_text('Branding.qml', text, PROPERTIES, assigned)
        prefix = 'Branding.qml:'
        return [error[len(prefix):] if error.startswith(prefix) else error for error in errors]

    def body(self, assignments):
        return 'import Victron.Branding\nBranding {\n%s\n}\n' % assignments

    def test_expressions_are_allowed(self):
        assigned = []
        self.assertEqual(self.check(ALLOWED_WITH_EXPRESSIONS, assigned), [])
        self.assertEqual(sorted(assigned), [
            'color_brand', 'color_success', 'color_warning', 'font_family', 'font_files',
            'light_mode_background_factor', 'splash_logo_icon'])
        # A value the GUI may ignore is still not a compiler error.
        self.assertEqual(self.check(self.body('\n'.join([
            'color_brand: "#CC003366"',
            'color_success: "transparent"',
            'splash_logo_icon: "../logo.svg"',
            'light_mode_background_factor: 9',
            'not_a_property: 1',
            'font_family: "Brand"',
            'color_info: eval("#003366")',
        ]))), [])

    def test_rejects_forbidden_names(self):
        cases = [
            'XMLHttpRequest',
            'createQmlObject',
            'createObject',
            'createComponent',
            'WorkerScript',
            'WebSocket',
            'LocalStorage',
            'openUrlExternally',
            'setContextProperty',
            'Qt.include("x.js")',
            'Qt.quit()',
            'Qt.exit(1)',
            'Qt . exit(0)',
        ]
        for snippet in cases:
            with self.subTest(snippet=snippet):
                text = self.body('color_brand: ' + snippet)
                errors = self.check(text)
                self.assertEqual(len(errors), 1, errors)
                name = snippet.split('(')[0].replace(' ', '')
                line = text.splitlines()[2]
                column = line.index(snippet.split('(')[0].lstrip()) + 1
                self.assertTrue(errors[0].startswith('%d:%d: "%s" is not allowed' % (
                    3, column, name)), errors[0])

    def test_forbidden_name_in_a_string_is_rejected(self):
        errors = self.check(self.body('splash_logo_icon: "createObject"'))
        self.assertEqual(len(errors), 1, errors)
        self.assertIn('"createObject" is not allowed', errors[0])

    def test_comments_and_similar_words_are_not_rejected(self):
        text = '''/*
        import Victron.VenusOS
        createObject
        */
        // pragma Singleton
        // Qt.exit XMLHttpRequest
        import Victron.Branding
        Branding {
            color_brand: "#003366" // createQmlObject
            font_family: "Qt.exitCode"
            quantity_font_family: mycreateObject
        }
        '''
        self.assertEqual(self.check(text), [])

    def test_create_qml_object_is_one_match(self):
        errors = self.check(self.body('color_brand: Qt.createQmlObject("Item {}", parent)'))
        self.assertEqual(len(errors), 1, errors)
        self.assertIn('"createQmlObject" is not allowed', errors[0])
        self.assertNotIn('"createObject"', errors[0])

    def test_rejects_imports(self):
        cases = {
            'import Victron.Branding\nimport Victron.VenusOS\nBranding {}':
                'importing Victron.VenusOS is not allowed',
            'import Victron.Branding\nimport Victron.GuiPlugins\nBranding {}':
                'importing Victron.GuiPlugins is not allowed',
            'import Victron.Branding\nimport QtQuick.Controls\nBranding {}':
                'importing QtQuick.Controls is not allowed',
            'import Victron.Branding\nimport "utils.js" as Utils\nBranding {}':
                'importing a file or directory',
            'import Victron.Branding\nimport \'icons\'\nBranding {}':
                'importing a file or directory',
            'import Victron.Branding as B\nB {}':
                'qualified imports ("as") are not allowed',
            'import Victron.Branding\nimport Victron.Branding\nBranding {}':
                'imported more than once (first on line 1)',
            'import QtQuick\nBranding {}':
                'missing "import Victron.Branding"',
            'pragma Singleton\nimport Victron.Branding\nBranding {}':
                'pragma is not allowed',
            'import\nimport Victron.Branding\nBranding {}':
                'invalid import',
        }
        for text, expected in cases.items():
            with self.subTest(text=text):
                errors = self.check(text)
                self.assertTrue(any(expected in error for error in errors), errors)

    def test_import_error_position(self):
        errors = self.check('import Victron.VenusOS\nimport Victron.Branding\n    Qt . quit\n')
        self.assertEqual(errors[0], '1:1: importing Victron.VenusOS is not allowed. A Branding file '
                         'may import only Victron.Branding, QtQml, QtQuick.')
        self.assertEqual(errors[1], '3:5: "Qt.quit" is not allowed in a Branding file. '
                         'Do not start other objects, load scripts, or do I/O from this file.')

    def test_assigned_properties_are_line_start_names(self):
        assigned = []
        errors = compiler.check_branding_text(
            'Branding.qml',
            'import Victron.Branding\nBranding {\n    color_brand: "#003366"\n'
            '    splash_logo_icon_preserve_colors: true\n    splash_logo_icon: "logo.svg"\n'
            '    color_brand: "#000"\n}\n',
            ['color_brand', 'splash_logo_icon', 'splash_logo_icon_preserve_colors', 'color_success'],
            assigned)
        self.assertEqual(errors, [])
        self.assertEqual(assigned, [
            'color_brand', 'splash_logo_icon_preserve_colors', 'splash_logo_icon'])

        missed = []
        self.assertEqual(self.check(
            'import Victron.Branding\n// color_success: "green"\n'
            'Branding { color_brand: "#003366" }\n    property string color_warning: "#ff0"\n',
            missed), [])
        self.assertEqual(missed, [])

    def test_packs_image_and_font_files_under_the_directory(self):
        # No directory is created. open and os.walk are mocked, and the walk
        # mock only descends into names the caller left in dirnames.
        directory = 'Plugin'
        branding = os.path.join(directory, 'Branding.qml')
        text = 'import Victron.Branding\nBranding {\n    color_brand: "#003366"\n}\n'
        tree = {
            directory: (['fonts', 'nested', '.hidden'], ['Branding.qml', 'logo.svg', 'gauge.gif', 'notes.txt']),
            os.path.join(directory, 'fonts'): ([], ['Brand.ttf']),
            os.path.join(directory, 'nested'): ([], ['mark.PNG']),
            os.path.join(directory, '.hidden'): ([], ['secret.svg']),
        }

        def walk(start):
            self.assertEqual(start, directory)
            pending = [start]
            while pending:
                root = pending.pop(0)
                entry = tree.get(root)
                self.assertIsNotNone(entry, root)
                dirnames = list(entry[0])
                yield root, dirnames, list(entry[1])
                for name in dirnames:
                    pending.append(os.path.join(root, name))

        with patch('builtins.open', mock_open(read_data=text)) as opened, \
                patch.object(compiler.os, 'walk', side_effect=walk):
            errors, files = compiler.check_branding_file(branding, PROPERTIES)
        opened.assert_called_once_with(branding, encoding='utf-8')
        self.assertEqual(errors, [])
        self.assertEqual(files, ['fonts/Brand.ttf', 'gauge.gif', 'logo.svg', 'nested/mark.PNG'])

    def test_rejects_invalid_utf8(self):
        def fail_open(path, *args, **kwargs):
            self.assertEqual(path, 'Branding.qml')
            self.assertEqual(kwargs.get('encoding'), 'utf-8')
            raise UnicodeDecodeError('utf-8', b'\xff', 0, 1, 'invalid start byte')

        with patch('builtins.open', side_effect=fail_open):
            errors, files = compiler.check_branding_file('Branding.qml', ['color_brand'])
        self.assertEqual(files, [])
        self.assertEqual(errors, ['Branding.qml:1:1: the file is not valid UTF-8.'])

    def test_packed_paths_are_relative_to_the_working_directory(self):
        self.assertEqual(compiler.branding_packed_paths('Branding.qml', ['logo.svg', 'fonts/a.ttf']),
                         ['logo.svg', 'fonts/a.ttf'])
        self.assertEqual(compiler.branding_packed_paths('examples/BrandingExample/Branding.qml',
                                                        ['logo.svg']),
                         ['examples/BrandingExample/logo.svg'])


class QtToolLookupTest(unittest.TestCase):
    def which(self, found):
        def which(name, path=None):
            if path is None:
                return found.get(name)
            return found.get((name, path))
        return which

    def test_returns_tool_on_path(self):
        found = {'qmllint': '/usr/bin/qmllint'}
        with patch.object(compiler.shutil, 'which', side_effect=self.which(found)):
            self.assertEqual(compiler.find_qt_tool('qmllint'), '/usr/bin/qmllint')

    def test_returns_tool_next_to_lrelease(self):
        found = {
            'lrelease': '/opt/Qt/bin/lrelease',
            ('qmllint', '/opt/Qt/bin'): '/opt/Qt/bin/qmllint',
        }
        with patch.object(compiler.shutil, 'which', side_effect=self.which(found)):
            self.assertEqual(compiler.find_qt_tool('qmllint'), '/opt/Qt/bin/qmllint')

    def test_returns_usr_libexec_tool(self):
        found = {'lrelease': '/usr/bin/lrelease'}
        with patch.object(compiler.shutil, 'which', side_effect=self.which(found)), \
                patch.object(compiler.os.path, 'isfile', side_effect=lambda path: path == '/usr/libexec/rcc'):
            self.assertEqual(compiler.find_qt_tool('rcc'), '/usr/libexec/rcc')

    def test_does_not_return_lrelease_as_another_tool(self):
        # The old rewrite left these paths unchanged, and isfile() then matched lrelease itself.
        for lrelease in ('/opt/Qt/bin/lrelease', r'C:\Qt\6.8.3\msvc2022_64\bin\lrelease.exe'):
            with self.subTest(lrelease=lrelease):
                found = {'lrelease': lrelease}
                with patch.object(compiler.shutil, 'which', side_effect=self.which(found)), \
                        patch.object(compiler.os.path, 'isfile', return_value=True):
                    self.assertIsNone(compiler.find_qt_tool('qmllint'))

    def test_missing_tool_is_none(self):
        with patch.object(compiler.shutil, 'which', return_value=None):
            self.assertIsNone(compiler.find_qt_tool('qmllint'))

    def test_rcc_success_returns(self):
        result = compiler.subprocess.CompletedProcess(['rcc'], 0, '', '')
        with patch.object(compiler, 'find_qt_tool', return_value='/usr/bin/rcc'), \
                patch.object(compiler.subprocess, 'run', return_value=result):
            compiler.run_rcc('Plugin')

    def test_rcc_failure_stops_the_compiler(self):
        error = compiler.subprocess.CalledProcessError(1, 'rcc', stderr='bad qrc')
        with patch.object(compiler, 'find_qt_tool', return_value='/usr/bin/rcc'), \
                patch.object(compiler.subprocess, 'run', side_effect=error):
            with self.assertRaises(SystemExit) as raised:
                compiler.run_rcc('Plugin')
        self.assertEqual(raised.exception.code, 1)

    def test_missing_rcc_stops_the_compiler(self):
        with patch.object(compiler, 'find_qt_tool', return_value=None):
            with self.assertRaises(SystemExit) as raised:
                compiler.run_rcc('Plugin')
        self.assertEqual(raised.exception.code, 1)


class RequiredBrandingVersionTest(unittest.TestCase):
    PROPERTY_LIST = {
        'module': 'Victron.Branding',
        'version': '2.3',
        'properties': [
            {'name': 'a', 'type': 'color', 'since': '2.0'},
            {'name': 'b', 'type': 'color', 'since': '2.3'},
            {'name': 'c', 'type': 'color', 'since': '2.1'},
        ],
    }

    def test_lowest_version_that_has_every_assigned_property(self):
        cases = {
            (): '2.0',
            ('a',): '2.0',
            ('c',): '2.1',
            ('a', 'c'): '2.1',
            ('b', 'a', 'c'): '2.3',
        }
        for assigned, expected in cases.items():
            with self.subTest(assigned=assigned):
                self.assertEqual(compiler.required_branding_version(self.PROPERTY_LIST, list(assigned)), expected)

    def test_checked_in_property_list(self):
        propertyList = compiler.load_branding_property_list()
        major = propertyList['version'].split('.')[0]
        self.assertEqual(compiler.required_branding_version(propertyList, []), major + '.0')
        for prop in propertyList['properties']:
            with self.subTest(property=prop['name']):
                self.assertEqual(compiler.required_branding_version(propertyList, [prop['name']]), prop['since'])


class ExampleBrandingTest(unittest.TestCase):
    """The example custom branding plugins in examples/ pass the checks that the compiler runs."""

    # Example directory: the image and font files, other than Branding.qml, that the compiler packs.
    EXAMPLES = {
        'BrandingExample': ['logo.svg', 'splash_gauge.gif', 'wordmark.svg'],
        'BrandingMinimalExample': [],
    }

    def test_branding_check(self):
        propertyList = compiler.load_branding_property_list()
        firstVersion = propertyList['version'].split('.')[0] + '.0'
        for name, expectedFiles in self.EXAMPLES.items():
            with self.subTest(example=name):
                assigned = []
                errors, files = compiler.check_branding_file(
                    os.path.join(EXAMPLES_DIR, name, 'Branding.qml'), PROPERTIES, assigned)
                self.assertEqual(errors, [])
                self.assertEqual(files, expectedFiles)
                self.assertIn('color_brand', assigned)
                self.assertEqual(compiler.required_branding_version(propertyList, assigned), firstVersion)

    # tests/CMakeLists.txt sets these to qmllint and the build directory, which holds Victron.Branding.
    def test_qmllint(self):
        qmllint = os.environ.get('GUI_V2_QMLLINT')
        importPath = os.environ.get('GUI_V2_QML_IMPORT_PATH')
        if not qmllint or not importPath:
            self.skipTest('GUI_V2_QMLLINT and GUI_V2_QML_IMPORT_PATH are not set')
        # CI runs ctest with QT_DEBUG_PLUGINS=1. qmllint then logs plugin
        # metadata; that is not a lint error, so do not pass the flag through.
        env = os.environ.copy()
        env.pop('QT_DEBUG_PLUGINS', None)
        for name in self.EXAMPLES:
            with self.subTest(example=name):
                result = subprocess.run([qmllint, '-I', importPath, os.path.join(EXAMPLES_DIR, name, 'Branding.qml')],
                                        capture_output=True, text=True, env=env)
                self.assertEqual((result.returncode, (result.stdout + result.stderr).strip()), (0, ''))


if __name__ == '__main__':
    unittest.main()
