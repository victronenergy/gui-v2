#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/gui-v2-plugin-compiler.py: the literal-only Branding check, and the
# requiredBrandingVersion that it writes.

import importlib.util
import json
import os
import subprocess
import sys
import unittest

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')
EXAMPLES_DIR = os.path.join(TOOLS_DIR, '..', 'examples')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('plugincompiler', os.path.join(TOOLS_DIR, 'gui-v2-plugin-compiler.py'))
compiler = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compiler)

with open(os.path.join(TOOLS_DIR, 'branding-properties.json'), encoding='utf-8') as propertiesFile:
    PROPERTIES = {prop['name']: prop['type'] for prop in json.load(propertiesFile)['properties']}

VALID_BRANDING = '''// An OEM branding file.
import QtQuick 2.15
import Victron.Branding 1.0;
import QtQml

/* Block comment */
Branding {
    color_brand: "#003366"
    color_success: 'green';
    color_warning: "#FFaa5500"
    color_critical: "#f00"
    color_background_primary: "black"
    light_mode_background_factor: 0.45
    font_files: [
        "fonts/Brand-Regular.ttf",
        "Brand-Bold.otf",
    ]
    font_family: "Brand"
    quantity_font_family: "Brand"
    splash_logo_icon: "images/icon.svg"
    splash_logo_text: "text.png"
    splash_logo_icon_preserve_colors: true
    splash_logo_text_preserve_colors: false
}
'''

# The files that the check treats as present next to Branding.qml.
AVAILABLE_FILES = {'fonts/Brand-Regular.ttf', 'Brand-Bold.otf', 'images/icon.svg', 'text.png', 'logo.jpg'}


