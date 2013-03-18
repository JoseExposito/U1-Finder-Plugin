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
#import "U1ContextMenuUtils.h"
#import "U1Resources.h"
#import "CDStructures.h"
#import "TContextMenu.h"
#import "FINode-FINodeAdditions.h"
#import "U1FinderLibAdaptor.h"

// { Not class-dump: Reversing
#import <vector>

typedef struct {
    struct OpaqueNodeRef* fNodeRef;
    struct OpaqueNodeRef* fNodeRef2;
    struct OpaqueNodeRef* fNodeRef3;
    struct OpaqueNodeRef* fNodeRef4;
} TFENode4;

/*typedef struct {
 void* something;
 } TGroupedNodes;*/

class TFENodeVector  : public std::vector<TFENode>  { };
class TFENode4Vector : public std::vector<TFENode4> { };
// }


@interface U1ContextMenuUtils ()

    /*!
     Returns the index where put the Ubuntu One menu depending of the selected items.
     */
    - (NSInteger)menuIndexForPaths:(NSArray /*NSString*/ *)selectedItems;

    /*!
     Auxiliar property to know what is the selected file in the menu callbacks.
     */
    @property (nonatomic, strong) NSString *menuSelectedFile;

@end


@implementation U1ContextMenuUtils
@synthesize menuItems = _menuItems;

+ (U1ContextMenuUtils *)sharedInstance
{
    static U1ContextMenuUtils *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[U1ContextMenuUtils alloc] init];
	});
    
	return sharedInstance;
}

- (NSArray /*NSString*/ *)pathsForNodes:(const struct TFENodeVector *)nodes
{
    NSMutableArray *selectedItems = [NSMutableArray arrayWithCapacity:nodes->size()];
    for (int n=0; n<nodes->size(); n++) {
        FINode *node = (FINode *)[FINode nodeFromNodeRef:nodes->at(n).fNodeRef];
        NSString *filePath = node.previewItemURL.path;
        [selectedItems insertObject:filePath atIndex:n];
    }
    
    return selectedItems;
}

- (void)addU1OptionsInMenu:(TContextMenu *)menu forPaths:(NSArray /*NSString*/ *)selectedItems
{
    // Add the Ubuntu One menu
    NSInteger separatorIndex = [self menuIndexForPaths:selectedItems];
    NSInteger menuIndex = separatorIndex + 1;
    
    [menu insertItem:[NSMenuItem separatorItem] atIndex:separatorIndex];
    NSMenuItem *mainMenu = [menu insertItemWithTitle:@"Ubuntu One" action:nil keyEquivalent:@"U1" atIndex:menuIndex];
    NSMenu *submenu = [[NSMenu alloc] init];
    [mainMenu setSubmenu:submenu];
    
    // Not show options if more than one file is selected
    if (selectedItems == nil || selectedItems.count == 0 || selectedItems.count > 1) {
        [mainMenu setEnabled:NO];
        return;
    }
    
    U1FinderLibAdaptor *finderLib = [U1FinderLibAdaptor sharedInstance];
    self.menuSelectedFile = [selectedItems objectAtIndex:0];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.menuSelectedFile isDirectory:&isDirectory]) {
        [mainMenu setEnabled:NO];
        return;
    }
    
    BOOL fileIsSynchronized = NO;
    NSArray *volumes = [finderLib syncronizedFolders];
    for (NSString *volume in volumes) {
        if ([self.menuSelectedFile hasPrefix:volume])
            fileIsSynchronized = YES;
    }
    
    if (isDirectory) {
        // No options if the selected directory is not in the user home or is into a synchronized folder
        if ([self.menuSelectedFile isEqualToString:NSHomeDirectory()] || [self.menuSelectedFile hasPrefix:[NSHomeDirectory() stringByAppendingPathComponent:@"Ubuntu One"]]|| ![self.menuSelectedFile hasPrefix:NSHomeDirectory()]) {
            [mainMenu setEnabled:NO];
        
        // If the selected directory is synchronized allow to stop synchronizing it
        } else if ([[finderLib syncronizedFolders] containsObject:self.menuSelectedFile]) {
            [[submenu addItemWithTitle:U1LocalizedString(@"Stop synchronizing this folder") action:@selector(u1StopSynchronizeMenuClicked:) keyEquivalent:@"U1-Stop-Synchronize"] setTarget:self];
            
        // If is not synchronized allow to synchronize it if it is not into a synchronized volume
        } else {
            if (fileIsSynchronized) {
                [mainMenu setEnabled:NO];
            } else {
                [[submenu addItemWithTitle:U1LocalizedString(@"Synchronise this folder") action:@selector(u1SynchronizeMenuClicked:) keyEquivalent:@"U1-Synchronize"] setTarget:self];
            }
        }
        
    } else {
        // If the file is not into a synchronized folder dissable the menu
        if (!fileIsSynchronized) {
            [mainMenu setEnabled:NO];
            
        } else {
            if ([finderLib isFilePublic:self.menuSelectedFile]) {
                [[submenu addItemWithTitle:U1LocalizedString(@"Stop publish") action:@selector(u1StopPublishMenuClicked:) keyEquivalent:@"U1-Stop-Publish-File"] setTarget:self];
                [[submenu addItemWithTitle:U1LocalizedString(@"Copy web link") action:@selector(u1LinkMenuClicked:) keyEquivalent:@"U1-Link"] setTarget:self];
            } else {
                [[submenu addItemWithTitle:U1LocalizedString(@"Publish") action:@selector(u1PublishMenuClicked:) keyEquivalent:@"U1-Publish-File"] setTarget:self];
            }
        }
        
    }
}


