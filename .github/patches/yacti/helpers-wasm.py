import logging
from typing import Tuple
import hashlib
import time

import requests


def configure_logging():
    logging.basicConfig(level=logging.INFO)


def check(value: bool, msg: str):
    if not value:
        raise ValueError(msg)


def split_version(version: str) -> Tuple[int, int, int]:
    components = version.replace("_wasm", "").split('.')

    msg_prefix = f'{version} is an invalid version name; '
    check(len(components) == 3, msg_prefix + 'expect a format X.Y.Z e.g. 5.15.0 or 6.2.0')
    check(all(i.isdigit() for i in components), msg_prefix + 'major, minor, and patch can only be numbers')

    components = tuple(int(i) for i in components)
    return components


def is_valid_url(url: str):
    try:
        return requests.head(url).ok
    except:
        return False


def download_package(url: str, path: str, hash_algo: str = 'sha1') -> str:
    logging.info(f'downloading file from {url} to {path}')
    time_start = time.process_time()

    hash = hashlib.new(hash_algo)
    req = requests.get(url, stream=True)

    with open(path, "wb") as binary_file:
        for chunk in req.iter_content(chunk_size=8196):
            binary_file.write(chunk)
            hash.update(chunk)

    time_end = time.process_time()
    time_taken = time_end - time_start
    logging.info(f'downloading {path} took {time_taken:.2f}s')

    return hash.digest()
