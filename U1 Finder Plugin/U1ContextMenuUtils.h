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
@class TContextMenu;
struct TFENodeVector;

@interface U1ContextMenuUtils : NSObject

    /*!
     Returns the single instance of the class.
     */
    + (U1ContextMenuUtils *)sharedInstance;

    /*!
     Auxiliar array to know the path of the selected items in the Icons/Desktop views.
     */
    @property (nonatomic, strong) NSMutableArray /*NSString*/ *menuItems;

    /*!
     Creates an array of paths with the specified TFENodeVector vector.
     */
    - (NSArray /*NSString*/ *)pathsForNodes:(const struct TFENodeVector *)nodes;

    /*!
     Adds the Ubuntu One options to the menu for the specified selected files.
     */
    - (void)addU1OptionsInMenu:(TContextMenu *)menu forPaths:(NSArray /*NSString*/ *)selectedItems;

@end
