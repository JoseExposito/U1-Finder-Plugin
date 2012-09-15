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
#import <Cocoa/Cocoa.h>

@interface U1Hook : NSObject

    /*!
     Hooks the specified method making it call to the new method. Example: [U1Hook hookMethod:@selector(drawImage:) inClass:@"TIconViewCell" toCallToTheNewMethod:@selector(U1IconOverlayHook_TIconViewCell_drawImage:)];
     IMPORTANT: Use [U1PHook hookClassMethod:inClass:toCallToTheNewMethod:] if you want to hook a class method (static method).
     @param oldSelector The selector to hook.
     @param className   The name of the class that contains the method to hook.
     @param newSelector The selector that will be called when the hooked program calls the hooked selector.
     */
    + (void)hookMethod:(SEL)oldSelector inClass:(NSString *)className toCallToTheNewMethod:(SEL)newSelector;

    /*!
     Like [U1PHook hookMethod:inClass:toCallToTheNewMethod:] but with class methods (static methods).
     @see [U1PHook hookMethod:inClass:toCallToTheNewMethod:]
     */
    + (void)hookClassMethod:(SEL)oldSelector inClass:(NSString *)className toCallToTheNewMethod:(SEL)newSelector;

@end
