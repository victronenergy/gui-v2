#
# Copyright (C) 2025 Victron Energy B.V.
# See LICENSE.txt for license information.
#

'''
Converts a simulation CSV file to a JSON file for data/mock/conf/services.

Run from the root gui-v2 directory:
    python tools/simuluation_csv_to_json.py <input-file> <output-file>

Each line in the input CSV should have four columns (path, type, value,
string value) aside from the first line, which is the service name.
Any other lines, including those starting with a digit (for timed
simulation purposes) are ignored. The output is sorted alphabetically.

For example, if the input CSV is:

com.victronenergy.battery.socketcan_vecan0_vi1_uc478868
/CustomName     STRING  House battery 1
/ParallelConnectThreshold       ARRAY   []
/Dc/0/Current	DOUBLE	-0.30000001192092896	-0.3A
/N2kUniqueNumber        UINT32  478868  478868

This converts to:
{
    "com.victronenergy.battery.socketcan_vecan0_vi1_uc478868": {
        "/CustomName": "House battery 1",
        "/Dc/0/Current": -0.30000001192092896,
        "/N2kUniqueNumber": 478868,
        "/ParallelConnectThreshold": null
    }
}
'''

import sys, json

class JsonOutputData:
    def __init__(self, uid):
        self.uid = uid
        self.data = {}

    def add_value(self, path, value):
        self.data[path] = value

    def write_to_file(self, output_fname):
        with open(output_fname, 'w') as f:
            service_data = { self.uid: self.data }
            f.write(json.dumps(service_data, sort_keys=True, indent=4))

def get_json_value(type_name, value):
    if type_name == 'STRING':
        if value is None:
            return ''
        else:
            return value
    elif type_name.startswith('INT') or type_name.startswith('UINT') or type_name == 'BYTE':
        return int(value)
    elif type_name == 'DOUBLE':
        return float(value)
    elif type_name == 'ARRAY[BYTE]':
        print('Ignore byte array, not used by gui-v2:', value)
    elif type_name == 'ARRAY':
        # Entries with ARRAY=[] will be returned as None. Currently there are no ARRAY
        # values other than '[]'.
        if value == '[]':
            pass
        else:
            raise ValueError(f'Unexpected ARRAY value: {value}')
    return None

def convert(input_fname, output_fname):
    with open(input_fname) as f:
        uid = f.readline().strip()
        output = JsonOutputData(uid)
        for line in f.readlines():
            line = line.rstrip()
            if not line:
                break
            parts = line.split('\t')
            if len(parts) > 4:
                break
            path, type_name = parts[:2]
            value = parts[2] if len(parts) > 2 else None
            output.add_value(path, get_json_value(type_name, value))
    output.write_to_file(output_fname)

if __name__ == '__main__':
    if len(sys.argv) <= 2:
        print(__doc__)
        sys.exit(-1)
    input_fname = sys.argv[1]
    output_fname = sys.argv[2]
    convert(input_fname, output_fname)
