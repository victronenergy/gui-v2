#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# themepruner must keep commas inside a color formula. Otherwise
# text_color_on(color_a,color_b) is one identifier, and pruning can delete both colors.

import os
import sys
import unittest

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools'))
import themepruner  # noqa: E402


class ThemePrunerTests(unittest.TestCase):
    def test_commas_inside_a_formula_are_kept(self):
        name, value = themepruner.parse_theme_property(
            '    "color_label": "text_color_on(color_unused_a,color_unused_b)",')
        self.assertEqual(name, 'color_label')
        self.assertEqual(
            themepruner.IDENTIFIER_RE.findall(value),
            ['text_color_on', 'color_unused_a', 'color_unused_b'])

    def test_trailing_json_comma_is_removed(self):
        name, value = themepruner.parse_theme_property('    "color_button": "color_brand",')
        self.assertEqual(name, 'color_button')
        self.assertEqual(value, 'color_brand')


if __name__ == '__main__':
    unittest.main()
