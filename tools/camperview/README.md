# camperview

Standalone RV illustration, for embedding in hosts such as VictronConnect, VRM and MFDs. It shares
its QML with the gui-v2 `CamperPage`, from `components/camper`.

## Build

WebAssembly, using the toolchain from `scripts/.env`:

```bash
bash scripts/build-camperview-wasm.sh
```

The files to host are written to `build-camperview-wasm_files_to_copy/`, including `.gz` and `.br`
versions of the wasm file, which has been optimized with `wasm-opt`.

Desktop, for development only. This build has no host, so it cycles through sample data:

```bash
/opt/Qt/6.8.3/gcc_64/bin/qt-cmake -S tools/camperview -B build-camperview
cmake --build build-camperview
build-camperview/camperview
```

## Host data contract

The app reads `window.camperViewData` every 750 ms. The host fills it in from the Venus OS paths in
the comments below, and is expected to embed this illustration only if
`/Settings/Gui/CustomIllustration` is 1.

```js
window.camperViewData = {
  colorScheme: "light",      // "light" | "dark"

  activeInputSource: 3,      // com.victronenergy.system/Ac/ActiveIn/Source
  acInputConnected: true,    // whether any com.victronenergy.system/Ac/In/x/Connected is 1
  alternatorState: 0,        // com.victronenergy.alternator/State; omit if there is no alternator
  lowSocAlarm: 0,            // /Alarms/LowSoc of the active battery service
  solarPresent: true,        // whether the installation has solar panels
  generatorPresent: true,    // whether any com.victronenergy.system/Ac/In/x/Source is 2

  // Values in Watts, except for batterySoc, which is a percentage. Omit any that are not available.
  activeInputPower: 1850,
  generatorPower: 0,
  solarPower: 1320,
  alternatorPower: 0,
  batteryPower: 410,         // positive when charging, as for /Dc/Battery/Power
  batterySoc: 82,
  dcLoadsPower: 290,
  acLoadsPower: 1210
};
```

If `window.camperViewData` is not set, the illustration shows no values. It does not fall back to
sample data, as that could be mistaken for real readings.

Text is currently in English only.
