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

NSArray *returnedVolumeList = nil;

NSArray *returnedUploads   = nil;
NSArray *returnedDownloads = nil;
NSTimeInterval lastSynchronizationCheck = 0;
const int SYNCHRONIZATION_CHECK_TIME = 3;

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


#pragma mark syncronizedFolders


- (NSArray *)syncronizedFolders
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


#pragma mark fileIsSynchronizing


- (BOOL)fileIsSynchronizing:(NSString *)filePath
{
    if (filePath == nil)
        return NO;
    
    NSTimeInterval currentTimestamp = [[[NSDate alloc] init] timeIntervalSince1970];
    if (currentTimestamp - lastSynchronizationCheck - SYNCHRONIZATION_CHECK_TIME > 0) {
        returnedUploads = nil;
        returnedDownloads = nil;
        
        [self.finderLib currentUploads];
        [self.finderLib currentDownloads];
        
        CFRunLoopRun();
        
        lastSynchronizationCheck = currentTimestamp;
    }
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && isDir) {
        // If the file is a folder, mark it as synchronizing if their content is synchronizing
        for (NSString *path in returnedUploads) {
            if ([path rangeOfString:filePath].location != NSNotFound)
                return YES;
        }
        
        for (NSString *path in returnedDownloads) {
            if ([path rangeOfString:filePath].location != NSNotFound)
                return YES;
        }
        
        return NO;
        
    } else {
        return [returnedUploads containsObject:filePath] || [returnedDownloads containsObject:filePath];
    }
}

- (void)returnedUploads:(NSArray *)uploads
{
    @synchronized(self) {        
        returnedUploads = uploads;
        if (returnedDownloads != nil)
            CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

- (void)returnedDownloads:(NSArray *)downloads
{
    @synchronized(self) {        
        returnedDownloads = downloads;
        if (returnedUploads != nil)
            CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

@end
