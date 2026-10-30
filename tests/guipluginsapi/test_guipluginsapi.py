#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/guipluginsapi.py: reading the Victron.GuiPlugins API from its sources, the
# checks that keep the checked-in API record from losing or changing a member, and the list of
# versions that it writes into .github/gui-plugins.md.

import json
import os
import subprocess
import sys
import unittest
from io import StringIO
from unittest import mock

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
sys.path.insert(0, TOOLS_DIR)
import guipluginsapi  # noqa: E402

QML_TYPE = '''import QtQuick

// The { in this comment, and the // in the string below, must not confuse the parser.
FocusScope {
	id: root

	property string text: "http://example.com/{"
	readonly property ExampleItem dataItem: ExampleItem {}
	required property int productId
	default property list<Example> rows
	property int currentIndex: root.dataItem.valid
			? 1
			: -1

	enum Tint {
		Text,
		Warning = 5,
		Critical
	}

	signal optionClicked(index: int)
	signal clicked

	function click() {
		inner.click()
	}

	function format(value: real, decimals): string {
		return ""
	}

	Item {
		id: inner
		property int hidden
		function click() {}
	}
}
'''

HEADER = '''
#include <QObject>
#include <qqmlintegration.h>

namespace Victron {
namespace GuiPlugins {

class Helper;

/* QML_ATTACHED, in a comment, is not read. */
class ExampleItem : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QVariant value READ value NOTIFY valueChanged FINAL)
	// Q_PROPERTY(int hidden READ hidden)

public:
	enum Mode { Off, On = 4 };
	Q_ENUM(Mode)

	Q_INVOKABLE void setValue(const QVariant &value);
	void notInvokable();

Q_SIGNALS:
	void uidChanged();
	void valueChanged(const QString &reason);

private:
	int m_mode = 0;
};

} // namespace GuiPlugins
} // namespace Victron
'''

NAMESPACE_HEADER = '''
namespace Victron {
namespace GuiPlugins {
namespace ExampleUnit {
Q_NAMESPACE
QML_ELEMENT

enum Unit {
	None = 0,
	Watt = 0x2A
};
Q_ENUM_NS(Unit)

}
}
}
'''


def api(qml=QML_TYPE, header=HEADER, namespace_header=NAMESPACE_HEADER):
    """Returns the API types of the given sources. A source that is None is left out."""
    sources = {path: text for path, text in (('Example.qml', qml), ('exampleitem.h', header),
                                             ('exampleunit.h', namespace_header)) if text is not None}
    return guipluginsapi.read_types(sources.get, list(sources))


# The checked-in record that the sources above give at version 1.0.
OLD_RECORD = guipluginsapi.make_record(None, (1, 0), api())


def versions(record):
    """Returns {name: the version that added it} for each type, member and enum value of record."""
    result = {}
    for record_type in record['types']:
        result[record_type['name']] = record_type['since']
        for section in ('properties', 'signals', 'methods', 'enums'):
            for member in record_type.get(section, []):
                name = '%s.%s' % (record_type['name'], member['name'])
                result[name] = member['since']
                result.update({'%s.%s' % (name, value['name']): value['since'] for value in member.get('values', [])})
    return result


