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

import objc
import os
from   twisted.internet import (cfreactor, defer)
from   ubuntuone.platform.tools import (SyncDaemonTool, is_already_running)
from Foundation import (NSObject, NSString, NSMutableArray)

##
# Delegates of the U1FinderLib
class U1FinderLibDelegate(NSObject):

    @objc.typedSelector('v@:@')
    def returnedVolumeList_(self, volumes):
        pass

##
# Objective-C facade to the methods of the U1FinderLib.
class U1FinderLib(NSObject):
    
    ##
    # Default constructor.
    @objc.typedSelector('@@:@')
    def initWithDelegate_(self, delegate):
        self = super(U1FinderLib, self).init()
        self.sync_daemon_tool = SyncDaemonTool(None)
        self.delegate = delegate
        cfreactor.install()
        return self
    
    ##
    # Returns the list of the shared volumes in a NSArray<NSString>. Example:
    #
    # [
    #    @"/Users/jose/Ubuntu One",
    #    @"/Users/jose/Pictures"
    # ]
    @objc.typedSelector('v@:')
    def volumeList(self):
        d = self.sync_daemon_tool.get_folders()
        d.addCallback(lambda r: volume_list(r, self.delegate))
        return None

    ##
    # Indicates if the specified file is in synchronization process. Example output:
    # { type:"file_is_synchronizing" path:"/Users/jose/Ubuntu One/Document.pdf" synchronizing:"YES/NO" }
    @objc.typedSelector('@@:@')
    def fileIsSynchronizing_(self, filePath):
        reactor.callWhenRunning(run_command, "file_is_synchronizing", [filePath], self.sync_daemon_tool)
        reactor.run()
        return returned_value[0]
    
    ##
    # Publish or unpublish the specified file. Example output:
    # { type:"file_is_public" path:"/Users/jose/Ubuntu One/Document.pdf" is_public:"YES/NO" public_url:"http://ubuntuone.com/..." }
    @objc.typedSelector('@@:@B')
    def makeFile_public_(self, filePath, public):
        reactor.callWhenRunning(run_command, "make_file_public", [filePath, public], self.sync_daemon_tool)
        reactor.run()
        return returned_value[0]

    ##
    # Returns the link of a public file or nil if the file is not public. Example output:
    # { type:"get_public_url" path:"/Users/jose/Ubuntu One/Document.pdf" public_url:"http://ubuntuone.com/..." }
    @objc.typedSelector('@@:@')
    def getPublicLinkOfFile_(self, filePath):
        reactor.callWhenRunning(run_command, "get_public_link", [filePath], self.sync_daemon_tool)
        reactor.run()
        return returned_value[0]


## CALLBACK FUNCTIONS ##


def volume_list(folders, delegate):
    volumes = NSMutableArray.alloc().init()
    volumes.addObject_(NSString.alloc().initWithString_(os.path.expanduser('~/Ubuntu One')))
    
    for folder in folders:
        if (bool(folder['subscribed'])):
            volumes.addObject_(NSString.alloc().initWithString_(folder['path']))

    delegate.returnedVolumeList_(volumes)

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
