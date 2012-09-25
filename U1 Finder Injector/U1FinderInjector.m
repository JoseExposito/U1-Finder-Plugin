/*
 * Ubuntu One Finder Plugin
 * Copyright (C) 2012 - José Expósito <jose.exposito89@gmail.com>
 * Based on the Antonin Hildebrand TotalFinderInjector.m class:
 * https://github.com/binaryage/totalfinder-osax/blob/master/TotalFinderInjector.m
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
#import <Cocoa/Cocoa.h>
#import "U1Main.h"

// If the U1 Finder Plugin is already loaded or not
static bool alreadyLoaded = false;

OSErr handleLoadEvent(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
    NSLog(@"########### LOADING U1 FINDER PLUGIN ###########");
    
    if (alreadyLoaded) {
        NSLog(@"U1 Finder Plugin is already loaded");
        return noErr;
    }
    
    @try {
        // Get the Finder version [TODO Check that the Finder version is between 10.7 (Lion) and 10.8.1 (Mountain Lion)]
        NSString* finderVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSLog(@"Finder v%@", finderVersion); // TODO Check that the Finder version is between 10.7 (Lion) and 10.8.1 (Mountain Lion)
        
        // Get the U1 Finder Plugin bundle from resources and inject it
        NSBundle* u1InjectorBundle = [NSBundle bundleWithIdentifier:@"com.egg-software.U1-Finder-Injector"];
        NSString *u1PluginBundlePath = [u1InjectorBundle pathForResource:@"U1 Finder Plugin" ofType:@"bundle"];
        NSBundle *u1PluginBundle = [NSBundle bundleWithPath:u1PluginBundlePath];
        if (!u1PluginBundle) {
            NSLog(@"Unable to create bundle from path: %@ [%@]", u1PluginBundlePath, u1InjectorBundle);
            return noErr;
        }
        
        NSError* error;
        if (![u1PluginBundle loadAndReturnError:&error]) {
            NSLog(@"Unable to load bundle from path: %@ error: %@", u1PluginBundlePath, error.localizedDescription);
            return noErr;
        }
        
        alreadyLoaded = true;        
        return noErr;
        
    } @catch (NSException* exception) {
        NSLog(@"Failed to load U1 Finder Plugin with exception: %@", exception);
    }
    
    return noErr;
}
