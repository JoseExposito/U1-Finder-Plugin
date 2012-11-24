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
# Objective-C facade to the methods of the FinderLib.
class FinderLib(NSObject):
    
    ##
    # Default constructor.
    def init(self):
        self = super(FinderLib, self).init()
        self.sync_daemon_tool = SyncDaemonTool(None)
        return self
    
    ##
    # Returns the list of the shared volumes. Example output:
    #
    # { type:"volumeList" volumes: {
    #    { volume:"/Users/jose/Ubuntu One" subscribed:"YES" },
    #    { volume:"/Users/jose/Pictures" subscribed:"NO" }
    # } }
    @objc.typedSelector('@@:')
    def volumeList(self):
        reactor.callWhenRunning(run_command, volume_list, self.sync_daemon_tool)
        reactor.run()
        return returned_value[0]



##
# Auxiliar function to call to the sync daemon.
@defer.inlineCallbacks
def run_command(callback, sync_daemon_tool):
    running = yield is_already_running()
    
    try:
        if not running:
            returned_value[0] = '{ type:"error" reason:"Sync Daemon is not running" }'
        else:
            d = sync_daemon_tool.get_folders()
            returned_value[0] = yield d.addCallback(lambda r: callback(r))

    except Exception, e:
        returned_value[0] = '{ type:"error" reason:"Exception: %s" }' % e

    finally:
        if reactor.running:
            reactor.stop()

if __name__ == '__main__':
    py = FinderLib.alloc().init()
    print py.volumeList()
