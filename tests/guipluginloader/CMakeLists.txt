add_single_file_unit_test(guipluginloader)

# The Victron.GuiPlugins module version (see cmake/ModuleGuiPlugins.cmake), so that the tests check
# that the plugin loader compares plugins against it.
target_compile_definitions(tst_guipluginloader PRIVATE
    VICTRON_GUIPLUGINS_VERSION_MAJOR=${VICTRON_GUIPLUGINS_VERSION_MAJOR}
    VICTRON_GUIPLUGINS_VERSION_MINOR=${VICTRON_GUIPLUGINS_VERSION_MINOR}
)
