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
from Foundation import (NSObject, NSString, NSMutableArray, NSLog)

##
# Delegates of the U1FinderLib
class U1FinderLibDelegate(NSObject):

    @objc.typedSelector('v@:@')
    def returnedVolumeList_(self, volumes):
        pass

    @objc.typedSelector('v@:@')
    def returnedUploads_(self, uploads):
        pass

    @objc.typedSelector('v@:@')
    def returnedDownloads_(self, downloads):
        pass

    @objc.typedSelector('v@:B')
    def returnedFileVisibillity_(self, isPublic):
        pass
    
    @objc.typedSelector('v@:@')
    def returnedPublicLink_(self, publicLink):
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
    # Returns a NSArray<NSString> whit all the files that are being uploaded. Example:
    # [
    #     @"/Users/jose/Ubuntu One/Document.pdf",
    #     @"/Users/jose/Pictures/Image.png"
    # }
    @objc.typedSelector('v@:')
    def currentUploads(self):
        d = self.sync_daemon_tool.get_current_uploads()
        d.addCallback(lambda r: get_uploads(r, self.delegate))
        return None

    ##
    # Like currentUploads() but with the downloads.
    @objc.typedSelector('v@:')
    def currentDownloads(self):
        d = self.sync_daemon_tool.get_current_downloads()
        d.addCallback(lambda r: get_downloads(r, self.delegate))
        return None
    
    ##
    # Indicates if the specified file is public or not.
    @objc.typedSelector('@@:@')
    def isFilePublic_(self, filePath):
        d = self.sync_daemon_tool.get_public_files()
        d.addCallback(lambda r: file_is_public(r, filePath, self.delegate))
        return None
    
    ##
    # Publish or unpublish the specified file.
    @objc.typedSelector('v@:@B')
    def changeFile_visibillity_(self, filePath, isPublic):
        self.sync_daemon_tool.change_public_access(os.path.abspath(filePath), isPublic)
        return None

    ##
    # Returns the link (NSString) of a public file or nil if the file is not public.
    @objc.typedSelector('@@:@')
    def getPublicLinkOfFile_(self, filePath):
        d = self.sync_daemon_tool.get_public_files()
        d.addCallback(lambda r: get_public_files(r, filePath, self.delegate))
        return None


## CALLBACK FUNCTIONS ##


def volume_list(folders, delegate):
    volumes = NSMutableArray.alloc().init()
    volumes.addObject_(NSString.alloc().initWithString_(os.path.expanduser('~/Ubuntu One')))
    volumes.addObject_(NSString.alloc().initWithString_(os.path.expanduser('/Users/jose/Library/Application Support/ubuntuone')))
    
    for folder in folders:
        if (bool(folder['subscribed'])):
            volumes.addObject_(NSString.alloc().initWithString_(folder['path']))

    delegate.returnedVolumeList_(volumes)

def get_uploads(uploads, delegate):
    returnUploads = NSMutableArray.alloc().initWithCapacity_(len(uploads))
    for upload in uploads:
        returnUploads.addObject_(NSString.alloc().initWithString_(upload['path']))
    delegate.returnedUploads_(returnUploads)

def get_downloads(downloads, delegate):
    returnDownloads = NSMutableArray.alloc().initWithCapacity_(len(downloads))
    for download in downloads:
        returnDownloads.addObject_(NSString.alloc().initWithString_(download['path']))
    delegate.returnedDownloads_(returnDownloads)

def file_is_public(public_files, path, delegate):
    for public_file in public_files:
        if public_file['path'] == path:
            delegate.returnedFileVisibillity_(True)
            return None
    delegate.returnedFileVisibillity_(False)


def get_public_files(public_files, path, delegate):
    for public_file in public_files:
        if public_file['path'] == path:
            delegate.returnedPublicLink_(NSString.alloc().initWithString_(public_file['public_url']))
            return None
    delegate.returnedPublicLink_(None)
