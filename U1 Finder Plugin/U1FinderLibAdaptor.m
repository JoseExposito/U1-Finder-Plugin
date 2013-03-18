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

/*!
 Time, in seconds, to chache the U1FinderLib information.
 */
const int SYNCHRONIZED_FOLDERS_CHECK_TIME = 10;
const int SYNCHRONIZATION_CHECK_TIME = 3;

@interface U1FinderLibAdaptor ()

    /*!
     Instance of the Python library.
     */
    @property (nonatomic, strong) U1FinderLib *finderLib;

    /*!
     List of files that are in upload/download process.
     */
    @property (nonatomic, strong) NSArray *uploads;
    @property (nonatomic, strong) NSArray *downloads;
    @property (nonatomic) NSTimeInterval lastUploadsAndDownloadsCheck;

    /*!
     List of synchronized folders.
     */
    @property (nonatomic, strong) NSArray *synchronizedFoldersList;
    @property (nonatomic) NSTimeInterval lastSynchronizedFoldersCheck;

@end

@implementation U1FinderLibAdaptor

+ (U1FinderLibAdaptor *)sharedInstance
{
    static U1FinderLibAdaptor *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[U1FinderLibAdaptor alloc] init];
	});
    
	return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    // Load the Python bundle
    NSBundle *pluginBundle = [NSBundle bundleWithPath:@"/Library/ScriptingAdditions/U1 Finder Injector.osax/Contents/Resources/U1FinderLib.bundle"];
    Class finderLibClass = [pluginBundle classNamed:@"U1FinderLib"];
    self.finderLib = [[finderLibClass alloc] initWithDelegate:self];
    
    // Get the synchronized volumes
    [self.finderLib volumeList];
    
    // Get the list of uploads/downloads
    [self.finderLib currentUploads];
    [self.finderLib currentDownloads];
    
    return self;
}

#pragma mark syncronizedFolders


- (NSArray *)syncronizedFolders
{
    NSTimeInterval currentTimestamp = [[[NSDate alloc] init] timeIntervalSince1970];
    if (currentTimestamp - self.lastSynchronizedFoldersCheck - SYNCHRONIZED_FOLDERS_CHECK_TIME > 0) {
        [self.finderLib volumeList];
    }
    
    return self.synchronizedFoldersList;
}

- (void)returnedVolumeList:(NSArray *)volumes
{    
    self.synchronizedFoldersList = volumes;
    self.lastSynchronizedFoldersCheck = [[[NSDate alloc] init] timeIntervalSince1970];
}


#pragma mark fileIsSynchronizing


- (BOOL)fileIsSynchronizing:(NSString *)filePath
{
    if (filePath == nil)
        return NO;
    
    NSTimeInterval currentTimestamp = [[[NSDate alloc] init] timeIntervalSince1970];
    if (currentTimestamp - self.lastUploadsAndDownloadsCheck - SYNCHRONIZATION_CHECK_TIME > 0) {
        [self.finderLib currentUploads];
        [self.finderLib currentDownloads];
    }
    
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && isDir) {
        // If the file is a folder, mark it as synchronizing if their content is synchronizing
        for (NSString *path in self.uploads) {
            if ([path rangeOfString:filePath].location != NSNotFound)
                return YES;
        }
        
        for (NSString *path in self.downloads) {
            if ([path rangeOfString:filePath].location != NSNotFound)
                return YES;
        }
        
        return NO;
        
    } else {
        return [self.uploads containsObject:filePath] || [self.downloads containsObject:filePath];
    }
}

- (void)returnedUploads:(NSArray *)uploads
{
    self.uploads = uploads;
    self.lastUploadsAndDownloadsCheck = [[[NSDate alloc] init] timeIntervalSince1970];
}

- (void)returnedDownloads:(NSArray *)downloads
{
    self.downloads = downloads;
    self.lastUploadsAndDownloadsCheck = [[[NSDate alloc] init] timeIntervalSince1970];
}


#pragma mark Synchronize folder / stop synchronizing folder


- (void)synchronizeFolderAtPath:(NSString *)folderPath
{
    [self.finderLib synchronizeFolderAtPath:folderPath];
}
- (void)folderSynchronizedOk
{
    NSLog(@"Folder synchronized");
    [self.finderLib volumeList];
}

- (void)stopSinchronizingFolderAtPath:(NSString *)folderPath
{
    [self.finderLib unsuscribeFolderAtPath:folderPath];
}
- (void)folderUnsuscribedOk
{
    NSLog(@"Folder unsuscribed");
    [self.finderLib volumeList];
}


#pragma mark Actions with file visibillity


BOOL returnedFileVisibillity;
- (BOOL)isFilePublic:(NSString *)filePath
{
    [self.finderLib isFilePublic:filePath];
    CFRunLoopRun();
    return returnedFileVisibillity;
}
- (void)returnedFileVisibillity:(BOOL)isPublic
{
    returnedFileVisibillity = isPublic;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)changeFile:(NSString *)filePath visibillity:(BOOL)isPublic;
{
    [self.finderLib changeFile:filePath visibillity:isPublic];
}

- (void)copyToTheClipboardThePublicLinkOfFileAtPath:(NSString *)filePath
{
    [self.finderLib getPublicLinkOfFile:filePath];
}

- (void)returnedPublicLink:(NSString *)publicLink
{
    NSLog(@"Link copied to the clipboard: %@", publicLink);
    if (publicLink != nil) {
        [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
        [[NSPasteboard generalPasteboard] setString:publicLink forType: NSStringPboardType];
    }
}

@end