#pragma mark Ubuntu One menu callbacks


- (void)u1SynchronizeMenuClicked:(id)param
{
    NSLog(@"SYNCHRONIZE MENU CLICKED");
    [[U1FinderLibAdaptor sharedInstance] synchronizeFolderAtPath:self.menuSelectedFile];
}

- (void)u1StopSynchronizeMenuClicked:(id)param
{
    NSLog(@"STOP SYNCHRONIZE MENU CLICKED");
    [[U1FinderLibAdaptor sharedInstance] stopSinchronizingFolderAtPath:self.menuSelectedFile];
}

- (void)u1PublishMenuClicked:(id)param
{
    NSLog(@"PUBLISH MENU CLICKED");
    [[U1FinderLibAdaptor sharedInstance] changeFile:self.menuSelectedFile visibillity:YES];
}

- (void)u1StopPublishMenuClicked:(id)param
{
    NSLog(@"STOP PUBLISH MENU CLICKED");
    [[U1FinderLibAdaptor sharedInstance] changeFile:self.menuSelectedFile visibillity:NO];
}

- (void)u1LinkMenuClicked:(id)param
{
    NSLog(@"LINK MENU CLICKED");
    [[U1FinderLibAdaptor sharedInstance] copyToTheClipboardThePublicLinkOfFileAtPath:self.menuSelectedFile];
}


#pragma mark Private Methods


- (NSInteger)menuIndexForPaths:(NSArray /*NSString*/ *)selectedItems
{
    NSInteger menuIndex;
    
    if (selectedItems.count > 1) {
        // The menu must be showed in different index if the selection contains files or only folders
        BOOL containsFiles = NO;
        for (NSString *path in selectedItems) {
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
            
            if (!isDirectory) {
                containsFiles = YES;
                break;
            }
        }
        
        menuIndex = containsFiles ? 5 : 2;
        
    } else {
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:[selectedItems objectAtIndex:0] isDirectory:&isDirectory];
        
        if (isDirectory && ![[NSWorkspace sharedWorkspace] isFilePackageAtPath:[selectedItems objectAtIndex:0]])
            menuIndex = 2;
        else
            menuIndex = 3;
    }
    
    return menuIndex;
}

@end
