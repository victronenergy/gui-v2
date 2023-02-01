from dataclasses import dataclass
from typing import List
from collections import defaultdict
import requests
import logging

import xmltodict

from .helpers import check
from .helpers import split_version


def fetch_versions():
    versions = ("5.9.0", "5.9.1", "5.9.2", "5.9.3", "5.9.4", "5.9.5", "5.9.6", "5.9.7", "5.9.8", "5.9.9", "5.10.0",
                "5.10.1", "5.11.0", "5.11.1", "5.11.2", "5.11.3", "5.12.0", "5.12.1", "5.12.2", "5.12.3", "5.12.4",
                "5.12.5", "5.12.6", "5.12.7", "5.12.8", "5.12.9", "5.12.10", "5.12.11", "5.13.0", "5.13.1", "5.13.2",
                "5.14.0", "5.14.1", "5.14.2", "5.15.0", "5.15.1", "5.15.2", "6.0.0", "6.0.1", "6.0.2", "6.0.3", "6.0.4",
                "6.1.0", "6.1.1", "6.1.2", "6.2.0", "6.2.4", "6.2.4_wasm")

    return versions


def fetch_archive_xml(os: str, platform: str, version: str):
    major, minor, patch = split_version(version)

    arch = "_x86" if os == "windows" else "_x64"

    stub = f'{major}{minor}{patch}_wasm'
    if (major, minor, patch) == (5, 9, 0):
        # note(will.brennan) - Qt changed their naming pattern
        stub = f'59'

    base_url = f'https://download.qt.io/online/qtsdkrepository/{os}{arch}/{platform}/qt{major}_{stub}'
    xml_url = f'{base_url}/Updates.xml'

    r = requests.get(xml_url)

    if r.ok:
        return base_url, xmltodict.parse(r.text)
    else:
        return base_url, None


@dataclass
class Package:
    name: str
    module: str
    description: str
    dependencies: List[str]
    archive_urls: List[str]
    sha1: str


def archive_urls_from_package(base_url: str, package_update) -> List[str]:
    archives = package_update['DownloadableArchives']
    if archives is None:
        return []

    name = package_update['Name']
    version = package_update['Version']

    urls = []

    for archive in archives.split(', '):
        url = f'{base_url}/{name}/{version}{archive}'
        urls.append(url)

    return urls


def fetch_package_infos(base_url: str, xml, modules: List[str]) -> List[Package]:
    logging.info(f'finding packages download paths for modules - {modules}')

    all_packages = {}
    all_modules = defaultdict(list)

    logging.debug('parsing xml into packages')

    for package_update in xml['Updates']['PackageUpdate']:
        name = package_update['Name']
        # note(will.brennan) - we remove addons because of qt6
        module = name.replace('.addons', '').split('.')[3]

        description = package_update['Description']

        dependencies = package_update.get('Dependencies', '')
        if dependencies == None:
            dependencies = ''
        else:
            dependencies = dependencies.split(', ')

        archive_urls = archive_urls_from_package(base_url, package_update)

        sha1 = package_update['SHA1']

        package = Package(name, module, description, dependencies, archive_urls, sha1)

        all_packages[name] = package
        all_modules[module].append(package)

    logging.debug('adding packages for modules')

    packages = {}
    for module in modules:
        check(module in all_modules, f'module {module} is not supported; available modules: {list(all_modules.keys())}')
        module_packages = all_modules[module]

        for package in module_packages:
            packages[package.name] = package

    logging.debug('recursively adding dependencies for selected modules')
    packages_to_scan = list(packages.values())

    while len(packages_to_scan) != 0:
        package = packages_to_scan.pop(-1)

        for dependency in package.dependencies:
            if dependency.startswith('qt.tools'):
                continue

            dependency_type = dependency.split('.')[3]
            if dependency_type in ('doc', 'examples'):
                continue

            if dependency not in packages:
                dependency_package = all_packages[dependency]
                packages[dependency_package.name] = dependency_package
                packages_to_scan.append(dependency_package)

    return list(packages.values())
