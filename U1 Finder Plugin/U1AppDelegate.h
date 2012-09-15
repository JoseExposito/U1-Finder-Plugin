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
#import "U1Login.h"
#import "U1Volumes.h"

/*!
 U1 Main only has an static method, that have dificult load the data required by the U1 Finder Plugin.
 This class is like the "AppDelegate" U1 Finder Plugin.
 */
@interface U1AppDelegate : NSObject <U1LoginDelegate, U1VolumesDelegate>

    /*!
     Tries to login Ubuntu One, gets the volume list and hooks the Finder to show an icon overlay and personalize the context menu.
     */
    - (void)start;

@end
