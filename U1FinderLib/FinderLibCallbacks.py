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

# Volume List
def volume_list(folders):
    volumes_json = '{ type:"volume_list" volumes: { \n\t{ volume:"' + os.path.expanduser('~/Ubuntu One') + '" subscribed:"YES" }'
    for folder in folders:
        volumes_json += ',\n\t{ volume:"' + folder['path'] + '" subscribed:"' + ('YES' if bool(folder['subscribed']) else 'NO') + '" }'
    volumes_json += '\n} }'
    return volumes_json

# File is Synchronizing
def get_uploads(uploads):
    return_list = []
    for upload in uploads:
        return_list.append(upload['path'])
    return return_list

def get_downloads(downloads):
    return_list = []
    for download in downloads:
        return_list.append(upload['downloads'])
    return return_list

# Make File Public
def change_public_access(info, path):
    return '{ type:"file_is_public" path:"' + path + '" is_public:"' + ('YES' if bool(info['is_public']) else 'NO') + '" public_url:"' + ('' if not bool(info['public_url']) else info['public_url']) + '" }'


# Get Public Link
def get_public_files(public_files, path):
    for public_file in public_files:
        if public_file['path'] == path:
            return '{ type:"get_public_url" path:"' + path + '" public_url:"' + public_file['public_url'] + '" }'
        
    return '{ type:"error" reason:"The file is not public" }'
