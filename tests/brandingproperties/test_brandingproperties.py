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
from unittest.mock import patch

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

    def test_property_added_after_a_release_needs_a_newer_version(self):
        released = {
            'version': '1.0',
            'properties': [{'name': 'color_brand', 'type': 'color', 'since': '1.0'}],
        }
        # An unrevisioned property is major.0, which equals the unreleased module version, so the
        # checked-in-list check does not catch it. A release tag must.
        still_at_release = brandingproperties.parse_properties(BRAND_PROPERTY + NEW_PROPERTY % '', 'branding.h', (1, 0))
        self.assertEqual(
            brandingproperties.properties_added_since_release(released, 'v1.5.0', (1, 0), still_at_release),
            ['color_new was added after Victron.Branding 1.0 was released in v1.5.0, but the module version '
             'is still 1.0. Increase the minor version and set REVISION to that version.'])

        bumped_without_revision = brandingproperties.parse_properties(
            BRAND_PROPERTY + NEW_PROPERTY % ' REVISION(1, 0)', 'branding.h', (1, 1))
        self.assertEqual(
            brandingproperties.properties_added_since_release(released, 'v1.5.0', (1, 1), bumped_without_revision),
            ['color_new was added after Victron.Branding 1.0 was released in v1.5.0, but its version is 1.0. '
             'Set REVISION(1, 1).'])

        bumped = brandingproperties.parse_properties(
            BRAND_PROPERTY + NEW_PROPERTY % ' REVISION(1, 1)', 'branding.h', (1, 1))
        self.assertEqual(brandingproperties.properties_added_since_release(released, 'v1.5.0', (1, 1), bumped), [])
        self.assertEqual(brandingproperties.properties_added_since_release(None, None, (1, 0), still_at_release), [])

    def test_released_list_comes_from_the_latest_version_tag(self):
        # No repository is created. git_output is mocked. The tag query must ask for
        # tags merged into HEAD, which is what excludes a newer unmerged tag. A
        # non-release tag is skipped. A later release with no property list is not
        # a Branding release, even if an older tag still has the file.
        released = '{"module": "Victron.Branding", "version": "1.0", "properties": []}\n'
        state = {
            'tags': 'v9.0.0-test-tag\nv9.0.0\n',
            'files': {'v9.0.0': released},
        }

        def git_result(returncode=0, stdout='', stderr=''):
            return subprocess.CompletedProcess(['git'], returncode, stdout, stderr)

        def git_output(repo_dir, args):
            self.assertEqual(repo_dir, 'repo')
            if args == ['rev-parse', '--is-inside-work-tree']:
                return git_result(stdout='true\n')
            if args == ['rev-parse', '--is-shallow-repository']:
                return git_result(stdout='false\n')
            if args[:3] == ['tag', '--list', 'v*']:
                self.assertEqual(args, ['tag', '--list', 'v*', '--merged', 'HEAD', '--sort=-v:refname'])
                return git_result(stdout=state['tags'])
            if args[:3] == ['rev-parse', '--verify', '--quiet'] and str(args[3]).endswith('^{commit}'):
                return git_result(stdout='abc\n')
            if args[0] == 'show':
                tag, path = args[1].split(':', 1)
                self.assertEqual(path, brandingproperties.RELEASED_PROPERTIES_PATH)
                text = state['files'].get(tag)
                if text is None:
                    return git_result(
                        returncode=128,
                        stderr="fatal: path '%s' exists on disk, but not in '%s'\n" % (path, tag))
                return git_result(stdout=text)
            self.fail('unexpected git %s' % (args,))

        with patch.object(brandingproperties, 'git_output', side_effect=git_output):
            tag, parsed = brandingproperties.read_released_branding_list('repo')
            self.assertEqual(tag, 'v9.0.0')
            self.assertEqual(parsed['version'], '1.0')

            state['tags'] = 'v9.0.1\nv9.0.0\n'
            self.assertEqual(brandingproperties.read_released_branding_list('repo'), (None, None))

    def test_new_major_version_may_change_properties(self):
        header = HEADER.replace('color_brand READ', 'color_logo READ').replace(' REVISION(1, 1)', '')
        self.assertEqual(problems(header, (2, 0)), [])

    def test_property_written_over_several_lines_is_an_error(self):
        header = HEADER.replace('READ color_brand ', 'READ color_brand\n\t\t')
        with self.assertRaisesRegex(ValueError, 'write each Q_PROPERTY on one line'):
            brandingproperties.parse_properties(header, 'branding.h', (1, 1))

    def test_reference_supplies_the_description(self):
        reference = '''
BEGIN property reference
Copied into the branding guide.

color_brand
The brand color.
If not set: Victron's color.

font_family
The font family.
If not set: the language's font.
END property reference
'''
        entries = brandingproperties.parse_reference(reference, 'branding.cpp')
        properties = brandingproperties.attach_reference(
            brandingproperties.parse_properties(HEADER, 'branding.h', (1, 1)),
            entries, 'branding.h', 'branding.cpp')
        self.assertEqual(properties[0]['description'], 'The brand color.')
        self.assertEqual(properties[1]['if_not_set'], "the language's font.")

    def test_reference_must_match_the_properties(self):
        reference = '''
BEGIN property reference

color_brand
The brand color.
If not set: Victron's color.
END property reference
'''
        entries = brandingproperties.parse_reference(reference, 'branding.cpp')
        with self.assertRaisesRegex(ValueError, 'font_family'):
            brandingproperties.attach_reference(
                brandingproperties.parse_properties(HEADER, 'branding.h', (1, 1)),
                entries, 'branding.h', 'branding.cpp')

    def test_source_tree_is_up_to_date(self):
        result = subprocess.run([sys.executable, '-B', os.path.join(TOOLS_DIR, 'brandingproperties.py'), '--check'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
