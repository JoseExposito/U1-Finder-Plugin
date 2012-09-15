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
@class U1Volumes;

@protocol U1VolumesDelegate <NSObject>

    /*!
     If the volumes request success returns an array with the paths of the volumes.
     */
    - (void)volumesRequest:(U1Volumes *)sender didFinishWithVolumeList:(NSArray *)volumes;

    /*!
     If the volumes request fails returns an error.
     */
    - (void)volumesRequest:(U1Volumes *)sender didFailWithError:(NSError *)error;

@end

/*!
 Class that allow to get the list of the volumes. The volumes are the folder synchronized with Ubuntu One.
 */
@interface U1Volumes : NSObject

    /*!
     Returns in the delegate a list of with the volumes. For implementation details check:
     https://one.ubuntu.com/developer/files/store_files/cloud#get--api-file_storage-v1-volumes
     */
    - (void)getVolumesReceivingTheResultInTheDelegate:(id<U1VolumesDelegate>)delegate;

@end
