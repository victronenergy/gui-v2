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

Desktop, for development only. Point it at the MQTT broker of a GX device:

```bash
/opt/Qt/6.8.3/gcc_64/bin/qt-cmake -S tools/camperview -B build-camperview
cmake --build build-camperview
build-camperview/camperview --mqtt 192.168.1.10:1883
```

## Connecting to a device

The app reads the device values over MQTT itself, with `VeQuickItem` and the MQTT backend from the
`Victron.VeUtil` module, so the host does not have to pass any values in. The host gives the
connection in the query of the page URL, with the same parameters as the gui-v2 WebAssembly build:

| Parameter | Meaning |
|---|---|
| `mqtt` | WebSocket URL of the broker, e.g. `ws://192.168.1.10:9001/websocket-mqtt` on a LAN |
| `id` | Portal id of the device. Without `mqtt`, it selects the VRM broker for that device. |
| `shard` | VRM broker shard, instead of deriving it from `id` |
| `user`, `pass` | MQTT credentials |
| `token` | VRM token, used as the password together with `user` |
| `colorScheme` | `light` or `dark` |

For example, through VRM:

```
index.html?id=<portal id>&user=<vrm user>&token=<vrm token>&colorScheme=dark
```

The host is expected to embed the illustration only if `/Settings/Gui/CustomIllustration` is 1.

Values are read from the totals of `com.victronenergy.system`, as this app does not have the gui-v2
data models. Solar is shown as present when the system reports any DC or AC PV power. If no broker is
given, the illustration shows no values. It never shows sample data, as that could be mistaken for
real readings.

Text is currently in English only.