class TestGuiPluginsApi(unittest.TestCase):
    def test_qml_declarations_are_read(self):
        self.assertEqual(guipluginsapi.parse_qml_type('Example', QML_TYPE, 'Example.qml'), {
            'name': 'Example',
            'kind': 'object',
            'base': 'FocusScope',
            'properties': [
                {'name': 'currentIndex', 'type': 'int'},
                {'name': 'dataItem', 'type': 'ExampleItem', 'readonly': True},
                {'name': 'productId', 'type': 'int', 'required': True},
                {'name': 'rows', 'type': 'list<Example>', 'default': True},
                {'name': 'text', 'type': 'string'},
            ],
            'signals': [
                {'name': 'clicked', 'parameters': []},
                {'name': 'optionClicked', 'parameters': ['index: int']},
            ],
            'methods': [
                {'name': 'click', 'parameters': []},
                {'name': 'format', 'parameters': ['value: real', 'decimals'], 'returns': 'string'},
            ],
            'enums': [{'name': 'Tint', 'values': [{'name': 'Text', 'value': 0}, {'name': 'Warning', 'value': 5},
                                                  {'name': 'Critical', 'value': 6}]}],
        })
        singleton = 'pragma Singleton\nimport QtQml\n\nQtObject {\n\treadonly property string yes: "Yes"\n}\n'
        self.assertEqual(guipluginsapi.parse_qml_type('Words', singleton, 'Words.qml')['kind'], 'singleton')

    def test_cpp_declarations_are_read(self):
        self.assertEqual(guipluginsapi.parse_cpp_types(HEADER, 'exampleitem.h'), [{
            'name': 'ExampleItem',
            'kind': 'object',
            'base': 'QtObject',
            'properties': [{'name': 'uid', 'type': 'string'}, {'name': 'value', 'type': 'var', 'readonly': True}],
            'signals': [{'name': 'uidChanged', 'parameters': []},
                        {'name': 'valueChanged', 'parameters': ['reason: string']}],
            'methods': [{'name': 'setValue', 'parameters': ['value: var'], 'returns': 'void'}],
            'enums': [{'name': 'Mode', 'values': [{'name': 'Off', 'value': 0}, {'name': 'On', 'value': 4}]}],
        }])
        self.assertEqual(guipluginsapi.parse_cpp_types(NAMESPACE_HEADER, 'exampleunit.h'), [{
            'name': 'ExampleUnit',
            'kind': 'namespace',
            'enums': [{'name': 'Unit', 'values': [{'name': 'None', 'value': 0}, {'name': 'Watt', 'value': 42}]}],
        }])
        self.assertEqual(guipluginsapi.parse_cpp_types('class Helper : public QObject {};', 'helper.h'), [])

    def test_declarations_that_cannot_be_recorded_are_errors(self):
        cases = [
            ('Example.qml', QML_TYPE.replace('\tsignal clicked\n', '\tcomponent Inner: Item {}\n'),
             'inline component Inner'),
            ('Example.qml', QML_TYPE.replace('required property int productId', 'required productId'),
             'cannot read this declaration'),
            ('exampleitem.h', HEADER.replace('READ uid WRITE', 'READ uid\n\t\tWRITE'),
             'write each Q_PROPERTY on one line'),
            ('exampleitem.h', HEADER.replace('Q_SIGNALS:', 'public Q_SLOTS:\n\tvoid reset();\n\nQ_SIGNALS:'),
             'Use Q_INVOKABLE'),
            ('exampleitem.h', HEADER.replace('\tQML_ELEMENT\n', '\tQML_ELEMENT\n\tQML_ATTACHED(Helper)\n'),
             'does not support QML_ATTACHED'),
            ('exampleitem.h', HEADER.replace('\tvoid notInvokable();', '\tQ_INVOKABLE void setValue(int value);'),
             'more than once'),
        ]
        for path, text, expected in cases:
            with self.subTest(expected=expected):
                with self.assertRaisesRegex(ValueError, expected):
                    guipluginsapi.read_types({path: text}.get, [path])

    def test_unchanged_api_passes(self):
        self.assertEqual(guipluginsapi.breaking_changes(OLD_RECORD, (1, 0), api()), [])
        self.assertEqual(guipluginsapi.make_record(OLD_RECORD, (1, 0), api()), OLD_RECORD)
        self.assertEqual(json.loads(guipluginsapi.generate_json(OLD_RECORD)), OLD_RECORD)

    def test_breaking_changes_are_reported(self):
        cases = {
            'Example.text was removed or renamed':
                {'qml': QML_TYPE.replace('\tproperty string text: "http://example.com/{"\n', '')},
            'Example.text changed type, from string to url':
                {'qml': QML_TYPE.replace('property string text', 'property url text')},
            'Example.currentIndex became read-only':
                {'qml': QML_TYPE.replace('property int currentIndex', 'readonly property int currentIndex')},
            'Example.caption is required, so a plugin that does not set it would fail':
                {'qml': QML_TYPE.replace('\tsignal clicked\n',
                                         '\tsignal clicked\n\trequired property string caption\n')},
            'Example changed its default property, from rows to none':
                {'qml': QML_TYPE.replace('default property', 'property')},
            'Example changed its base type, from FocusScope to Item':
                {'qml': QML_TYPE.replace('FocusScope {', 'Item {')},
            'Example.optionClicked changed its parameters, from (index: int) to (row: int)':
                {'qml': QML_TYPE.replace('index: int', 'row: int')},
            'Example.format changed its return type, from string to int':
                {'qml': QML_TYPE.replace('decimals): string', 'decimals): int')},
            'ExampleItem.setValue was removed or renamed':
                {'header': HEADER.replace('Q_INVOKABLE void setValue', 'void setValue')},
            'ExampleItem.Mode.On changed value, from 4 to 3':
                {'header': HEADER.replace('On = 4', 'On = 3')},
            'ExampleUnit was removed or renamed':
                {'namespace_header': None},
        }
        for expected, sources in cases.items():
            with self.subTest(expected=expected):
                self.assertEqual(guipluginsapi.breaking_changes(OLD_RECORD, (1, 0), api(**sources)), [expected])
        self.assertEqual(guipluginsapi.breaking_changes(OLD_RECORD, (0, 9), api()),
                         ['the module version went down, from 1.0 to 0.9'])

    def test_new_members_get_the_module_version(self):
        types = api(qml=QML_TYPE.replace('\tsignal clicked\n', '\tsignal clicked\n\tproperty string caption\n'),
                    header=HEADER.replace('On = 4', 'On = 4, Auto'))
        self.assertEqual(guipluginsapi.breaking_changes(OLD_RECORD, (1, 1), types), [])
        record = guipluginsapi.make_record(OLD_RECORD, (1, 1), types)
        record_versions = versions(record)
        self.assertEqual(record['version'], '1.1')
        self.assertEqual(record_versions['Example.caption'], '1.1')
        self.assertEqual(record_versions['ExampleItem.Mode.Auto'], '1.1')
        self.assertEqual(record_versions['Example.text'], '1.0')

    def test_new_major_version_allows_breaking_changes(self):
        types = api(qml=QML_TYPE.replace('property string text', 'property url text'), namespace_header=None)
        self.assertEqual(guipluginsapi.breaking_changes(OLD_RECORD, (2, 0), types), [])
        record = guipluginsapi.make_record(OLD_RECORD, (2, 0), types)
        self.assertEqual(set(versions(record).values()), {'2.0'})

    def test_versions_list_shows_members_added_after_their_type(self):
        caption = '\tsignal clicked\n\tproperty string caption\n'
        record = guipluginsapi.make_record(OLD_RECORD, (1, 1), api(qml=QML_TYPE.replace('\tsignal clicked\n', caption),
                                                                   header=HEADER.replace('On = 4', 'On = 4, Auto')))
        record = guipluginsapi.make_record(record, (1, 2), api(
            qml=QML_TYPE.replace('\tsignal clicked\n', caption + '\tproperty int more\n\tsignal extra\n'),
            header=HEADER.replace('On = 4', 'On = 4, Auto')))
        lines = guipluginsapi.generate_versions(record).splitlines()
        self.assertEqual((lines[0], lines[-1]), (guipluginsapi.DOCS_BEGIN, guipluginsapi.DOCS_END))
        self.assertEqual(lines[1:-1], [
            '',
            '- `Example`: 1.0, except `caption` (1.1), `extra` (1.2) and `more` (1.2)',
            '- `ExampleItem`: 1.0, except `Auto` (1.1)',
            '- `ExampleUnit`: 1.0',
            '',
        ])

    def test_versions_list_replaces_the_text_between_its_markers(self):
        begin, end = guipluginsapi.DOCS_BEGIN, guipluginsapi.DOCS_END
        docs = 'Before\n%s\nold\n%s\nAfter\n' % (begin, end)
        self.assertEqual(guipluginsapi.replace_versions(docs, 'docs.md', 'new\n'), 'Before\nnew\nAfter\n')
        for broken in ['Before\n', '%s\n%s\n' % (end, begin), docs + begin + '\n']:
            with self.subTest(docs=broken):
                with self.assertRaisesRegex(ValueError, 'docs.md must contain these two lines'):
                    guipluginsapi.replace_versions(broken, 'docs.md', 'new\n')

    def test_types_that_plugins_cannot_use_are_reported(self):
        self.assertEqual(guipluginsapi.disallowed_types(api()), [])
        types = api(qml=QML_TYPE.replace('\tsignal clicked\n', '\tsignal clicked\n\tproperty ListSwitch inner\n'),
                    header=HEADER.replace('void setValue(const QVariant &value)', 'VeQuickItem *item()'))
        self.assertEqual(guipluginsapi.disallowed_types(types),
                         ['Example: property inner uses ListSwitch', 'ExampleItem: method item uses VeQuickItem'])

    def test_deprecated_mark_is_kept(self):
        old = guipluginsapi.make_record(None, (1, 0), api())
        example = next(api_type for api_type in old['types'] if api_type['name'] == 'Example')
        example['deprecated'] = True
        next(prop for prop in example['properties'] if prop['name'] == 'text')['deprecated'] = True
        unit = next(api_type for api_type in old['types'] if api_type['name'] == 'ExampleUnit')
        watt = next(value for value in unit['enums'][0]['values'] if value['name'] == 'Watt')
        watt['deprecated'] = True
        record = guipluginsapi.make_record(old, (1, 0), api())
        again = next(api_type for api_type in record['types'] if api_type['name'] == 'Example')
        self.assertTrue(again.get('deprecated'))
        self.assertTrue(next(prop for prop in again['properties'] if prop['name'] == 'text').get('deprecated'))
        self.assertNotIn('deprecated', next(prop for prop in again['properties'] if prop['name'] == 'productId'))
        again_unit = next(api_type for api_type in record['types'] if api_type['name'] == 'ExampleUnit')
        again_watt = next(value for value in again_unit['enums'][0]['values'] if value['name'] == 'Watt')
        self.assertTrue(again_watt.get('deprecated'))
        self.assertNotIn('deprecated', next(value for value in again_unit['enums'][0]['values']
                                            if value['name'] == 'None'))

    def test_unbumped_additions_are_refused(self):
        types = api(qml=QML_TYPE.replace('\tsignal clicked\n', '\tsignal clicked\n\tproperty string caption\n'))
        record = guipluginsapi.make_record(OLD_RECORD, (1, 0), types)
        message = guipluginsapi.unbumped_additions_message(
            OLD_RECORD, (1, 0), record, 'tools/guiplugins-api.json', '.github/gui-plugins.md')
        self.assertIn('Refusing to write tools/guiplugins-api.json.', message)
        self.assertIn('  Example.caption', message)
        self.assertIn('is still 1.0, the same version as in tools/guiplugins-api.json', message)
        self.assertIn('Increase VICTRON_GUIPLUGINS_VERSION_MINOR in cmake/ModuleGuiPlugins.cmake', message)
        self.assertIn('so the module version is newer than 1.0', message)
        self.assertIn('2. Run this script again.', message)
        self.assertIn('Do not edit tools/guiplugins-api.json by hand.', message)
        self.assertIn('did not change tools/guiplugins-api.json or .github/gui-plugins.md', message)
        self.assertNotIn('restore', message)
        shown = guipluginsapi.unbumped_additions_message(
            OLD_RECORD, (1, 0), record, guipluginsapi.DEFAULT_OUTPUT, guipluginsapi.DEFAULT_DOCS)
        self.assertIn('Refusing to write tools/guiplugins-api.json.', shown)
        self.assertIn('.github/gui-plugins.md', shown)
        self.assertNotIn(guipluginsapi.DEFAULT_OUTPUT, shown)
        self.assertEqual(guipluginsapi.unbumped_additions(OLD_RECORD, (1, 1), record), [])
        self.assertEqual(guipluginsapi.unbumped_additions_message(
            OLD_RECORD, (1, 1), record, 'tools/guiplugins-api.json', '.github/gui-plugins.md'), '')
        self.assertEqual(guipluginsapi.unbumped_additions(None, (1, 0), record), [])

        lowered = dict(OLD_RECORD, version='1.1')
        older = guipluginsapi.unbumped_additions_message(
            lowered, (1, 0), record, 'tools/guiplugins-api.json', '.github/gui-plugins.md')
        self.assertIn('is 1.0, which is older than 1.1 in tools/guiplugins-api.json', older)
        self.assertIn('newer than 1.1', older)

    def test_script_does_not_write_an_unbumped_addition(self):
        version, types = guipluginsapi.read_api(guipluginsapi.SOURCE_DIR)
        types = json.loads(json.dumps(types))
        page = next(api_type for api_type in types if api_type['name'] == 'PluginPage')
        page.setdefault('properties', []).append({'name': 'captionAddedForTest', 'type': 'string'})
        written = []
        real_open = open

        def tracking_open(path, mode='r', *args, **kwargs):
            if any(flag in mode for flag in ('w', 'a', 'x')):
                written.append(path)
                raise AssertionError('should not write %s' % path)
            return real_open(path, mode, *args, **kwargs)

        stdout = StringIO()
        argv = [sys.argv[0], '--source-dir', guipluginsapi.SOURCE_DIR]
        with mock.patch.object(guipluginsapi, 'read_api', lambda source_dir: (version, types)), \
                mock.patch('builtins.open', tracking_open), \
                mock.patch.object(sys, 'argv', argv), \
                mock.patch('sys.stdout', stdout):
            code = guipluginsapi.main()
        self.assertEqual(code, 1)
        self.assertEqual(written, [])
        text = stdout.getvalue()
        self.assertIn('Refusing to write tools/guiplugins-api.json.', text)
        self.assertIn('  PluginPage.captionAddedForTest', text)
        self.assertIn('1. Increase VICTRON_GUIPLUGINS_VERSION_MINOR in cmake/ModuleGuiPlugins.cmake', text)
        self.assertIn('2. Run this script again.', text)
        self.assertIn('Do not edit tools/guiplugins-api.json by hand.', text)

    def test_source_tree_is_up_to_date(self):
        result = subprocess.run([sys.executable, '-B', os.path.join(TOOLS_DIR, 'guipluginsapi.py'), '--check'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
