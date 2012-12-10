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
from   twisted.internet import reactor, defer
from   ubuntuone.platform.tools import (SyncDaemonTool, is_already_running)
from   FinderLibCallbacks import *
NSObject = objc.lookUpClass('NSObject')

##
# Variable to get the result of the calls to the Sync Daemon.
# The result is a JSON string stored in returned_value[0].
returned_value = ['']

##
# Objective-C facade to the methods of the U1FinderLib.
class U1FinderLib(NSObject):
    
    ##
    # Default constructor.
    def init(self):
        self = super(U1FinderLib, self).init()
        self.sync_daemon_tool = SyncDaemonTool(None)
        return self
    
    ##
    # Returns the list of the shared volumes. Example output:
    #
    # { type:"volume_list" volumes: {
    #    { volume:"/Users/jose/Ubuntu One" subscribed:"YES" },
    #    { volume:"/Users/jose/Pictures" subscribed:"NO" }
    # } }
    @objc.typedSelector('@@:')
    def volumeList(self):
        reactor.callWhenRunning(run_command, "volume_list", [], self.sync_daemon_tool)
        reactor.run()
        return returned_value[0]

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





##
# Auxiliar functions to call to the sync daemon.
@defer.inlineCallbacks
def run_command(action, params, sync_daemon_tool):
    running = yield is_already_running()
    
    try:
        if not running:
            returned_value[0] = '{ type:"error" reason:"Sync Daemon is not running" }'
        else:
            yield run_action(action, params, sync_daemon_tool)

    except Exception, e:
        returned_value[0] = '{ type:"error" reason:"Exception: %s" }' % e

    finally:
        if reactor.running:
            reactor.stop()

@defer.inlineCallbacks
def run_action(action, params, sync_daemon_tool):
    
    if action == "volume_list":
        d = sync_daemon_tool.get_folders()
        returned_value[0] = yield d.addCallback(lambda r: volume_list(r))

    elif action == "file_is_synchronizing":
        # Check if the file is in the uploads
        d = sync_daemon_tool.get_current_uploads()
        uploads = yield d.addCallback(lambda r: get_uploads(r))        
        if params[0] in uploads:
            returned_value[0] = '{ type:"file_is_synchronizing" path:"' + params[0] + '" synchronizing:"YES" }'
            return
        
        # Check if the file is in the downloads
        d = sync_daemon_tool.get_current_downloads()
        downloads = yield d.addCallback(lambda r: get_downloads(r))
        if params[0] in downloads:
            returned_value[0] = '{ type:"file_is_synchronizing" path:"' + params[0] + '" synchronizing:"YES" }'
            return

        # If the file is not in the downloads or in the uploads it is because it is synchronized
        returned_value[0] = '{ type:"file_is_synchronizing" path:"' + params[0] + '" synchronizing:"NO" }'

    elif action == "make_file_public":
        d = sync_daemon_tool.change_public_access(params[0], params[1])
        returned_value[0] = yield d.addCallback(lambda r: change_public_access(r, params[0]))

    elif action == "get_public_link":
        d = sync_daemon_tool.get_public_files()
        returned_value[0] = yield d.addCallback(lambda r: get_public_files(r, params[0]))


if __name__ == '__main__':
    py = U1FinderLib.alloc().init()
    print py.volumeList()
    #print py.fileIsSynchronizing_("/Users/jose/Ubuntu One/a.mp4")
    #print py.makeFile_public_("/Users/jose/Ubuntu One/Examen.pdf", True)
    #print py.getPublicLinkOfFile_("/Users/jose/Ubuntu One/Examen.pdf")
