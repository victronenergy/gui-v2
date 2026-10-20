#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/gui-v2-plugin-compiler.py: the requiredGuiPluginsVersion that it writes,
# and the warning it prints for a deprecated type or member.

import contextlib
import copy
import importlib.util
import io
import os
import sys
import unittest
from unittest import mock

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')
EXAMPLES_DIR = os.path.join(TOOLS_DIR, '..', 'examples')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('plugincompiler', os.path.join(TOOLS_DIR, 'gui-v2-plugin-compiler.py'))
compiler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compiler)


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
                self.assertEqual(compiler.guiplugins_names(qml)[0], expected)

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
        }
        for qml, expected in cases.items():
            with self.subTest(qml=qml):
                imports, names = compiler.guiplugins_names('import Victron.GuiPlugins\n' + qml)
                self.assertTrue(imports)
                self.assertEqual(compiler.required_guiplugins_version(self.API, names), expected)

    def test_examples(self):
        """The examples work with the first version of the checked-in record."""
        firstVersion = compiler.load_guiplugins_api()['version'].split('.')[0] + '.0'
        for name in ['DeviceListExample', 'FullApiExample', 'SimpleExample', 'SimpleTrExample']:
            with self.subTest(example=name):
                directory = os.path.join(EXAMPLES_DIR, name)
                paths = [os.path.join(directory, file) for file in os.listdir(directory) if file.endswith('.qml')]
                with contextlib.redirect_stdout(io.StringIO()):
                    self.assertEqual(compiler.check_guiplugins_version(paths), firstVersion)

    def test_no_import(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(compiler.check_guiplugins_version([]), '')

    def test_versioned_import_is_rejected(self):
        self.assertIsNone(compiler.versioned_guiplugins_import('import Victron.GuiPlugins\nItem {}'))
        self.assertIsNone(compiler.versioned_guiplugins_import('import Victron.GuiPlugins as Plugins'))
        self.assertIsNone(compiler.versioned_guiplugins_import('// import Victron.GuiPlugins 1.0'))
        self.assertIsNone(compiler.versioned_guiplugins_import('import Victron.GuiPlugins.Other 1.0'))
        self.assertEqual(compiler.versioned_guiplugins_import('import Victron.GuiPlugins 1.3'),
                         'import Victron.GuiPlugins 1.3')
        self.assertEqual(compiler.versioned_guiplugins_import('import Victron.GuiPlugins 1.10'),
                         'import Victron.GuiPlugins 1.10')
        self.assertEqual(compiler.versioned_guiplugins_import('import Victron.GuiPlugins 1.0 as Plugins'),
                         'import Victron.GuiPlugins 1.0')
        with self.assertRaises(SystemExit) as raised:
            with contextlib.redirect_stdout(io.StringIO()) as out:
                compiler.reject_versioned_import('Page.qml', 'import Victron.GuiPlugins 1.0\nItem {}')
        self.assertEqual(raised.exception.code, 1)
        self.assertIn('Page.qml', out.getvalue())
        self.assertIn('without a version', out.getvalue())
        with self.assertRaises(SystemExit):
            with contextlib.redirect_stdout(io.StringIO()) as out:
                compiler.reject_versioned_import('Page.qml', 'import Victron.GuiPlugins 1.10\nItem {}')
        self.assertIn('import Victron.GuiPlugins 1.10', out.getvalue())

    def test_reached_type_version_counts(self):
        api = copy.deepcopy(self.API)
        next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListItem')['since'] = '1.3'
        _imports, names = compiler.guiplugins_names('import Victron.GuiPlugins\nPluginListSwitch {}')
        self.assertEqual(compiler.required_guiplugins_version(api, names), ('1.3', ['PluginListItem']))

    def test_deprecated_use_is_warned(self):
        api = copy.deepcopy(self.API)
        next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListItem')['deprecated'] = True
        switch = next(api_type for api_type in api['types'] if api_type['name'] == 'PluginListSwitch')
        switch['properties'][0]['deprecated'] = True
        words = next(api_type for api_type in api['types'] if api_type['name'] == 'PluginWords')
        next(prop for prop in words['properties'] if prop['name'] == 'reset')['deprecated'] = True

        def uses(qml):
            _imports, names = compiler.guiplugins_names('import Victron.GuiPlugins\n' + qml)
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

    def test_rejects_another_user_or_an_unsafe_name(self):
        with self.assertRaises(ValueError):
            compiler.gx_install_command('OemName', 'user@gx.local', 'key')
        with self.assertRaises(ValueError):
            compiler.gx_install_command('OemName', 'gx.local;rm -rf /', 'key')
        with self.assertRaises(ValueError):
            compiler.gx_install_command('../OemName', 'gx.local', 'key')

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


if __name__ == '__main__':
    unittest.main()
