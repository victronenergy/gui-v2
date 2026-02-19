set(VictronBoat_QML_MODULE_RESOURCES
    images/boat_glow.png
    images/icon_battery_40.png
    images/icon_boat_32.svg
    images/icon_engine_temp_32.svg
    images/icon_motorController_32.svg
    images/icon_propeller_32.png
    images/icon_propeller.svg
    images/icon_temp_coolant_32.svg
)

set(VictronBoat_QML_MODULE_SOURCES
    pages/boat/BoatPage.qml
    pages/boat/Background.qml
    pages/boat/BatteryArc.qml
    pages/boat/BatteryPercentage.qml
    pages/boat/ConsumptionGauge.qml
    pages/boat/Gear.qml
    pages/boat/Gps.qml
    pages/boat/LargeCenterGauge.qml
    pages/boat/LoadArc.qml
    pages/boat/MotorDrive.qml
    pages/boat/MotorDrives.qml
    pages/boat/MotorDriveGauges.qml
    pages/boat/PortraitBoatPage.qml
    pages/boat/QuantityLabelIconRow.qml
    pages/boat/TemperatureGauge.qml
    pages/boat/TemperatureGauges.qml
    pages/boat/TimeToGo.qml
)

set_source_files_properties(pages/boat/BoatPage.qml PROPERTIES QT_RESOURCE_ALIAS BoatPage.qml)
set_source_files_properties(pages/boat/Background.qml PROPERTIES QT_RESOURCE_ALIAS Background.qml)
set_source_files_properties(pages/boat/BatteryArc.qml PROPERTIES QT_RESOURCE_ALIAS BatteryArc.qml)
set_source_files_properties(pages/boat/BatteryPercentage.qml PROPERTIES QT_RESOURCE_ALIAS BatteryPercentage.qml)
set_source_files_properties(pages/boat/ConsumptionGauge.qml PROPERTIES QT_RESOURCE_ALIAS ConsumptionGauge.qml)
set_source_files_properties(pages/boat/Gear.qml PROPERTIES QT_RESOURCE_ALIAS Gear.qml)
set_source_files_properties(pages/boat/Gps.qml PROPERTIES QT_RESOURCE_ALIAS Gps.qml)
set_source_files_properties(pages/boat/LargeCenterGauge.qml PROPERTIES QT_RESOURCE_ALIAS LargeCenterGauge.qml)
set_source_files_properties(pages/boat/LoadArc.qml PROPERTIES QT_RESOURCE_ALIAS LoadArc.qml)
set_source_files_properties(pages/boat/MotorDrive.qml PROPERTIES QT_RESOURCE_ALIAS MotorDrive.qml)
set_source_files_properties(pages/boat/MotorDrives.qml PROPERTIES QT_RESOURCE_ALIAS MotorDrives.qml)
set_source_files_properties(pages/boat/MotorDriveGauges.qml PROPERTIES QT_RESOURCE_ALIAS MotorDriveGauges.qml)
set_source_files_properties(pages/boat/PortraitBoatPage.qml PROPERTIES QT_RESOURCE_ALIAS PortraitBoatPage.qml)
set_source_files_properties(pages/boat/QuantityLabelIconRow.qml PROPERTIES QT_RESOURCE_ALIAS QuantityLabelIconRow.qml)
set_source_files_properties(pages/boat/TemperatureGauge.qml PROPERTIES QT_RESOURCE_ALIAS TemperatureGauge.qml)
set_source_files_properties(pages/boat/TemperatureGauges.qml PROPERTIES QT_RESOURCE_ALIAS TemperatureGauges.qml)
set_source_files_properties(pages/boat/TimeToGo.qml PROPERTIES QT_RESOURCE_ALIAS TimeToGo.qml)

