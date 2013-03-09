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
#import "U1FinderLib.h"

/*!
 Class that provides synchronous and singleton access to the U1FinderLib bundle.
 */
@interface U1FinderLibAdaptor : NSObject <U1FinderLibDelegate>

    /*!
     Returns the single instance of the class.
     */
    + (U1FinderLibAdaptor *)sharedInstance;

    /*!
     Returns the list of syncroniced folders.
     */
    - (NSArray *)syncronizedFolders;

    /*!
     Indicates if the specified file is in synchronization process.
     */
    - (BOOL)fileIsSynchronizing:(NSString *)filePath;

@end
