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
#import "U1Main.h"
#import "U1Hook.h"
#import "U1IconOverlayHook.h"
#import "U1IconOverlayUtils.h"
#import "U1ContextMenuHook.h"
#import "U1Resources.h"
#import "U1FinderLibAdaptor.h"

@implementation U1Main

+ (void)load
{
    NSLog(@"########### U1 FINDER PLUGIN LOADED ###########");
    
    U1FinderLibAdaptor *finderLib = [U1FinderLibAdaptor sharedInstance];
    NSArray *volumes = [finderLib volumeList];
    
    NSLog(@"Volume list obtained: %@", volumes);
    
    // Store the volume list in the U1IconOverlayUtils class
    [U1IconOverlayUtils sharedInstance].volumesToSynchronize = volumes;
    
    // Set the U1 folder icon to the ~/Ubuntu One volume
    NSImage *folderImage = [[NSImage alloc] initWithContentsOfFile:[U1Resources getPathForResourceNamed:@"u1-folder.icns"]];
    [[NSWorkspace sharedWorkspace] setIcon:folderImage forFile:[@"~/Ubuntu One" stringByStandardizingPath] options:0];
    
    NSLog(@"Hooking Finder to show icon overlay and personalize the context menu");
    
    // Icon overlay
    [U1Hook hookMethod:@selector(drawImage:) inClass:@"TIconViewCell" toCallToTheNewMethod:@selector(U1IconOverlayHook_TIconViewCell_drawImage:)]; // Lion & Mountain Lion
    [U1Hook hookMethod:@selector(drawIconWithFrame:) inClass:@"TListViewIconAndTextCell" toCallToTheNewMethod:@selector(U1IconOverlayHook_TListViewIconAndTextCell_drawIconWithFrame:)]; // Lion & Mountain Lion
    
    // Context menu
    [U1Hook hookClassMethod:@selector(addViewSpecificStuffToMenu:browserViewController:context:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:browserViewController:context:)]; // Lion & Mountain Lion
    
    [U1Hook hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:)]; // Lion
    [U1Hook hookMethod:@selector(configureWithNodes:windowController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_configureWithNodes:windowController:container:)]; // Lion
    
    [U1Hook hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:)]; // Mountain Lion
    [U1Hook hookMethod:@selector(configureWithNodes:browserController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_configureWithNodes:browserController:container:)]; // Mountain Lion
}

@end