class BrandingCheckTest(unittest.TestCase):
    def check(self, text, warnings=None):
        path = 'Branding.qml'
        allWarnings = []
        errors, files = compiler.check_branding_text(path, text, PROPERTIES, lambda relative_path:
                                                     relative_path in AVAILABLE_FILES, allWarnings)
        prefix = path + ':'
        if warnings is not None:
            warnings.extend(w[len(prefix):] if w.startswith(prefix) else w for w in allWarnings)
        return [error[len(prefix):] if error.startswith(prefix) else error for error in errors], files

    def body(self, assignments):
        return 'import Victron.Branding\nBranding {\n%s\n}\n' % assignments

    def test_valid_file(self):
        warnings = []
        errors, files = self.check(VALID_BRANDING, warnings)
        self.assertEqual(errors, [])
        self.assertEqual(warnings, [])
        self.assertEqual(sorted(files), ['Brand-Bold.otf', 'fonts/Brand-Regular.ttf', 'images/icon.svg', 'text.png'])

    def test_rejects_non_literal_values(self):
        cases = {
            'color_brand: "#00" + "3366"': 'found an expression ("+" follows the value)',
            'color_brand: Theme.color_ok': 'found a reference to Theme.color_ok',
            'color_brand: color_success': 'found the identifier color_success',
            'color_brand: undefined': 'found undefined',
            'color_brand: Qt.rgba(1, 0, 0, 1)': 'found a call to Qt.rgba',
            'splash_logo_icon: Qt.resolvedUrl("logo.svg")': 'found a call to Qt.resolvedUrl',
            'font_family: qsTr("Brand")': 'found a call to qsTr',
            'color_brand: `#003366`': 'found a template literal',
            'color_brand: { return "#003366" }': 'found a block',
            'color_brand: ("#003366")': 'found a parenthesised expression',
            'splash_logo_icon_preserve_colors: !true': 'found an expression starting with "!"',
            'color_brand: true ? "#003366" : "#000000"': 'found an expression ("?" follows the value)',
            'font_files: [["a.ttf"]]': 'list entries must be string literals, found a nested list',
            'font_files: ["a" + ".ttf"]': 'separated by ","',
            'font_files: [Qt.resolvedUrl("a.ttf")]': 'found a call to Qt.resolvedUrl',
        }
        for assignment, expected in cases.items():
            with self.subTest(assignment=assignment):
                errors, _ = self.check(self.body(assignment))
                self.assertEqual(len(errors), 1, errors)
                self.assertIn(expected, errors[0])

    def test_rejects_non_assignments(self):
        cases = {
            'id: branding': 'id is not allowed',
            'property color c: "red"': '"property" declarations are not allowed',
            'readonly property color c: "red"': '"readonly" declarations are not allowed',
            'signal changed()': '"signal" declarations are not allowed',
            'function f() { return 1 }': '"function" declarations are not allowed',
            'enum E { A, B }': '"enum" declarations are not allowed',
            'component C: QtObject {}': '"component" declarations are not allowed',
            'onColor_brandChanged: console.log("x")': 'signal handlers are not allowed',
            'Component.onCompleted: console.log("x")': 'Component.onCompleted: attached and grouped properties',
            'font.family: "x"': 'attached and grouped properties',
            'Behavior on color_brand { ColorAnimation {} }': '"Behavior on ..." is not allowed',
            'QtObject { }': 'child objects (QtObject { }) are not allowed',
        }
        for statement, expected in cases.items():
            with self.subTest(statement=statement):
                errors, _ = self.check(self.body(statement + '\ncolor_brand: "#003366"'))
                self.assertEqual(len(errors), 1, errors)
                self.assertIn(expected, errors[0])

    def test_rejects_imports_and_structure(self):
        cases = {
            'import Victron.Branding\nimport Victron.VenusOS\nBranding {}': 'importing Victron.VenusOS is not allowed',
            'import Victron.Branding\nimport Victron.GuiPlugins\nBranding {}': 'importing Victron.GuiPlugins is not allowed',
            'import Victron.Branding\nimport QtQuick.Controls\nBranding {}': 'importing QtQuick.Controls is not allowed',
            'import Victron.Branding\nimport "utils.js" as Utils\nBranding {}': 'importing a file or directory',
            'import Victron.Branding as B\nB.Branding {}': 'qualified imports ("as") are not allowed',
            'import Victron.Branding\nimport Victron.Branding\nBranding {}': 'imported more than once',
            'import QtQuick\nBranding {}': 'missing "import Victron.Branding"',
            'pragma Singleton\nimport Victron.Branding\nBranding {}': 'pragma is not allowed',
            'import Victron.Branding\nQtObject {}': 'the root object must be Branding, found QtObject',
            'import Victron.Branding\nBranding {}\nBranding {}': 'only one root object is allowed',
            'import Victron.Branding\nBranding {': 'missing the closing "}"',
        }
        for text, expected in cases.items():
            with self.subTest(text=text):
                errors, _ = self.check(text)
                self.assertTrue(any(expected in error for error in errors), errors)

    def test_rejects_invalid_values(self):
        cases = {
            'color_brand: "#CC003366"': 'QML reads 8-digit colors as #AARRGGBB',
            'color_brand: "transparent"': '"transparent" is not allowed',
            'color_brand: "#12345"': 'is not a color',
            'color_brand: "bluish"': 'is not a color',
            'splash_logo_icon: "qrc:/logo.svg"': 'is a URL',
            'splash_logo_icon: "https://example.com/logo.svg"': 'is a URL',
            'splash_logo_icon: "/images/icon.svg"': 'is absolute',
            'splash_logo_icon: "../images/icon.svg"': 'contains ".."',
            'splash_logo_icon: "images\\\\icon.svg"': 'contains "\\"',
            'splash_logo_icon: "missing.svg"': 'was not found',
            'splash_logo_icon: "Images/icon.svg"': 'was not found',
            'splash_logo_icon: "logo.jpg"': 'must be a .svg or .png file',
            'font_files: ["text.png"]': 'must be a .ttf or .otf file',
            'font_files: ["Brand-Bold.otf", "./Brand-Bold.otf"]': 'is listed more than once',
            'font_family: "  "': 'must not be empty',
            'color_brand: true': 'expected a string literal, found true',
            'splash_logo_icon_preserve_colors: "true"': 'expected true or false, found a string',
            'font_files: "Brand-Bold.otf"': 'expected a list of string literals, found a string',
            'color_brand: -1': 'expected a string literal, found a number',
            'color_brand: 0x10': 'found the invalid number 0x10',
            'color_brand: "#003366"\ncolor_brand: "#003366"': 'assigned more than once (first on line 3)',
            'colour_brand: "#003366"': 'Branding has no property with this name. Did you mean color_brand?',
            'color_brand:': 'color_brand: missing value',
        }
        for assignment, expected in cases.items():
            with self.subTest(assignment=assignment):
                errors, _ = self.check(self.body(assignment))
                self.assertEqual(len(errors), 1, errors)
                self.assertIn(expected, errors[0])

    def test_background_factor(self):
        invalid = ('0', '-0.5', '2.001', '0.0004', '1e999')
        for value in invalid:
            with self.subTest(value=value):
                errors, _ = self.check(self.body('color_background_primary: "#1A1A1A"\n'
                                                 'light_mode_background_factor: ' + value))
                self.assertEqual(len(errors), 1, errors)
                self.assertIn('light_mode_background_factor: must be more than 0 and at most 2', errors[0])
        errors, _ = self.check(self.body('light_mode_background_factor: "0.5"'))
        self.assertEqual(len(errors), 1, errors)
        self.assertIn('expected a number, found a string. Write a number, for example 0.5.', errors[0])

        # 0.0005 rounds half up to one thousandth, as in the loader.
        for value in ('2', '0.0005', '1.12'):
            with self.subTest(value=value):
                warnings = []
                errors, _ = self.check(self.body('light_mode_background_factor: %s\n'
                                                 'color_background_primary: "#1A1A1A"' % value), warnings)
                self.assertEqual((errors, warnings), ([], []))

    def test_background_factor_without_background_warns(self):
        warnings = []
        errors, _ = self.check(self.body('color_brand: "#003366"\nlight_mode_background_factor: 0.45'), warnings)
        self.assertEqual(errors, [])
        self.assertEqual(len(warnings), 1, warnings)
        self.assertTrue(warnings[0].startswith('4:31: light_mode_background_factor: has no effect unless this file '
                                               'also sets color_background_primary'), warnings[0])

    def test_reports_every_error_with_position(self):
        errors, files = self.check(self.body(
            '    color_brand: Qt.rgba(0, 0, 1, 1)\n'
            '    splash_logo_icon: Qt.resolvedUrl("logo.svg")\n'
            '    color_success: "#80ff0000"'))
        self.assertEqual(len(errors), 3, errors)
        self.assertTrue(errors[0].startswith('3:18: color_brand: expected a string literal, found a call to Qt.rgba.'))
        self.assertEqual(errors[1], '4:23: splash_logo_icon: expected a string literal, found a call to '
                                    'Qt.resolvedUrl. Write "logo.svg"; the path is relative to Branding.qml.')
        self.assertTrue(errors[2].startswith('5:20: color_success: "#80ff0000" is not opaque.'))
        self.assertEqual(files, [])

    def test_string_escapes(self):
        tokens, errors, _ = compiler.tokenize_qml(r'"a\"b\u0041\x42\u{1F600}\n" ' + "'c\\'d'")
        self.assertEqual(errors, [])
        self.assertEqual([t.value for t in tokens], ['a"bAB\U0001F600\n', "c'd"])
        _, errors, _ = compiler.tokenize_qml('"unterminated\n"')
        self.assertTrue(any('unterminated string' in error[2] for error in errors))

    def test_reports_assigned_properties(self):
        assigned = []
        errors, _ = compiler.check_branding_text('Branding.qml', self.body('color_brand: "#003366"\nfont_family: "X"'),
                                                 PROPERTIES, lambda relative_path: True, None, assigned)
        self.assertEqual(errors, [])
        self.assertEqual(sorted(assigned), ['color_brand', 'font_family'])


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
    """The example branding plugins in examples/ pass the checks that the compiler runs."""

    # Example directory: the files, other than Branding.qml, that the compiler packs for it.
    EXAMPLES = {
        'BrandingExample': ['logo.svg', 'wordmark.svg'],
        'BrandingMinimalExample': [],
    }

    def test_literal_only_check(self):
        propertyList = compiler.load_branding_property_list()
        firstVersion = propertyList['version'].split('.')[0] + '.0'
        for name, expectedFiles in self.EXAMPLES.items():
            with self.subTest(example=name):
                warnings = []
                assigned = []
                errors, files = compiler.check_branding_file(os.path.join(EXAMPLES_DIR, name, 'Branding.qml'),
                                                             PROPERTIES, warnings, assigned)
                self.assertEqual((errors, warnings), ([], []))
                self.assertEqual(sorted(os.path.basename(path) for path in files), expectedFiles)
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
