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
#import "U1IconOverlayHook.h"
#import "U1Resources.h"
#import "U1IconOverlayUtils.h"

#import "TNodeIconAndNameCell.h"
#import "PFDesktopServicesPriv.h"
#import "PFDisckImages.h"
#import "FINode-FINodeAdditions.h"
#import "TIconViewCell.h"
#import "TDesktopIcon.h"

@implementation NSObject (U1IconOverlayHook)

- (void)U1IconOverlayHook_TIconViewCell_drawImage:(id)arg1
{
    // Get the path of the file
    TIconViewCell *realSelf = (TIconViewCell *)self;
    FINode *node = (FINode *)[realSelf representedItem];
    NSString *filePath = node.previewItemURL.path;
    
    IKImageWrapper *returnImage = arg1;
    
    if ([[U1IconOverlayUtils sharedInstance] mustDrawIconOverlayOverFileAtPath:filePath]) {        
        // Get the icon overlay
        NSImage *iconOverlay = [[NSImage alloc] initWithContentsOfFile:[U1Resources getPathForResourceNamed:@"u1-synced-emblem.icns"]];
        
        // Get the real icon
        IKImageWrapper *imageWrapper = (IKImageWrapper *)arg1;
        NSImage *icon = [imageWrapper nsImage];
        
        // Draw the icon overlay over the real icon
        [icon lockFocus];
        [iconOverlay drawInRect:NSMakeRect(0, 0, icon.size.width/2, icon.size.height/2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        [icon unlockFocus];
        
        // Return the composed icon
        returnImage = [[IKImageWrapper alloc] initWithNSImage:icon];
    }
    
    [self U1IconOverlayHook_TIconViewCell_drawImage:returnImage];
}

- (void)U1IconOverlayHook_TListViewIconAndTextCell_drawIconWithFrame:(struct CGRect)arg1
{
    [self U1IconOverlayHook_TListViewIconAndTextCell_drawIconWithFrame:arg1];
    
    // Get the path of the file
    TNodeIconAndNameCell *nodeIconAndNameCell = (TNodeIconAndNameCell *)self;
    FINode *node = (FINode *)[FINode nodeFromNodeRef:nodeIconAndNameCell.node->fNodeRef];
    NSString *filePath = node.previewItemURL.path;
    
    // Draw the icon overlay if necessary
    if ([[U1IconOverlayUtils sharedInstance] mustDrawIconOverlayOverFileAtPath:filePath]) {
        NSImage *iconOverlay = [[NSImage alloc] initWithContentsOfFile:[U1Resources getPathForResourceNamed:@"u1-synced-emblem.icns"]];
        [iconOverlay drawInRect:NSMakeRect(arg1.origin.x, arg1.origin.y+arg1.size.height/4, 3*arg1.size.height/4, 3*arg1.size.height/4) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    }
}

@end
