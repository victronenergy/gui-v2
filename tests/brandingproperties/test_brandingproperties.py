#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/brandingproperties.py: the checks that keep the checked-in Branding property list,
# which is the Victron.Branding API, from losing or changing a property.

import json
import os
import subprocess
import sys
import unittest

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
sys.path.insert(0, TOOLS_DIR)
import brandingproperties  # noqa: E402

BRAND_PROPERTY = '''
	// The brand color.
	// If not set: Victron's color.
	Q_PROPERTY(QColor color_brand READ color_brand WRITE setColor_brand FINAL)
'''
FONT_PROPERTY = '''
	// The font family.
	// If not set: the language's font.
	Q_PROPERTY(QString font_family READ font_family WRITE setFont_family REVISION(1, 1) FINAL)
'''
HEADER = BRAND_PROPERTY + FONT_PROPERTY

# The checked-in list that HEADER gives at version 1.1.
OLD_LIST = json.loads(brandingproperties.generate_json(
    (1, 1), brandingproperties.parse_properties(HEADER, 'branding.h', (1, 1))))

NEW_PROPERTY = '''
	// The new color.
	// If not set: the brand color.
	Q_PROPERTY(QColor color_new READ color_new WRITE setColor_new%s FINAL)
'''


def problems(header, module_version):
    properties = brandingproperties.parse_properties(header, 'branding.h', module_version)
    return (brandingproperties.breaking_changes(OLD_LIST, module_version, properties)
            + brandingproperties.new_properties_without_revision(OLD_LIST, module_version, properties))


class TestBrandingProperties(unittest.TestCase):
    def test_unchanged_properties_pass(self):
        self.assertEqual(problems(HEADER, (1, 1)), [])

    def test_removed_or_changed_property_is_reported(self):
        cases = {
            'color_brand was removed or renamed': FONT_PROPERTY,
            'color_brand changed type, from color to string': HEADER.replace('QColor color_brand', 'QString color_brand'),
            'font_family changed version, from 1.1 to 1.0': HEADER.replace(' REVISION(1, 1)', ''),
        }
        for expected, header in cases.items():
            with self.subTest(expected=expected):
                self.assertEqual(problems(header, (1, 1)), [expected])

    def test_new_property_needs_the_module_version(self):
        self.assertEqual(problems(HEADER + NEW_PROPERTY % ' REVISION(1, 2)', (1, 2)), [])
        self.assertEqual(problems(HEADER + NEW_PROPERTY % ' REVISION(1, 1)', (1, 2)),
                         ['color_new is new, so it needs REVISION(1, 2): the current module version'])

    def test_new_major_version_may_change_properties(self):
        header = HEADER.replace('color_brand READ', 'color_logo READ').replace(' REVISION(1, 1)', '')
        self.assertEqual(problems(header, (2, 0)), [])

    def test_property_written_over_several_lines_is_an_error(self):
        header = HEADER.replace('READ color_brand ', 'READ color_brand\n\t\t')
        with self.assertRaisesRegex(ValueError, 'write each Q_PROPERTY on one line'):
            brandingproperties.parse_properties(header, 'branding.h', (1, 1))

    def test_source_tree_is_up_to_date(self):
        result = subprocess.run([sys.executable, '-B', os.path.join(TOOLS_DIR, 'brandingproperties.py'), '--check'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
