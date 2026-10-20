#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/gui-v2-plugin-compiler.py: the requiredGuiPluginsVersion that it writes.

import contextlib
import importlib.util
import io
import os
import sys
import unittest

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
            'PluginReading { Component.onCompleted: dataItem.setValue(1) }': ('1.1', ['PluginDataItem.setValue']),
            'PluginListItem { text: PluginWords.reset }': ('1.3', ['PluginWords.reset']),
            'PluginListItem { property int unit: PluginUnit.Watt }': ('1.2', ['PluginUnit.Watt']),
            'PluginListItem { text: `${PluginWords.reset}` }': ('1.3', ['PluginWords.reset']),
            # Names of members on types that the plugin does not use, or in strings and comments.
            'PluginListItem { property bool checked; function setValue() {} }': ('1.0', []),
            'PluginListItem { text: "PluginListGauge" } // PluginWords.reset': ('1.0', []),
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


if __name__ == '__main__':
    unittest.main()
