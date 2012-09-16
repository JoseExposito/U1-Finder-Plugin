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
#import "CDStructures.h"
#import "TContextMenu.h"
#import "FINode-FINodeAdditions.h"


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
    NSLog(@"Selected items: %@", selectedItems);

    // Add the Ubuntu One menu
    NSMenuItem *u1MainMenu = [menu insertItemWithTitle:@"Ubuntu One" action:nil keyEquivalent:@"U1" atIndex:3];

    // Create and add the Ubuntu One submenu
    NSMenu *submenu = [[NSMenu alloc] init];
    NSMenuItem *synchronizeItem = [submenu addItemWithTitle:NSLocalizedString(@"Stop Synchronizing This Folder", nil) action:@selector(u1SynchronizeMenuClicked:) keyEquivalent:@"U1-Synchronize"];
    NSMenuItem *publishItem = [submenu addItemWithTitle:NSLocalizedString(@"Publish", nil) action:@selector(u1PublishMenuClicked:) keyEquivalent:@"U1-Publish"];
    NSMenuItem *linkItem = [submenu addItemWithTitle:NSLocalizedString(@"Copy Web Link", nil) action:@selector(u1LinkMenuClicked:) keyEquivalent:@"U1-Link"];
    [u1MainMenu setSubmenu:submenu];
    
    // Enable or dissable the submenu options
    [synchronizeItem setEnabled:YES];
    [publishItem setEnabled:YES];
    [linkItem setEnabled:YES];
    [u1MainMenu setEnabled:YES];
}


#pragma mark Ubuntu One menu callbacks


- (void)u1SynchronizeMenuClicked:(id)param
{
    NSLog(@"SYNCHRONIZE MENU CLICKED");
}

- (void)u1PublishMenuClicked:(id)param
{
    NSLog(@"PUBLISH MENU CLICKED");
}

- (void)u1LinkMenuClicked:(id)param
{
    NSLog(@"LINK MENU CLICKED");
}

@end
