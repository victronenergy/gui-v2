1) Run the following in a terminal which has sourced the Venus OS SDK environment:

python3 ../../tools/customisationcompiler.py \
    --name SimpleTrExample \
    --minrequiredversion v1.2.7 \
    --settings SimpleTrExample_PageSettingsSimple.qml

2) Copy the output file `SimpleTrExample.json` to /tmp/venus-gui-v2/customisations/ on device
3) Run gui-v2 in mock mode, e.g. `/opt/victronenergy/venus-gui-v2 --mock --no-mock-timers`
4) Navigate to Settings -> Integrations -> UI Customisations and confirm the SimpleTrExample customisation exists
5) Navigate to Settings -> Integrations -> UI Customisations -> SimpleTrExample to see the settings page
