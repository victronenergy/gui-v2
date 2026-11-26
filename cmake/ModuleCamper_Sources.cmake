# Paths are relative to the gui-v2 source directory. A standalone host includes this file too, see
# tools/camperview/CMakeLists.txt.

set(VictronCamper_QML_MODULE_SOURCES
    components/camper/CamperBattery.qml
    components/camper/CamperColors.qml
    components/camper/CamperDevice.qml
    components/camper/CamperDomainCard.qml
    components/camper/CamperFlowArrow.qml
    components/camper/CamperOverviewScene.qml
    components/camper/CamperOverviewView.qml
    components/camper/CamperState.qml
    components/camper/CamperTheme.qml
)

set(VictronCamper_QML_MODULE_RESOURCES
    images/camper/camper_card_shadow.png
    images/camper/camper_device.svg
    images/camper/camper_nosolar_charging_dark.svg
    images/camper/camper_nosolar_charging_light.svg
    images/camper/camper_nosolar_driving_dark.svg
    images/camper/camper_nosolar_driving_light.svg
    images/camper/camper_nosolar_offgrid_dark.svg
    images/camper/camper_nosolar_offgrid_light.svg
    images/camper/camper_solar_charging_dark.svg
    images/camper/camper_solar_charging_light.svg
    images/camper/camper_solar_driving_dark.svg
    images/camper/camper_solar_driving_light.svg
    images/camper/camper_solar_offgrid_dark.svg
    images/camper/camper_solar_offgrid_light.svg
)

# The gui-v2 icons that the cards show. gui-v2 already has them in Victron.VenusOS, so only a
# standalone host adds them to its resources.
set(VictronCamper_HOST_IMAGES
    images/acloads.svg
    images/alternator.svg
    images/dcloads.svg
    images/generator.svg
    images/grid.svg
    images/shore.svg
    images/solaryield.svg
)
