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
#import <Foundation/Foundation.h>
#import "PFImageKit.h"
struct TFENodeVector;

@interface NSObject (U1ContextMenuHook)

    /*!
     Modifies the context menu in icons and desktop view.
     */
    + (void)U1ContextMenuHook_TContextMenu_handleContextMenuCommon:(unsigned int)arg1 nodes:(const struct TFENodeVector *)arg2 event:(id)arg3 view:(id)arg4 windowController:(id)arg5 addPlugIns:(BOOL)arg6;  // Lion
    + (void)U1ContextMenuHook_TContextMenu_handleContextMenuCommon:(unsigned int)arg1 nodes:(const struct TFENodeVector *)arg2 event:(id)arg3 view:(id)arg4 browserController:(id)arg5 addPlugIns:(BOOL)arg6; // Mountain Lion

    + (void)U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:(id)arg1 browserViewController:(id)arg2 context:(unsigned int)arg3; // Lion & Mountain Lion

    /*!
     Modifies the context menu in list, columns and cover flow modes.
     */
    - (void)U1ContextMenuHook_TContextMenu_configureWithNodes:(const struct TFENodeVector *)arg1 windowController:(id)arg2 container:(BOOL)arg3;  // Lion
    - (void)U1ContextMenuHook_TContextMenu_configureWithNodes:(const struct TFENodeVector *)arg1 browserController:(id)arg2 container:(BOOL)arg3; // Mountain Lion

@end
