#
# Copyright (C) 2023 Victron Energy B.V.
# See LICENSE.txt for license information.
#

'''
Removes unused theme properties from the theme json files.

Run from the root gui-v2 directory:
    python tools/themepruner.py
'''

import os, sys

def find_theme_files(root_dir):
    'Returns a list of all JSON files in the directory and its subdirectories.'
    json_files = []
    for root, dirs, files in os.walk(os.path.join(root_dir, 'themes')):
        for filename in files:
            if filename.endswith('.json'):
                json_files.append(os.path.join(root, filename))
    return json_files

def find_source_code_files(root_dir):
    'Returns a list of all QML and JS files in the directory and its subdirectories.'
    source_code_files = []
    for root, dirs, files in os.walk(root_dir):
        for filename in files:
            if filename.endswith('.qml') or filename.endswith('.js'):
                source_code_files.append(os.path.join(root, filename))
    return source_code_files

def parse_theme_property(line):
    'Parses the theme property from a line formatted like ["<name>": value].'
    line = line.strip()
    try:
        name, value = line.split(':')
    except ValueError:
        return ('','')
    name = name.strip().replace('"', '')
    value = value.strip().replace(',', '').replace('"', '')
    return (name, value)

def parse_theme_properties(json_filename):
    'Returns a list of the theme properties parsed from the JSON file.'
    theme_properties = []
    with open(json_filename) as f:
        for line in f.readlines():
            property_name, property_value = parse_theme_property(line)
            if property_name:
                theme_properties.append((property_name, property_value))
    return theme_properties

def find_theme_properties_in_source_code_file(source_code_filename, theme_property_names):
    'Returns the theme properties from the given list that are found in this QML file.'
    properties_to_find = [name for name in theme_property_names]
    found_properties = []
    with open(source_code_filename) as source_code_file:
        for line in source_code_file.readlines():
            # Update found_properties with the properties found in this line.
            properties_found_in_line = [property_name for property_name in properties_to_find if f'Theme.{property_name}' in line]
            found_properties.extend(properties_found_in_line)

            # Remove these from the list of properties that need to be found.
            for property_name in properties_found_in_line:
                properties_to_find.remove(property_name)
            if not properties_to_find:
                break
    return found_properties

def remove_theme_properties(json_filename, properties_to_remove):
    'Rewrites a JSON file so that it does not contain the specified theme properties.'
    output_lines = []
    with open(json_filename) as theme_file:
        # For each line, if it refers to a property to be removed, then omit this line from the new
        # JSON file to be written.
        for line in theme_file.readlines():
            matched = False
            for i, theme_property_name in enumerate(properties_to_remove):
                if theme_property_name == parse_theme_property(line)[0]:
                    del properties_to_remove[i]
                    matched = True
                    break
            if not matched:
                output_lines.append(line)
    with open(json_filename, 'w') as theme_file:
        theme_file.writelines(output_lines)

def main(root_dir):
    'Finds unused theme properties and removes them from the json files.'
    source_code_filenames = find_source_code_files(root_dir)
    all_theme_properties = {}
    nested_theme_properties = {}
    for json_filename in find_theme_files(root_dir):
        print(f'Parsing {json_filename}...')
        for theme_property_name, theme_property_value in parse_theme_properties(json_filename):
            if '_' in theme_property_value:
                nested_theme_properties.setdefault(theme_property_name, []).append(theme_property_value)
            all_theme_properties.setdefault(theme_property_name, []).append(json_filename)

    # Search each QML file. Each time a theme property is found in a QML file, remove it from the
    # map. Keep searching until all theme properties are found, or until we've searched all files.
    print('Searching QML and JS files...')
    unused_theme_properties = all_theme_properties.copy()
    for source_code_filename in source_code_filenames:
        for theme_property in find_theme_properties_in_source_code_file(source_code_filename, unused_theme_properties.keys()):
            del unused_theme_properties[theme_property]

    # Now unused_theme_properties is a list of the properties that are not used in any QML/JS files.
    # But, a property might be used as a value for another property that *is* used by a QML/JS file.
    # So, make sure those properties are not removed.
    required_nested_property_names = set()
    for theme_property_name in unused_theme_properties.keys():
        for nested_theme_property_name, nested_theme_property_values in nested_theme_properties.items():
            if theme_property_name in nested_theme_property_values and nested_theme_property_name not in unused_theme_properties.keys():
                print(f'Do not remove {theme_property_name}, used for value of {nested_theme_property_name}')
                required_nested_property_names.add(theme_property_name)
    for theme_property_name in required_nested_property_names:
        del unused_theme_properties[theme_property_name]

    print('Unused theme values:')
    for theme_property_name in unused_theme_properties.keys():
        print('\t', theme_property_name)

    json_files_with_unused_properties = {}
    for theme_property_name, json_filenames in unused_theme_properties.items():
        for json_filename in json_filenames:
            json_files_with_unused_properties.setdefault(json_filename, []).append(theme_property_name)
    for json_filename, theme_property_names in json_files_with_unused_properties.items():
        print(f'Removing {len(theme_property_names)} unused theme values from {json_filename}...')
        remove_theme_properties(json_filename, theme_property_names)

if __name__ == '__main__':
    if len(sys.argv) > 1 or not os.path.exists(os.path.join(os.getcwd(), 'tools')):
        print(__doc__)
    else:
        main(os.getcwd())
