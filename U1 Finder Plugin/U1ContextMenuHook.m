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
#import "U1ContextMenuHookML.h"
#import "U1ContextMenuUtils.h"
#import "CDStructures.h"
#import "FINode-FINodeAdditions.h"
#import "TContextMenu.h"

@implementation NSObject (U1ContextMenuHookML)

+ (void)U1ContextMenuHook_TContextMenu_handleContextMenuCommon:(unsigned int)arg1 nodes:(const struct TFENodeVector *)arg2 event:(id)arg3 view:(id)arg4 browserController:(id)arg5 addPlugIns:(BOOL)arg6
{
    // Save the list of selected files to use it in [self U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:browserViewController:context:]
    U1ContextMenuUtils *contexMenuUtils = [U1ContextMenuUtils sharedInstance];
    contexMenuUtils.menuItems = (NSMutableArray *)[contexMenuUtils pathsForNodes:arg2];
    
    [self U1ContextMenuHook_TContextMenu_handleContextMenuCommon:arg1 nodes:arg2 event:arg3 view:arg4 browserController:arg5 addPlugIns:arg6];
}

+ (void)U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:(id)arg1 browserViewController:(id)arg2 context:(unsigned int)arg3
{
    [self U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:arg1 browserViewController:arg2 context:arg3];
    
    // Add the U1 menu options
    if ([U1ContextMenuUtils sharedInstance].menuItems.count > 0) {
        U1ContextMenuUtils *contexMenuUtils = [U1ContextMenuUtils sharedInstance];
        [contexMenuUtils addU1OptionsInMenu:arg1 forPaths:contexMenuUtils.menuItems];
        [contexMenuUtils.menuItems removeAllObjects];
    }
}

- (void)U1ContextMenuHook_TContextMenu_configureWithNodes:(const struct TFENodeVector *)arg1 browserController:(id)arg2 container:(BOOL)arg3
{    
    [self U1ContextMenuHook_TContextMenu_configureWithNodes:arg1 browserController:arg2 container:arg3];
    
    TContextMenu *realSelf = (TContextMenu *)self;
    U1ContextMenuUtils *contexMenuUtils = [U1ContextMenuUtils sharedInstance];
    
    NSArray *selectedItems = [contexMenuUtils pathsForNodes:arg1];
    [contexMenuUtils addU1OptionsInMenu:realSelf forPaths:selectedItems];
}

@end
