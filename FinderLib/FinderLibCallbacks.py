#!/usr/bin/env python
# coding=utf8

# Ubuntu One Finder Plugin
# Copyright (C) 2012 - José Expósito <jose.exposito89@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

import os

def volume_list(folders):
    volumes_json = '{ type:"volumeList" volumes: { \n\t{ volume:"' + os.path.expanduser('~/Ubuntu One') + '" subscribed:"YES" }'
    for folder in folders:
        volumes_json += ',\n\t{ volume:"' + folder['path'] + '" subscribed:"' + ('YES' if bool(folder['subscribed']) else 'NO') + '" }'
    volumes_json += '\n} }'
    return volumes_json
