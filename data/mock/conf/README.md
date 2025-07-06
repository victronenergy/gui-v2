# Mock configurations

A mock configuration is a JSON file that specifies a set of services and backend values to be loaded into gui-v2 when run in mock mode (i.e. with the --mock option).

Mock configurations are provided for prototyping and UI testing. They are not intended to reflect real systems.
To run gui-v2 with a specific configuration, specify it with the --mock-conf option:

    ./venus-gui-v2 --mock --mock-conf multi-rs

If --mock is set but no configuration is specified, the 'maximal' configuration is used.


## Available mock configurations

- barebones
    - Only contains settings and system services, with minimal settings
    - Useful for testing new/custom services during development; just add the services that you need.

- maximal (as many services as possible)
    - Inverter/chargers:
        - Quattro with 3-phase Grid (feed-in) + Genset, prefers renewable energy
        - Chargers: skylla, phoenix smart charger
        - Inverter RS
    - AC inputs:
        - Grid (on Quattro) and Genset (separate service)
        - DSE genset & generator
    - DC inputs
        - Alternator, OrionXS as alternator
        - DC charger (SmartShunt)
        - Wind
    - Loads: (AC input loads enabled, i.e. has Essential Loads)
        - EVCS x 2 (one controllable, one energy meter)
        - Heat pumps (both input and output)
        - DC loads: dcsystem, OrionXS as dcdc
    - Batteries:
        - BMS, parallel BMS, pylontech
    - Solar:
        - MPPT (some with multiple trackers and/or 3+ days of history)
        - PV inverters (Fronius, EM)
        - Inverter RS
    - Boat page with GPS
    - System:
        - Networking: wifi, modem
        - ESS
        - Digital input, relays
    - Temperature sensors: Ruuvi, generic
    - Tanks: generic
    - Switches: GIO Extender and ES SmartSwitch
    - Pulsemeter, pump, meteo (SolarSense)

- multi-rs (Multi RS inverter/charger)
    - Inverter/chargers: Multi RS with single Grid input, plus solar
    - Boat page without GPS
    - Loads: (AC output loads only, i.e. no Essential Loads)
        - Single EV charger


## Future mock configurations

- 1-phase shore + generator on vebus (no genset) - quattro-1phase-shore-generator.json
- Grid energy meter (not on vebus) - em-grid.json
- DC only system
etc.


# Service configurations

The data/mock/conf/services/*.json files specify sets of service values to be loaded into the mock backend in gui-v2. 

Each file provides a set of values for one or more related services. For example, quattro-1phase-shore-generator.json specifies a Quattro inverter/charger to be published under the com.victronenergy.vebus.ttyO1 service, as well as values for the inverter/charger backup/restore feature to be published under the com.victronenergy.platform service.

While service configurations may be derived from the values on a real system, they may also be modified for testing/verification purposes, so should not be relied upon for final verification.


## Creating service configurations

You could write a JSON configuration from scratch, but it's not that fun.

If you are running gui-v2 on a device or from the browser, go to Settings > Debug & Develop > Values, find the relevant service and press 'P' to dump the object tree in JSON format, or 'Shift+P' to dump it in a prettified format. The output can be used directly as a service configuration. You may have to change the /DeviceInstance for a service to make sure it does not conflict with another service of the same type in your mock configuration.

You can also generate a JSON service configuration from a venus-docker simulation csv file, using `tools/simuluation_csv_to_json.py`.

