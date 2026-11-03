set(VictronUiTest_QML_MODULE_SOURCES
    tests/ui/RecursivePageCapture.qml
    tests/ui/benchmark/overview/tst_benchmark_overview.qml
    tests/ui/benchmark/pages/tst_benchmark_pages.qml
    tests/ui/plugins/ProbeBroken_Page.qml
    tests/ui/plugins/ProbeNav_Page.qml
    tests/ui/plugins/tst_plugins.qml
    tests/ui/smoke/generic-capture/tst_all.qml
    tests/ui/smoke/mock-maximal/tst_boat.qml
    tests/ui/smoke/mock-maximal/tst_brief.qml
    tests/ui/smoke/mock-maximal/tst_cards.qml
    tests/ui/smoke/mock-maximal/tst_levels.qml
    tests/ui/smoke/mock-maximal/tst_notifications.qml
    tests/ui/smoke/mock-maximal/tst_overview.qml
    tests/ui/smoke/mock-maximal/tst_settings.qml
    tests/ui/start-page/StartPageNavPage.qml
    tests/ui/start-page/StartPageTestCase.qml
    tests/ui/start-page/maximal/tst_start_page.qml
    tests/ui/start-page/no-levels/tst_start_page.qml
    tests/ui/target-page/tst_target_page.qml
)

set_source_files_properties(tests/ui/plugins/ProbeBroken_Page.qml PROPERTIES
    QT_QML_SKIP_CACHEGEN TRUE
)

SET(VictronUiTest_QML_MODULE_RESOURCES
    tests/ui/benchmark/overview/overview.json
    tests/ui/benchmark/pages/pages.json
    tests/ui/plugins/plugins.json
    tests/ui/smoke/generic-capture/generic-capture.json
    tests/ui/smoke/mock-maximal/mock-maximal.json
    tests/ui/start-page/maximal/maximal.json
    tests/ui/start-page/no-levels/no-levels.json
)
