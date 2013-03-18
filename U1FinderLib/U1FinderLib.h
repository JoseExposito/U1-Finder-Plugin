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

@protocol U1FinderLibDelegate <NSObject>

    - (void)returnedVolumeList:(NSArray *)volumes;
    - (void)returnedUploads:(NSArray *)uploads;
    - (void)returnedDownloads:(NSArray *)downloads;
    - (void)returnedFileVisibillity:(BOOL)isPublic;
    - (void)returnedPublicLink:(NSString *)publicLink;

@end

/*!
 Objective-C interface to execute the FinderLib bundle Python code.
 DO NOT USE THIS CLASS. Use U1FinderLibAdaptor instead.
 */
@interface U1FinderLib : NSObject

    - (id)initWithDelegate:(id<U1FinderLibDelegate>)delegate;
    - (void)volumeList;
    - (void)currentUploads;
    - (void)currentDownloads;
    - (void)isFilePublic:(NSString *)filePath;
    - (void)changeFile:(NSString *)filePath visibillity:(BOOL)isPublic;
    - (void)getPublicLinkOfFile:(NSString *)filePath;

@end
