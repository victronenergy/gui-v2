#
# Copyright (C) 2024 Victron Energy B.V.
# See LICENSE.txt for license information.
#

cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0048 NEW)
project(tests LANGUAGES CXX)

add_subdirectory(units)
add_subdirectory(screenblanker)