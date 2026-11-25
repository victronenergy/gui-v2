# camperview

Standalone RV illustration, for embedding in hosts such as VictronConnect, VRM and MFDs. It uses the
same `Victron.Camper` QML module as the gui-v2 `CamperPage` (`components/camper`,
`cmake/ModuleCamper.cmake`), which uses only Qt Quick.

## Build

The app builds `Victron.VeUtil` from the `src/veutil` git submodule, so fetch it first:

```bash
git submodule update --init src/veutil
```

WebAssembly, using the toolchain from `scripts/.env` (the script also needs `brotli`):

```bash
bash scripts/build-camperview-wasm.sh
```

The files to host are written to `build-camperview-wasm_files_to_copy/`, including `.gz` and `.br`
versions of the wasm file, which has been optimized with `wasm-opt`. It enables only the wasm
features the build already uses, so that older Safari, iOS WebViews and MFD browsers can run it.
As for gui-v2, `camperview.js` exposes the loader as `window.createQtAppInstance`, which the VRM
remote console calls.

Desktop, for development only. Point it at the MQTT broker of a GX device:

```bash
/opt/Qt/6.8.3/gcc_64/bin/qt-cmake -S tools/camperview -B build-camperview
cmake --build build-camperview
build-camperview/camperview --mqtt 192.168.1.10:1883
```

## Connecting to a device

The app reads the device values over MQTT itself, with `VeQuickItem` and the MQTT backend from the
`Victron.VeUtil` module, so the host does not have to pass any values in. The host gives the
connection with the same options as gui-v2: as command-line arguments (`--mqtt <url>`), which is how
the VRM remote console starts a WebAssembly build, or else in the query of the page URL (`?mqtt=<url>`).

| Option | Meaning |
|---|---|
| `mqtt` | WebSocket URL of the broker, e.g. `ws://192.168.1.10:9001/websocket-mqtt` on a LAN; `host[:port]` on the desktop |
| `id` | Portal id of the device. Without `mqtt`, it selects the VRM broker for that device (WebAssembly only). |
| `shard` | VRM broker shard, instead of deriving it from `id` (WebAssembly only). `vrm`, which makes gui-v2 log in to the VRM API, is not supported: the app warns and uses `id` instead. |
| `user`, `pass` | MQTT credentials |
| `token` | VRM token, used as the password together with `user` |
| `colorScheme` | `light`, `dark`, `auto` (follows the system, or the browser in WebAssembly) or `default`. Case is ignored. `default`, also used when the option is missing or unknown, follows the device's display settings as gui-v2 does, else light. |

On the desktop the broker can only be a plain MQTT `host[:port]`, so `id` or `shard` alone selects no
broker: pass `--mqtt`.

For example, the VRM remote console passes:

```
--mqtt wss://webmqtt<n>.victronenergy.com/mqtt?idUser=<n> --id <portal id> --user <vrm user> --pass <JWT> --colorScheme auto
```

The host is expected to embed the illustration only if `/Settings/Gui/CustomIllustration` is 1.

Values are read from the totals of `com.victronenergy.system`, as this app does not have the gui-v2
data models. The app only reads values: `CamperState` in the module decides what they mean, for
both this app and gui-v2. Solar is present when there is a solar charger, a PV inverter, or an
inverter or Multi with trackers, as on the gui-v2 overview. A value the device does not publish is
unknown, and is not shown as a known state. If no broker is given, the illustration shows no values
and says it is not configured. While it is not connected, or the device's heartbeat stops, it dims
the illustration and says so. It never shows sample data, as that could be mistaken for real
readings.

## Translations

The text follows the device's `/Settings/Gui/Language`. The build cuts a small catalogue per
language (about 1 KB each) from gui-v2's `i18n/*.ts`, with only the ids that this app and the
module use, so the translations are the ones made for gui-v2. In WebAssembly, the only font is
Roboto, so Arabic, Chinese, Japanese and Thai are shown in English.
