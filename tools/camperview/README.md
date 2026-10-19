# camperview

Standalone Camper visualization app for desktop and WebAssembly builds.

## Build (desktop)

```bash
cmake -S tools/camperview -B build-camperview-desktop -DCMAKE_PREFIX_PATH=C:\Development\Qt\6.8.3\msvc2022_64
cmake --build build-camperview-desktop --config Debug
```

Run:

```bash
build-camperview-desktop\Debug\camperview.exe
```

## Build (WebAssembly)

Use a Qt-for-WASM toolchain with Ninja, for example:

```bash
cmake -G Ninja -S tools/camperview -B build-camperview-wasm ^
  -DCMAKE_TOOLCHAIN_FILE=C:\Development\Qt\6.8.3\wasm_singlethread\lib\cmake\Qt6\qt.toolchain.cmake ^
  -DQT_HOST_PATH=C:\Development\Qt\6.8.3\msvc2022_64
cmake --build build-camperview-wasm
```

## Host data contract (WASM)

The app polls `window.camperViewData` and expects a JSON-like object:

```js
window.camperViewData = {
  activeInputSource: "grid",   // "grid" | "shore" | "generator" | "none"
  gridShorePower: 1850,
  generatorPower: null,
  solarPower: 1320,
  batteryPower: 410,
  alternatorPower: 0,
  dcLoadsPower: 290,
  acLoadsPower: 1210
};
```

If no host object is available, the app falls back to animated mock data.
