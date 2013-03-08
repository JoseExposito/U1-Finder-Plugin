/*
 * Ubuntu One Finder Plugin
 * Copyright (C) 2012 - José Expósito <jose.exposito89@gmail.com>
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
#import "U1FinderLibAdaptor.h"

NSArray *returnedVolumeList;

@interface U1FinderLibAdaptor ()
    @property (nonatomic, strong) U1FinderLib *finderLib;
@end

@implementation U1FinderLibAdaptor

+ (U1FinderLibAdaptor *)sharedInstance
{
    static U1FinderLibAdaptor *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[U1FinderLibAdaptor alloc] init];
        
        // Load the Python bundle
        NSBundle *pluginBundle = [NSBundle bundleWithPath:@"/Library/ScriptingAdditions/U1 Finder Injector.osax/Contents/Resources/U1FinderLib.bundle"];
        Class finderLibClass = [pluginBundle classNamed:@"U1FinderLib"];
        sharedInstance.finderLib = [[finderLibClass alloc] initWithDelegate:sharedInstance];
	});
    
	return sharedInstance;
}

- (NSArray *)volumeList
{
    [self.finderLib volumeList];
    CFRunLoopRun();
    return returnedVolumeList;
}

- (void)returnedVolumeList:(NSArray *)volumes
{
    returnedVolumeList = volumes;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
