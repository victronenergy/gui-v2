import json
import os
import sys
import subprocess
import argparse
import base64
import shutil

def read_metadata(filePath):
    try:
        with open(filePath, 'r', encoding='utf-8') as file:
            data = json.load(file)
        name = data.get('name')
        version = data.get('name')
        minRequiredVersion = data.get('minRequiredVersion')
        maxRequiredVersion = data.get('maxRequiredVersion')
        if not minRequiredVersion:
            minRequiredVersion = ''
        if not maxRequiredVersion:
            maxRequiredVersion = ''
        return name, version, minRequiredVersion, maxRequiredVersion
    except Exception as e:
        print(f"    Failed to read metadata json file: {e}")

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
            base64str = base64data.decode('utf-8')
    except FileNotFoundError:
        print("    cannot open " + rccFile + " for reading!")
    return base64str

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
        prog='customisationcompiler',
        description='Compiles customisations for gui-v2 into json files')

    parser.add_argument('--rcc', nargs='?', default='') # debugging only...
    parser.add_argument('-m', '--metadata', nargs='?', default='')
    parser.add_argument('-s', '--settings', nargs='?', default='')
    parser.add_argument('-d', '--devicelist', nargs='*')
    parser.add_argument('-n', '--navigation', nargs='?', default='')
    parser.add_argument('-q', '--quickaccess', nargs='?', default='')
    parser.add_argument('-c', '--card', nargs='?', default='')

    args = parser.parse_args()

    if len(args.metadata) == 0:
        print("Error: you must specify a metadata .json file via --metadata <filename>")
        sys.exit(1)

    imageFiles = collect_filenames('.', '.svg')
    imageFiles += collect_filenames('.', '.png')
    qmlFiles = collect_filenames('.', '.qml')
    tsFiles = collect_filenames('.', '.ts')

    print("--- reading metadata .json")
    name, version, minRequiredVersion, maxRequiredVersion = read_metadata(args.metadata)

    print("--- running lupdate")
    run_lupdate(qmlFiles, tsFiles, name)

    print("--- running lrelease")
    run_lrelease(tsFiles, name)
    qmFiles = collect_filenames('.', '.qm')

    print("--- writing .qrc")
    write_qrc(qmlFiles, qmFiles, imageFiles, name)

    print("--- running rcc")
    if len(args.rcc) == 0:
        run_rcc(name)

    print("--- base64 encoding rcc data")
    resource = b64_encode_rcc(name)

    print("--- building translations array")
    translations = []
    for qmFile in qmFiles:
        translations.append("qrc:/" + name + "/" + qmFile)

    print("--- building integrations dictionary")
    integrations = []
    if len(args.settings) > 0:
        settingsIntegration = {
            "type": 1,
            "url": "qrc:/" + name + "/" + args.settings
        }
    if args.devicelist:
        if len(args.devicelist) > 0:
            print("TODO: device list...")
    if len(args.navigation) > 0:
        print("TODO: navigation...")
    if len(args.quickaccess) > 0:
        print("TODO: quick access...")
    if len(args.card) > 0:
        print("TODO: card...")
    integrations.append(settingsIntegration)

    print("--- writing compiled json")
    write_compiled_json(name, version, minRequiredVersion, maxRequiredVersion, translations, integrations, resource)

    print("--- done!")
    sys.exit(0)

