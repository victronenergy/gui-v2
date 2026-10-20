#
# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.
#
# Tests for tools/moduledependencies.py. Each test breaks one rule in a small source tree held in memory.

import os
import sys
import unittest

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools')

# Do not leave a __pycache__ directory in the source tree.
sys.dont_write_bytecode = True
sys.path.insert(0, TOOLS_DIR)
import moduledependencies  # noqa: E402

# A tree that follows the rules: GuiPlugins uses VenusOS, and VenusOS uses Branding.
TREE = {
    'CMakeLists.txt': 'include(cmake/ModuleVenus.cmake)\n',
    'cmake/ModuleVenus_Sources.cmake': (
        'set (VictronVenusOS_QML_MODULE_SOURCES # The QML files\n'
        '    components/Gauge.qml\n'
        ')\n'
        'list(APPEND VictronVenusOS_CPP_SOURCES\n'
        '    src/theme.h\n'
        '    src/theme.cpp\n'
        ')\n'),
    'cmake/ModuleVenus.cmake': (
        'qt_add_qml_module(VictronVenusOS\n'
        '    URI Victron.VenusOS\n'
        '    IMPORTS QtQuick.Controls.Basic\n'
        '    QML_FILES ${VictronVenusOS_QML_MODULE_SOURCES}\n'
        ')\n'
        'target_link_libraries(VictronVenusOS PUBLIC VictronBranding)\n'),
    'cmake/ModuleBranding_Sources.cmake': (
        'set(VictronBranding_CPP_SOURCES\n'
        '    src/branding/branding.h\n'
        '    src/branding/branding.cpp\n'
        ')\n'),
    'cmake/ModuleBranding.cmake': (
        'qt_add_qml_module(VictronBranding\n'
        '    URI Victron.Branding\n'
        '    DEPENDENCIES QtQuick\n'
        ')\n'
        'target_link_libraries(VictronBranding PRIVATE Qt6::Core)\n'),
    'cmake/ModuleGuiPlugins_Sources.cmake': (
        'set(VictronGuiPlugins_CPP_SOURCES\n'
        '    src/plugins/pluginpage.h\n'
        '    src/plugins/pluginpage.cpp\n'
        ')\n'),
    'cmake/ModuleGuiPlugins.cmake': (
        'qt_add_qml_module(VictronGuiPlugins\n'
        '    URI Victron.GuiPlugins\n'
        '    IMPORTS Victron.VenusOS\n'
        ')\n'
        'target_link_libraries(VictronGuiPlugins PRIVATE VictronVenusOS)\n'),
    'components/Gauge.qml': 'import QtQuick\nimport Victron.VenusOS\nItem {}\n',
    'src/theme.h': '#include <QObject>\n#include "branding.h"\n',
    'src/theme.cpp': '#include "theme.h"\n',
    'src/branding/branding.h': '#include <QObject>\n#include <optional>\n',
    'src/branding/branding.cpp': '#include "branding.h"\n',
    'src/plugins/pluginpage.h': '#include "theme.h"\n',
    'src/plugins/pluginpage.cpp': '#include "pluginpage.h"\n',
}


class TestModuleDependencies(unittest.TestCase):
    def check(self, changes):
        """Runs the check on TREE, with changes ({path: text}) applied."""
        tree = dict(TREE, **changes)
        cmake_paths = [path for path in tree if path.endswith('.cmake') or path == 'CMakeLists.txt']
        return moduledependencies.check(tree.get, cmake_paths)

    def assertOneProblem(self, changes, expected):
        problems = self.check(changes)
        self.assertEqual(len(problems), 1, problems)
        self.assertIn(expected, problems[0])

    def test_tree_that_follows_the_rules_passes(self):
        self.assertEqual(self.check({}), [])

    def test_venusos_qml_file_imports_guiplugins(self):
        self.assertOneProblem({'components/Gauge.qml': 'import QtQuick\nimport Victron.GuiPlugins\nItem {}\n'},
                              'components/Gauge.qml imports Victron.GuiPlugins')

    def test_venusos_qml_module_lists_guiplugins(self):
        for keyword in ('IMPORTS', 'OPTIONAL_IMPORTS', 'DEFAULT_IMPORTS', 'DEPENDENCIES'):
            with self.subTest(keyword=keyword):
                cmake = TREE['cmake/ModuleVenus.cmake'].replace(
                    '    QML_FILES', '    %s Victron.GuiPlugins/auto\n    QML_FILES' % keyword)
                self.assertOneProblem({'cmake/ModuleVenus.cmake': cmake},
                                      'qt_add_qml_module(VictronVenusOS) lists Victron.GuiPlugins')

    def test_venusos_source_includes_guiplugins_header(self):
        self.assertOneProblem({'src/theme.cpp': '#include "theme.h"\n#include "plugins/pluginpage.h"\n'},
                              'src/theme.cpp includes src/plugins/pluginpage.h')

    def test_venusos_links_guiplugins(self):
        cmake = TREE['cmake/ModuleVenus.cmake'] + 'target_link_libraries(VictronVenusOS PRIVATE VictronGuiPlugins)\n'
        self.assertOneProblem({'cmake/ModuleVenus.cmake': cmake}, 'VictronVenusOS links VictronGuiPlugins')

    def test_branding_qml_module_lists_victron_module(self):
        cmake = TREE['cmake/ModuleBranding.cmake'].replace('DEPENDENCIES QtQuick', 'IMPORTS Victron.VenusOS')
        self.assertOneProblem({'cmake/ModuleBranding.cmake': cmake},
                              'qt_add_qml_module(VictronBranding) lists Victron.VenusOS')

    def test_branding_qml_file_imports_victron_module(self):
        sources = TREE['cmake/ModuleBranding_Sources.cmake'] + 'set(VictronBranding_QML_FILES Brand.qml)\n'
        self.assertOneProblem({'cmake/ModuleBranding_Sources.cmake': sources,
                               'Brand.qml': 'import QtQuick\nimport Victron.VenusOS\nItem {}\n'},
                              'Brand.qml imports Victron.VenusOS')

    def test_branding_source_includes_victron_header(self):
        for include in ('"theme.h"', '<theme.h>', '"../theme.h"'):
            with self.subTest(include=include):
                text = '#include "branding.h"\n#include %s\n' % include
                self.assertOneProblem({'src/branding/branding.cpp': text}, 'src/branding/branding.cpp includes')

    def test_branding_links_victron_library(self):
        cmake = TREE['cmake/ModuleBranding.cmake'] + 'target_link_libraries(VictronBranding PUBLIC VictronVenusOS)\n'
        self.assertOneProblem({'cmake/ModuleBranding.cmake': cmake}, 'VictronBranding links VictronVenusOS')

    def test_guiplugins_header_has_same_name_as_venusos_header(self):
        venus = TREE['cmake/ModuleVenus_Sources.cmake'].replace('    src/theme.h\n', '    src/theme.h\n    src/units.h\n')
        guiplugins = TREE['cmake/ModuleGuiPlugins_Sources.cmake'].replace('    src/plugins/pluginpage.h\n',
                                                                          '    src/plugins/pluginpage.h\n'
                                                                          '    src/plugins/units.h\n')
        self.assertOneProblem({'cmake/ModuleVenus_Sources.cmake': venus,
                               'cmake/ModuleGuiPlugins_Sources.cmake': guiplugins},
                              'src/units.h and src/plugins/units.h have the same file name')

    def test_source_tree_follows_the_rules(self):
        self.assertEqual(moduledependencies.check_source_dir(os.path.join(TOOLS_DIR, '..')), [])


if __name__ == '__main__':
    unittest.main()
