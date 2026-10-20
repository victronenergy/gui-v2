add_single_file_unit_test(branding)

# Branding files that the tests load through the plugin loader. They are compiled into the test
# executable, so the tests load them from qrc:/branding-test/<name>/Branding.qml, as the loader
# loads a plugin's Branding file from its resource file.
qt_add_resources(tst_branding "tst_branding_files"
    PREFIX "/branding-test"
    BASE data
    FILES
        data/child_object/Branding.qml
        data/import/Branding.qml
        data/not_a_Branding/Branding.qml
        data/syntax_error/Branding.qml
        data/valid/Branding.qml
)

