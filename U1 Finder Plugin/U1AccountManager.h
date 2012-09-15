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
#import "OAuthConsumer.h"

/*!
 Allows to check if the user has their credentials storeds in the OS X keychain and allows to use it to login or send messages to the U1 server.
 */
@interface U1AccountManager : NSObject

    /*!
     Returns the single instance of the class.
     */
    + (U1AccountManager *)sharedInstance;

    /*!
     Reloads the autentication data reading it from the keyhain.
     */
    - (void)reloadDataFromKeychain;

    /*!
     Indicates if the user has correct credentials storeds in their keychain.
     */
    - (BOOL)hasCredentials;

    /*!
     OAuth data.
     */
    @property (nonatomic, strong) OAConsumer *oauthConsumer;
    @property (nonatomic, strong) OAToken *oauthToken;

@end
