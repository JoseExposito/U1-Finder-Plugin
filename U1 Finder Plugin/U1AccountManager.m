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
#import "U1AccountManager.h"
#import "SSKeychain.h"

static NSString *U1_KEYCHAIN_SERVICE_NAME = @"Ubuntu One";
static NSString *U1_KEYCHAIN_ACCOUNT_NAME = @"ubuntu_sso";

static NSString *U1_KEYCHAIN_CONSUMER_SECRET = @"consumer_secret";
static NSString *U1_KEYCHAIN_CONSUMER_KEY    = @"consumer_key";
static NSString *U1_KEYCHAIN_TOKEN_KEY       = @"token";
static NSString *U1_KEYCHAIN_TOKEN_SECRET    = @"token_secret";


@implementation U1AccountManager
@synthesize oauthConsumer = _oauthConsumer;
@synthesize oauthToken    = _oauthToken;

+ (U1AccountManager *)sharedInstance;
{
	static U1AccountManager *sharedInstance = nil;
	
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[U1AccountManager alloc] init];
        [sharedInstance reloadDataFromKeychain];
	});
    
	return sharedInstance;
}

- (void)reloadDataFromKeychain
{
    NSString *keychainJSON = [SSKeychain passwordForService:U1_KEYCHAIN_SERVICE_NAME account:U1_KEYCHAIN_ACCOUNT_NAME];
    
    if (keychainJSON == nil) {
        NSLog(@"The user doesn't allow the access to the keychain");
        return;
    }
    
    // The stored data in the keychain is a JSON like:
    //
    // {
    //    "consumer_secret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    //    "token": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    //    "consumer_key": "XXXXXXX",
    //    "name": "Ubuntu One @ Your computer name",
    //    "token_secret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    // }
    
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[keychainJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSString *consumerKey    = [jsonData objectForKey:U1_KEYCHAIN_CONSUMER_KEY];
    NSString *consumerSecret = [jsonData objectForKey:U1_KEYCHAIN_CONSUMER_SECRET];
    
    NSString *tokenKey       = [jsonData objectForKey:U1_KEYCHAIN_TOKEN_KEY];
    NSString *tokenSecret    = [jsonData objectForKey:U1_KEYCHAIN_TOKEN_SECRET];
    
    if (consumerKey == nil || consumerSecret == nil || tokenKey == nil || tokenSecret == nil) {
        NSLog(@"Invalid data stored in the keychain");
        return;
    }
    
    self.oauthConsumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret];
    self.oauthToken    = [[OAToken alloc] initWithKey:tokenKey secret:tokenSecret];
}

- (BOOL)hasCredentials
{
    return !(self.oauthConsumer == nil || self.oauthToken == nil);
}

@end
