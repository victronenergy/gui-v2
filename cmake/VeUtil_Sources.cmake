include_directories(src/veutil/inc src .)

set(VEUTIL_CORE_SOURCES
    src/veutil/inc/veutil/qt/alternator_error.hpp
    src/veutil/inc/veutil/qt/bms_error.hpp
    src/veutil/inc/veutil/qt/charger_error.hpp
    src/veutil/inc/veutil/qt/firmware_updater_data.hpp
    src/veutil/inc/veutil/qt/genset_error.hpp
    src/veutil/inc/veutil/qt/unit_conversion.hpp
    src/veutil/inc/veutil/qt/vebus_error.hpp
    src/veutil/inc/veutil/qt/ve_qitem.hpp
    src/veutil/inc/veutil/qt/ve_qitem_child_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_loader.hpp
    src/veutil/inc/veutil/qt/ve_qitem_sort_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_table_model.hpp
    src/veutil/inc/veutil/qt/ve_qitem_tree_model.hpp
    src/veutil/inc/veutil/qt/ve_quick_item.hpp

    src/veutil/src/qt/alternator_error.cpp
    src/veutil/src/qt/bms_error.cpp
    src/veutil/src/qt/charger_error.cpp
    src/veutil/src/qt/genset_error.cpp
    src/veutil/src/qt/unit_conversion.cpp
    src/veutil/src/qt/vebus_error.cpp
    src/veutil/src/qt/ve_qitem.cpp
    src/veutil/src/qt/ve_qitem_child_model.cpp
    src/veutil/src/qt/ve_qitem_loader.cpp
    src/veutil/src/qt/ve_qitem_sort_table_model.cpp
    src/veutil/src/qt/ve_qitem_table_model.cpp
    src/veutil/src/qt/ve_qitem_tree_model.cpp
    src/veutil/src/qt/ve_quick_item.cpp
)

set(VEUTIL_MQTT_SOURCES
    src/veutil/inc/veutil/qt/ve_qitems_mqtt.hpp

    src/veutil/src/qt/ve_qitems_mqtt.cpp
)

SET(VEUTIL_DBUS_SOURCES
    src/veutil/inc/veutil/qt/ve_dbus_connection.hpp
    src/veutil/inc/veutil/qt/ve_qitems_dbus.hpp

    src/veutil/src/qt/ve_dbus_connection.cpp
    src/veutil/src/qt/ve_qitems_dbus.cpp
)

list(APPEND VictronVenusOS_CPP_SOURCES ${VEUTIL_CORE_SOURCES})
list(APPEND VictronVenusOS_CPP_SOURCES ${VEUTIL_MQTT_SOURCES})
if(NOT VENUS_WEBASSEMBLY_BUILD)
    list(APPEND VictronVenusOS_CPP_SOURCES ${VEUTIL_DBUS_SOURCES} )
endif()

