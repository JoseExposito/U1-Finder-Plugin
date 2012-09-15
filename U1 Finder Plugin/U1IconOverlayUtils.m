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
#import "U1IconOverlayUtils.h"

@implementation U1IconOverlayUtils
@synthesize volumesToSynchronize = _volumesToSynchronize;

+ (U1IconOverlayUtils *)sharedInstance;
{
	static U1IconOverlayUtils *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[U1IconOverlayUtils alloc] init];
	});
    
	return sharedInstance;
}

- (BOOL)mustDrawIconOverlayOverFileAtPath:(NSString *)filePath
{
    // We only draw the Ubuntu One icon overlay if the selected file/folder is into one of the
    // volumes to synchronize or is the volume it self
    
    if (filePath == nil)
        return NO;
    
    for (NSString *volume in self.volumesToSynchronize) {
        if ([filePath rangeOfString:volume].location != NSNotFound) {
            return YES;
        }
    }
            
    return NO;
}

@end
