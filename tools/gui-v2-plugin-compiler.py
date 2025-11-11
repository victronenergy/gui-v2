import json
import os
import sys
import subprocess
import argparse
import base64
import shutil

def collect_filenames(directory, suffix):
    files = []
    for filename in os.listdir(directory):
        if filename.endswith(suffix):
            files.append(filename)
    return files

def run_lupdate(qmlFiles, tsFiles, name):
    cmd = ['lupdate']
    cmd.extend(qmlFiles)
    if len(tsFiles) > 0:
        cmd.extend(['-ts'])
        for tsFile in tsFiles:
            cmd.extend([tsFile])
    else:
        defaultTsName = "" + name + "_en.ts"
        cmd.extend(['-ts', defaultTsName])
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if result.stdout:
            print("    lupdate output:", result.stdout)
        if result.stderr:
            print("    lupdate stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"    lupdate returncode: {e.returncode}")
        print("    lupdate error:", e.stderr, file=sys.stderr)

def run_lrelease(tsFiles, name):
    if len(tsFiles) == 0:
        tsFiles.append("" + name + "_en.ts")
    for filename in tsFiles:
        qmFile = filename[:-2] + "qm"
        cmd = ['lrelease']
        cmd.extend([filename])
        cmd.extend(['-idbased'])
        cmd.extend(['-qm', qmFile])
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            if result.stdout:
                print("    lrelease output:", result.stdout)
            if result.stderr:
                print("    lrelease stderr:", result.stderr)
        except subprocess.CalledProcessError as e:
            print(f"    lrelease returncode: {e.returncode}")
            print("    lrelease error:", e.stderr, file=sys.stderr)

def write_qrc(qmlFiles, qmFiles, imageFiles, name):
    allFiles = qmlFiles + qmFiles + imageFiles
    contents = "<RCC>\n<qresource prefix=\"/" + name + "\">\n"
    for filename in allFiles:
        contents += "<file>" + filename + "</file>\n"
    contents += "</qresource>\n</RCC>\n"
    try:
        filename = "" + name + ".qrc"
        with open(filename, 'w') as file:
            file.write(contents)
    except IOError as e:
        print(f"    Error writing to file: {e}")

def run_rcc(name):
    if shutil.which('rcc'):
        rccPath = 'rcc'
    else:
        lreleasePath = shutil.which('lrelease')
        rccPath = lreleasePath.replace('/usr/bin/lrelease', '/usr/libexec/rcc')

    qrcFile = "" + name + ".qrc"
    rccFile = "" + name + ".rcc"
    cmd = [rccPath]
    cmd.extend(['-binary'])
    cmd.extend(['-compress-algo', 'zlib'])
    cmd.extend(['-o', rccFile])
    cmd.extend([qrcFile])
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if result.stdout:
            print("    rcc output:", result.stdout)
        if result.stderr:
            print("    rcc stderr:", result.stderr)
    except subprocess.CalledProcessError as e:
        print("    rcc error:", e.stderr, file=sys.stderr)
    except FileNotFoundError:
        print("    rcc not found, perhaps generate .rcc manually from .qrc then pass it with --rcc <filename>")

def b64_encode_rcc(name):
    rccFile = "" + name + ".rcc"
    base64Str = ""
    try:
        with open(rccFile, 'rb') as file:
            data = file.read()
            base64data = base64.b64encode(data)
            base64Str = base64data.decode('utf-8')
    except FileNotFoundError:
        print("    cannot open " + rccFile + " for reading!")
    return base64Str

def write_compiled_json(name, version, minRequiredVersion, maxRequiredVersion, translations, integrations, resource):
    dataDict = {
        "name": name,
        "version": version,
        "minRequiredVersion": minRequiredVersion,
        "maxRequiredVersion": maxRequiredVersion,
        "translations": translations,
        "integrations": integrations,
        "resource": resource
    }
    with open(name+'.json', 'w', encoding='utf-8') as file:
        json.dump(dataDict, file, indent=4)
        file.write('\n')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='gui-v2-plugin-compiler',
        description='Compiles plugins for gui-v2 into json files')

    parser.add_argument('--rcc', nargs='?', default='') # debugging only...
    parser.add_argument('-n', '--name', required=True, help='The name of your plugin')
    parser.add_argument('-v', '--version', default='1.0', help='The version of your plugin')
    parser.add_argument('-z', '--min-required-version', default='', help='The minimum gui-v2 version required for the plugin')
    parser.add_argument('-x', '--max-required-version', default='', help='The maximum gui-v2 version compatible with this plugin')
    parser.add_argument('-s', '--settings', default='', help='The main settings page .qml associated with your plugin')
    parser.add_argument('-d', '--devicelist', required=False, nargs='+', action='append', help='Triplet of product id, settings page .qml, and title text (or translation id)')
    parser.add_argument('-g', '--navigation', default='')
    parser.add_argument('-q', '--quickaccess', default='')
    parser.add_argument('-c', '--card', default='')

    args = parser.parse_args()

    imageFiles = collect_filenames('.', '.svg')
    imageFiles += collect_filenames('.', '.png')
    qmlFiles = collect_filenames('.', '.qml')
    tsFiles = collect_filenames('.', '.ts')

    print("--- running lupdate")
    run_lupdate(qmlFiles, tsFiles, args.name)

    print("--- running lrelease")
    run_lrelease(tsFiles, args.name)
    qmFiles = collect_filenames('.', '.qm')

    print("--- writing .qrc")
    write_qrc(qmlFiles, qmFiles, imageFiles, args.name)

    print("--- running rcc")
    if len(args.rcc) == 0:
        run_rcc(args.name)

    print("--- base64 encoding rcc data")
    resource = b64_encode_rcc(args.name)

    print("--- building translations array")
    translations = []
    for qmFile in qmFiles:
        translations.append("qrc:/" + args.name + "/" + qmFile)

    print("--- building integrations dictionary")
    integrations = []
    if len(args.settings) > 0:
        if not args.settings.endswith('.qml'):
            print("Invalid settings page specified, must be a .qml file")
            sys.exit(1)
        settingsIntegration = {
            "type": 1,
            "url": "qrc:/" + args.name + "/" + args.settings
        }
        integrations.append(settingsIntegration)
    if args.devicelist:
        if len(args.devicelist) > 0:
            for integration in args.devicelist:
                if len(integration) != 3:
                    print("Invalid devicelist triplet!")
                    sys.exit(1)
                if not integration[0].startswith(('0x', '0X')):
                    print("Invalid product id specified in devicelist triplet, must be a hex string starting with 0x")
                    sys.exit(1)
                if not integration[1].endswith('.qml'):
                    print("Invalid settings page specified in devicelist triplet, must be a .qml file")
                    sys.exit(1)
                devicelistIntegration = {
                    "type": 2,
                    "productId": integration[0],
                    "url": "qrc:/" + args.name + "/" + integration[1],
                    "title": integration[2]
                }
                integrations.append(devicelistIntegration)
    if len(args.navigation) > 0:
        print("TODO: navigation...")
    if len(args.quickaccess) > 0:
        print("TODO: quick access...")
    if len(args.card) > 0:
        print("TODO: card...")

    print("--- writing compiled json")
    write_compiled_json(args.name, args.version, args.min_required_version, args.max_required_version, translations, integrations, resource)

    print("--- done!")
    sys.exit(0)

