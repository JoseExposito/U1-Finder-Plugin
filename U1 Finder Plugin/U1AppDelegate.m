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
#import "U1AppDelegate.h"
#import "U1AccountManager.h"
#import "U1Hook.h"
#import "U1IconOverlayHook.h"
#import "U1IconOverlayUtils.h"
#import "U1ContextMenuHook.h"

@interface U1AppDelegate ()

    @property (nonatomic, strong) U1Login *loginClass;
    @property (nonatomic, strong) U1Volumes *volumesClass;

@end

@implementation U1AppDelegate
@synthesize loginClass = _loginClass;

- (void)start
{
    U1AccountManager *accountManager = [U1AccountManager sharedInstance];
    
    // If the user hasn't got credential exit. This plugin must not be loaded without the correct credentials storeds in the keychain
    if (![accountManager hasCredentials]) {
        NSLog(@"Leaving from Ubuntu One Finder Plugin");
        return;
    }
    
    NSLog(@"Logging in Ubuntu One...");
    self.loginClass = [[U1Login alloc] init];
    [self.loginClass loginWithKeychainCredentialsReceivingTheResultInTheDelegate:self];
}

- (void)loginSuccess:(U1Login *)sender
{
    NSLog(@"Loged in Ubuntu One, asking for volumes...");
    self.volumesClass = [[U1Volumes alloc] init];
    [self.volumesClass getVolumesReceivingTheResultInTheDelegate:self];
}

- (void)volumesRequest:(U1Volumes *)sender didFinishWithVolumeList:(NSArray *)volumes
{
    NSLog(@"Volume list obtained: %@", volumes);
    
    self.loginClass   = nil;
    self.volumesClass = nil;
    
    // Store the volume list in the U1IconOverlayUtils class
    [U1IconOverlayUtils sharedInstance].volumesToSynchronize = volumes;
    

    NSLog(@"Hooking Finder to show icon overlay and personalize the context menu");
    
    // Icon overlay
    [U1Hook hookMethod:@selector(drawImage:) inClass:@"TIconViewCell" toCallToTheNewMethod:@selector(U1IconOverlayHook_TIconViewCell_drawImage:)]; // Lion & Mountain Lion
    [U1Hook hookMethod:@selector(drawIconWithFrame:) inClass:@"TListViewIconAndTextCell" toCallToTheNewMethod:@selector(U1IconOverlayHook_TListViewIconAndTextCell_drawIconWithFrame:)]; // Lion & Mountain Lion
    
    // Context menu
    [U1Hook hookClassMethod:@selector(addViewSpecificStuffToMenu:browserViewController:context:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_addViewSpecificStuffToMenu:browserViewController:context:)]; // Lion & Mountain Lion

    [U1Hook hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_handleContextMenuCommon:nodes:event:view:windowController:addPlugIns:)]; // Lion
    [U1Hook hookMethod:@selector(configureWithNodes:windowController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_configureWithNodes:windowController:container:)]; // Lion
    
    [U1Hook hookClassMethod:@selector(handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_handleContextMenuCommon:nodes:event:view:browserController:addPlugIns:)]; // Mountain Lion
    [U1Hook hookMethod:@selector(configureWithNodes:browserController:container:) inClass:@"TContextMenu" toCallToTheNewMethod:@selector(U1ContextMenuHook_TContextMenu_configureWithNodes:browserController:container:)]; // Mountain Lion
    
}


#pragma mark Callback errors


- (void)loginError:(U1Login *)sender
{
    NSLog(@"Error in the login process");
    NSLog(@"Leaving from Ubuntu One Finder Plugin");
}

- (void)volumesRequest:(U1Volumes *)sender didFailWithError:(NSError *)error
{
    NSLog(@"Error getting the volumes");
    NSLog(@"Leaving from Ubuntu One Finder Plugin");
}


@end
