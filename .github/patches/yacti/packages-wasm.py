import logging
import multiprocessing as mp
import pathlib
from typing import List

import py7zr

from .fetchers import Package
from .helpers import check
from .helpers import configure_logging
from .helpers import download_package


def _fetch_package(install_path: pathlib.Path, url: str, sha1: str):
    configure_logging()

    name = pathlib.Path(url).name
    path = install_path / 'yaqti_archives' / name

    path.parent.mkdir(exist_ok=True, parents=True)

    if path.exists():
        logging.info(f'skipping download for {name}')
    else:
        download_sha1 = download_package(url, path)

        if download_sha1 != sha1:
            logging.warning(f'hashes do not match for {name}')

    logging.info(f'unzipping {name} to {install_path}')
    with py7zr.SevenZipFile(path, 'r') as zip_file:
        zip_file.extractall(path=install_path)

    logging.info(f'deleting {name} package')
    path.unlink()


def fetch_packages(install_directory: str, packages: List[Package]):
    install_path = pathlib.Path(install_directory)
    # check(not install_path.exists(), f'trying to extract to {install_path} but it already exists...')

    logging.info(f'installing {len(packages)} to {install_path}')

    tasks = []
    for package in packages:
        tasks += [(install_path, url, package.sha1) for url in package.archive_urls]

    ctx = mp.get_context("spawn")
    pool = ctx.Pool(None)
    pool.starmap(_fetch_package, tasks)
    pool.close()
    pool.join()
