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

@interface U1IconOverlayUtils : NSObject

    /*!
     Returns the single instance of the class.
     */
    + (U1IconOverlayUtils *)sharedInstance;

    /*!
     List with the paths of the volumes to synchronize.
     */
    @property (nonatomic, strong) NSArray *volumesToSynchronize;

    /*!
     Indicates if is necessary draw an icon overlay over the specified file.
     @param filePath The path of the file to check.
     */
    - (BOOL)mustDrawIconOverlayOverFileAtPath:(NSString *)filePath;

@end
