#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/gui-v2-plugin-compiler.py: the Branding import and name checks, the image,
# animation and font files it packs, and the requiredBrandingVersion that it writes.

import importlib.util
import json
import os
import sys
import unittest
from unittest.mock import mock_open, patch

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')
# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('plugincompiler', os.path.join(TOOLS_DIR, 'gui-v2-plugin-compiler.py'))
compiler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compiler)

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


if __name__ == '__main__':
    unittest.main()
