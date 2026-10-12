# Copyright (C) 2026 Victron Energy B.V.
# See LICENSE.txt for license information.

"""Pixel-identity proof for the geometry token condensation.

Fails if a deleted spacing, radius, or border token's recorded
(five-inch, seven-inch, portrait) triple is not exactly the
replacement token's triple, or if a deleted name remains in the
tree outside this file. If a keeper is intentionally retuned,
update the recorded triple here in the same change.
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
GEOM_DIR = ROOT / "themes" / "geometry"
SIZES = ("FiveInch", "SevenInch", "Portrait")

# old name -> (replacement name, five, seven, portrait)
REPLACEMENTS = {
    "geometry_acInputDirectionIcon_rightMargin": ("geometry_space_2", (2, 2, 2)),
    "geometry_batteryListPage_item_verticalSpacing": ("geometry_space_2", (2, 2, 2)),
    "geometry_boatPage_batteryCenterGauge_detailsRow_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_boatPage_batteryCenterGauge_detailsRow_topPadding": ("geometry_overviewPage_widget_content_horizontalMargin", (8, 12, 12)),
    "geometry_boatPage_batteryCenterGauge_title_bottomPadding": ("geometry_space_12", (12, 12, 12)),
    "geometry_boatPage_batteryCenterGauge_title_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_boatPage_row_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_boatPage_temperature_row_spacing": ("geometry_controlCardsPage_bottomMargin", (16, 24, 24)),
    "geometry_boatPage_temperature_temperatureColumn_spacing": ("geometry_space_2", (2, 2, 2)),
    "geometry_boatPage_temperature_temperatureRow_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_briefPage_centerGauge_centerText_horizontalSpacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_briefPage_edgeGauge_gaugeSpacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_briefPage_edgeGauge_horizontalMargin": ("geometry_page_content_horizontalMargin", (24, 40, 16)),
    "geometry_briefPage_edgeGauge_initialize_margin": ("geometry_space_10", (10, 10, 10)),
    "geometry_briefPage_edgeGauge_quantityLabel_feedback_margin": ("geometry_space_4", (4, 4, 4)),
    "geometry_briefPage_edgeGauge_quantityLabel_spacing": ("geometry_space_2", (2, 2, 2)),
    "geometry_button_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_button_padding": ("geometry_space_4", (4, 4, 4)),
    "geometry_button_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_circularMultiGauge_spacing": ("geometry_listItem_flat_content_horizontalMargin", (16, 16, 12)),
    "geometry_circularMultiGauge_value_rightMargin": ("geometry_space_2", (2, 2, 2)),
    "geometry_closeButton_rightMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_colorWheelDialog_mode_button_verticalMargin": ("geometry_space_18", (18, 18, 18)),
    "geometry_colorWheelDialog_preset_button_radius": ("geometry_radius_6", (6, 6, 6)),
    "geometry_colorWheelDialog_preset_trash_spacing": ("geometry_statusBar_spacing", (16, 16, 8)),
    "geometry_colorWheelDialog_rightPadding": ("geometry_listItem_content_horizontalMargin", (24, 24, 12)),
    "geometry_colorWheel_selector_swatch_borderWidth": ("geometry_border_2", (2, 2, 2)),
    "geometry_colorWheel_slider_borderWidth": ("geometry_border_2", (2, 2, 2)),
    "geometry_comboBox_leftPadding": ("geometry_space_18", (18, 18, 18)),
    "geometry_comboBox_rightPadding": ("geometry_space_10", (10, 10, 10)),
    "geometry_comboBox_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_comboBox_verticalPadding": ("geometry_space_10", (10, 10, 10)),
    "geometry_controlCard_contentMargins": ("geometry_space_16", (16, 16, 16)),
    "geometry_controlCard_status_topMargin": ("geometry_space_6", (6, 6, 6)),
    "geometry_controlCard_title_topMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_controlCardsPage_horizontalMargin": ("geometry_page_content_horizontalMargin", (24, 40, 16)),
    "geometry_demoModeIndicator_horizontalPadding": ("geometry_space_12", (12, 12, 12)),
    "geometry_droopGraph_container_graph_leftMargin": ("geometry_page_content_horizontalMargin", (24, 40, 16)),
    "geometry_droopGraph_container_graph_topMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_droopGraph_container_label_leftMargin": ("geometry_controlCard_button_margins", (24, 24, 16)),
    "geometry_droopGraph_container_label_topMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_droopGraph_container_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_droopGraph_operationPoint_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_droopGraph_xAxis_label_padding": ("geometry_space_4", (4, 4, 4)),
    "geometry_emptyPageItem_column_spacing": ("geometry_space_10", (10, 10, 10)),
    "geometry_emptyPageItem_primaryLabel_topPadding": ("geometry_space_10", (10, 10, 10)),
    "geometry_environmentGaugePanel_verticalPadding": ("geometry_solarDetailBox_margins", (8, 8, 12)),
    "geometry_environmentGauge_tick_margin": ("geometry_environmentGauge_gauge_horizontalPadding", (8, 8, 0)),
    "geometry_environmentGauge_valueMarker_padding": ("geometry_space_2", (2, 2, 2)),
    "geometry_environmentGauge_verticalPadding": ("geometry_space_4", (4, 4, 4)),
    "geometry_generatorIconLabel_icon_margin": ("geometry_space_4", (4, 4, 4)),
    "geometry_gradientList_bottomMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_gradientList_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_iochannel_label_margin": ("geometry_space_2", (2, 2, 2)),
    "geometry_iochannel_spacing": ("geometry_space_16", (16, 16, 16)),
    "geometry_iochannel_status_horizontalPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_iochannel_status_verticalPadding": ("geometry_space_2", (2, 2, 2)),
    "geometry_levelsGauge_gauge_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_levelsGauge_horizontalSpacing": ("geometry_space_12", (12, 12, 12)),
    "geometry_levelsGauge_verticalPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_levelsPage_gauge_spacing_small": ("geometry_space_16", (16, 16, 16)),
    "geometry_levelsPage_gauge_spacing_tiny": ("geometry_space_8", (8, 8, 8)),
    "geometry_levelsPage_gaugesView_compact_bottomMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_levelsPage_tankGauge_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_listItemButton_horizontalPadding": ("geometry_space_16", (16, 16, 16)),
    "geometry_listItem_content_spacing": ("geometry_listItem_content_verticalMargin", (12, 16, 8)),
    "geometry_listItem_content_verticalSpacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_listItem_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_listSectionHeader_bottomPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_listSectionHeader_topPadding": ("geometry_space_18", (18, 18, 18)),
    "geometry_miniSlider_decorator_vertical_padding": ("geometry_space_6", (6, 6, 6)),
    "geometry_miniSlider_text_padding": ("geometry_space_12", (12, 12, 12)),
    "geometry_modalDialog_bottomPadding": ("geometry_listItem_content_horizontalMargin", (24, 24, 12)),
    "geometry_modalDialog_content_spacing": ("geometry_space_16", (16, 16, 16)),
    "geometry_modalDialog_grabber_topMargin": ("geometry_space_6", (6, 6, 6)),
    "geometry_modalDialog_header_verticalPadding": ("geometry_space_12", (12, 12, 12)),
    "geometry_modalWarningDialog_description_spacing": ("geometry_space_12", (12, 12, 12)),
    "geometry_navigationBar_button_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_navigationBar_initialize_margin": ("geometry_space_12", (12, 12, 12)),
    "geometry_navigationBar_notifications_redDot_margin": ("geometry_space_6", (6, 6, 6)),
    "geometry_notificationsPage_delegate_unacknowledged_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_opportunityLoad_button_radius": ("geometry_radius_6", (6, 6, 6)),
    "geometry_opportunityLoad_margin": ("geometry_space_4", (4, 4, 4)),
    "geometry_overviewPage_connector_anchor_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_overviewPage_widget_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_overviewPage_widget_content_bottomMargin_large": ("geometry_space_8", (8, 8, 8)),
    "geometry_overviewPage_widget_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_overviewPage_widget_sideGauge_margins": ("geometry_space_8", (8, 8, 8)),
    "geometry_overviewPage_widget_solar_graph_bar_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_overviewPage_widget_solar_graph_bar_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_overviewPage_widget_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_progressBar_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_quantityGroupRow_spacing": ("geometry_space_12", (12, 12, 12)),
    "geometry_quantityLabel_spacing": ("geometry_space_2", (2, 2, 2)),
    "geometry_quantityTableSummary_verticalMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_radioButton_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_scrollBar_bar_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_separatorBar_horizontalMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_settingsListHeader_bottomPadding": ("geometry_space_2", (2, 2, 2)),
    "geometry_settingsListHeader_topPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_settingsListNavigation_verticalPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_settings_gsmModem_signalStrengthBars_spacing": ("geometry_space_2", (2, 2, 2)),
    "geometry_settings_gsmModem_signalStrengthBars_topMargin": ("geometry_space_2", (2, 2, 2)),
    "geometry_sidePanel_sideWidget_bottomMargin": ("geometry_space_4", (4, 4, 4)),
    "geometry_sidePanel_sideWidget_horizontalMargin": ("geometry_levelsGauge_horizontalPadding", (0, 0, 16)),
    "geometry_sidePanel_sideWidget_spacing": ("geometry_space_16", (16, 16, 16)),
    "geometry_silenceAlarmButton_horizontalPadding": ("geometry_space_16", (16, 16, 16)),
    "geometry_slider_groove_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_slider_spacing": ("geometry_space_12", (12, 12, 12)),
    "geometry_solarChart_bar_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_solarChart_bar_spacing_fourteenDays": ("geometry_space_6", (6, 6, 6)),
    "geometry_solarChart_bar_spacing_sevenDays": ("geometry_space_8", (8, 8, 8)),
    "geometry_solarChart_bar_spacing_thirtyDays": ("geometry_space_4", (4, 4, 4)),
    "geometry_solarDailyHistoryDialog_background_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_solarDetailBox_header_bottomPadding": ("geometry_quantityMetricPadding", (8, 8, 4)),
    "geometry_solarDetailBox_separator_horizontalMargin": ("geometry_space_12", (12, 12, 12)),
    "geometry_solarDetailBox_title_bottomPadding": ("geometry_space_2", (2, 2, 2)),
    "geometry_solarDetailBox_verticalPadding": ("geometry_space_8", (8, 8, 8)),
    "geometry_solarHistoryErrorView_expandIcon_horizontalMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_solarHistoryErrorView_radius": ("geometry_radius_6", (6, 6, 6)),
    "geometry_solarHistoryErrorView_textBackground_bottomMargin": ("geometry_space_10", (10, 10, 10)),
    "geometry_solarHistoryErrorView_textBackground_horizontalMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_spinBox_indicator_radius": ("geometry_radius_6", (6, 6, 6)),
    "geometry_spinBox_wide_spacing": ("geometry_space_10", (10, 10, 10)),
    "geometry_splashView_progressText_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_splashView_progressText_topMargin": ("geometry_space_12", (12, 12, 12)),
    "geometry_switch_groove_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_switches_header_topMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_tabBar_horizontalMargin": ("geometry_space_6", (6, 6, 6)),
    "geometry_tankGaugeDialog_closeButton_leftMargin": ("geometry_space_12", (12, 12, 12)),
    "geometry_tankGaugeDialog_closeButton_rightMargin": ("geometry_space_16", (16, 16, 16)),
    "geometry_temperatureSlider_dot_padding": ("geometry_space_4", (4, 4, 4)),
    "geometry_temperatureSlider_popup_padding": ("geometry_space_8", (8, 8, 8)),
    "geometry_temperatureSlider_popup_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_temperatureSlider_text_horizontal_padding": ("geometry_space_8", (8, 8, 8)),
    "geometry_textField_horizontalMargin": ("geometry_statusBar_spacing", (16, 16, 8)),
    "geometry_three_phase_gauge_spacing": ("geometry_space_4", (4, 4, 4)),
    "geometry_toastNotification_padding": ("geometry_space_16", (16, 16, 16)),
    "geometry_toastNotification_radius": ("geometry_radius_8", (8, 8, 8)),
    "geometry_toastNotification_verticalMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_valueIndicator_horizontalMargin": ("geometry_space_12", (12, 12, 12)),
    "geometry_valueIndicator_slider_handle_border_width": ("geometry_border_2", (2, 2, 2)),
    "geometry_vebusDeviceListPage_quantityTable_row_spacing": ("geometry_levelsPage_panel_background_title_padding", (4, 4, 0)),
    "geometry_welcome_button_spacing": ("geometry_space_8", (8, 8, 8)),
    "geometry_welcome_header_bottomMargin": ("geometry_space_4", (4, 4, 4)),
    "geometry_welcome_title_bottomMargin": ("geometry_space_8", (8, 8, 8)),
    "geometry_widgetHeader_spacing": ("geometry_space_4", (4, 4, 4)),
}

DELETED_UNUSED = (
    "geometry_briefPage_edgeGauge_spacing",
)

MISFILED = {
    "geometry_overviewPage_connector_animationPowerThreshold": 30,
    "geometry_levelsPage_max_tank_count": (5, 6, 6),
}


def resolve(data):
    resolved = {}
    pending = {}
    for key, value in data.items():
        if isinstance(value, str):
            pending[key] = value
        else:
            resolved[key] = value
    guard = 0
    while pending:
        guard += 1
        if guard > 30:
            raise SystemExit("alias cycle: %s" % sorted(pending))
        progress = False
        for key, target in list(pending.items()):
            if target in resolved:
                resolved[key] = resolved[target]
                del pending[key]
                progress = True
            elif target not in data:
                raise SystemExit("missing alias %s -> %s" % (key, target))
        if not progress:
            raise SystemExit("stuck aliases: %s" % sorted(pending))
    return resolved


def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)


def main():
    files = {}
    for size in SIZES:
        files[size] = json.loads((GEOM_DIR / (size + ".json")).read_text(encoding="utf-8"))
    key_sets = [set(files[size]) for size in SIZES]
    if key_sets[0] != key_sets[1] or key_sets[0] != key_sets[2]:
        fail("geometry key sets differ")
    resolved = {size: resolve(files[size]) for size in SIZES}

    deleted = set(REPLACEMENTS) | set(DELETED_UNUSED) | set(MISFILED)
    for old, (new, triple) in REPLACEMENTS.items():
        if old in key_sets[0]:
            fail("deleted key still present: %s" % old)
        if new not in key_sets[0]:
            fail("replacement missing: %s (for %s)" % (new, old))
        current = tuple(resolved[size][new] for size in SIZES)
        if current != tuple(triple):
            fail("%s triple %s != recorded %s for %s" % (new, current, triple, old))
    for name in list(DELETED_UNUSED) + list(MISFILED):
        if name in key_sets[0]:
            fail("deleted key still present: %s" % name)

    skip_parts = {"build", ".git"}
    source_exts = {".qml", ".js", ".mjs", ".cpp", ".h", ".c", ".md", ".py", ".cmake", ".txt", ".html"}
    self_path = pathlib.Path(__file__).resolve()
    for path in ROOT.rglob("*"):
        if not path.is_file() or any(part in skip_parts for part in path.parts):
            continue
        if path.resolve() == self_path:
            continue
        if path.suffix.lower() not in source_exts and not (path.suffix == ".json" and "themes" in path.parts):
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for name in deleted:
            if re.search(r"\b" + re.escape(name) + r"\b", text):
                fail("%s still references %s" % (path.relative_to(ROOT), name))

    landscape = (ROOT / "pages" / "OverviewPage_Landscape.qml").read_text(encoding="utf-8")
    portrait = (ROOT / "pages" / "OverviewPage_Portrait.qml").read_text(encoding="utf-8")
    for text, label in ((landscape, "landscape"), (portrait, "portrait")):
        if "readonly property int connectorAnimationPowerThreshold: 30" not in text:
            fail("%s overview page missing power threshold 30" % label)
        if "Theme.root.connectorAnimationPowerThreshold" in text:
            fail("%s power threshold is still prefixed with Theme" % label)
        if "root.connectorAnimationPowerThreshold" not in text:
            fail("%s power threshold call sites missing" % label)
    gauges = (ROOT / "components" / "Gauges.js").read_text(encoding="utf-8")
    if "function maxTankCount()" not in gauges:
        fail("Gauges.maxTankCount() missing")
    if "return 5" not in gauges or "return 6" not in gauges:
        fail("tank count table missing")
    for rel in ("pages/TanksTab.qml", "components/ExpandedTanksView.qml"):
        text = (ROOT / rel).read_text(encoding="utf-8")
        if "Theme.Gauges.maxTankCount" in text:
            fail("%s still prefixes Gauges.maxTankCount with Theme" % rel)
        if "Gauges.maxTankCount()" not in text:
            fail("%s missing Gauges.maxTankCount()" % rel)
    print("geometry condensation proof ok (%d retargeted, %d unused, %d misfiled)" % (
        len(REPLACEMENTS), len(DELETED_UNUSED), len(MISFILED)))


if __name__ == "__main__":
    main()
