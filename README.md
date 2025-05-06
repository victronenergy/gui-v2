# gui-v2, part of Victron Energy Venus OS

![image](https://github.com/victronenergy/gui-v2/assets/5200296/cbf9b7c0-6d8f-4bef-82c5-ec74230e4f87)

Venus OS is the software that runs on the Victron family of [GX monitoring devices](https://www.victronenergy.com/communication-centres), as well as RaspberryPis. gui-v2 is the next generation UI for Venus OS.

gui-v2 is for the on-screen display on a GX Touch 50, 70 and Ekrano GX. And also to be used remotely in a webbrowser, aka the Victron Remote Console feature.

For more technical information on Venus OS, see the [Venus OS wiki](https://github.com/victronenergy/venus/wiki).

## Main differences between gui-v1 and gui-v2

- Touch oriented, rather than button oriented.
- New looks
- Based on Qt6 instead of Qt4
- Remote Console is done by running a Webassembly (WASM) build in the browser, and data over MQTT, rather than (browser based-) VNC
- Besides being a UI, gui-v1 also took care of various more core tasks, like starting stopping services; those have all been moved to the venus-platform repo.
- Because gui-v2 is can also run remotely (WASM), it can no longer issue commands directly to Venus OS. The only data path is MQTT (for WASM) and D-Bus (when
- running locally on the GX). For that, various features have been added to venus-platform (like starting a reboot, or starting a firmware update) so that the
- command for that can be issued over D-Bus / MQTT. Same for creation of settings; they need to be created elsewhere.

**Status:** gui-v2, know as "New UI" was released in Venus OS 3.50.

**How to install:** See https://bit.ly/gui-v2

## Don't use the issue tracker for support

Do not use the issue tracker in this repo to ask for support. The issue tracker is our development workflow; and not for support. Instead, please use the open Venus OS beta thread on the [Modifications section on Victron Community](https://community.victronenergy.com/c/modifications/5) (see top section on that page).

## Modifications

The prime reason to share this source code publicly is to allow for modifications. But that will work differently than in gui-v1.

While all the sources of gui-v1 were not open source, all the visible elements were taken care of in QML, of which are non-compiled files that could be edited after obtaining root access to the GX device. This allowed for modifications. Small ones, but also large projects like Kevin Windrems [gui-mods](https://github.com/kwindrem/GuiMods).

In gui-v2 this is a bit different. The QML files are still on the rootfs and can be edited, but doing so only changes the version you see on screen. It won't change the version used remotely in a browser, ie. the WASM version. That is a compiled single binary blob, which can't be rebuild on the GX itself.

Building the WASM requires lots of tooling installed (Qt6, emscriptem), and then takes a while. To learn more, see the guiv-2 [automated build](https://github.com/victronenergy/gui-v2/blob/main/.github/workflows/build-wasm.yml), a Github Action workflow in this repo, as well as the [[how to build page in the gui-v2 wiki](https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2).

Concluding, we'll need a different solution to allow modifications. Preferably one that, like gui-v2, has a low barrier to get started. Publishing these sources is a first step.

To discuss this, see https://communityarchive.victronenergy.com/questions/245056/venus-os-modifying-gui-v2.html.

## Building

See the wiki page: https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2

## License

See license file in the repo.
