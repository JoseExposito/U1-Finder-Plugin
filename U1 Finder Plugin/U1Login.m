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
#import "U1Login.h"
#import "U1AccountManager.h"


static NSString *U1_OAUTH_SSO_ME_URL      = @"https://login.ubuntu.com/api/1.0/accounts?ws.op=me";
static NSString *U1_OAUTH_SSO_TOKEN_URL   = @"https://one.ubuntu.com/oauth/sso-finished-so-get-tokens/%@";
static NSString *U1_LOGIN_PREFERRED_EMAIL = @"preferred_email";


@interface U1Login ()

    /*!
     OAuth data.
     */
    @property (nonatomic, strong) OAConsumer *oauthConsumer;
    @property (nonatomic, strong) OAToken *oauthToken;

    /*!
     The delegate that will receive the login status.
     */
    @property (nonatomic, strong) id<U1LoginDelegate> delegate;

@end


@implementation U1Login

- (void)loginWithKeychainCredentialsReceivingTheResultInTheDelegate:(id<U1LoginDelegate>)delegate
{
    U1AccountManager *accountManager = [U1AccountManager sharedInstance];
    self.oauthConsumer = accountManager.oauthConsumer;
    self.oauthToken    = accountManager.oauthToken;
    self.delegate      = delegate;
    
    OAPlaintextSignatureProvider *signatureProvider = [[OAPlaintextSignatureProvider alloc] init];
	OAMutableURLRequest *oauthRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:U1_OAUTH_SSO_ME_URL] consumer:self.oauthConsumer token:self.oauthToken realm:nil signatureProvider:signatureProvider];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:oauthRequest delegate:self didFinishSelector:@selector(loginStep1WithTicket:didFinishWithData:) didFailSelector:@selector(loginErrorWithTicket:andError:)];
}

- (void)loginStep1WithTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    if (ticket.didSucceed) {
        
        // The login action returns a JSON like
        //
        // {
        //    "username": "The name of the user",
        //    "preferred_email": "The email of the user",
        //    "displayname": "The real name of the user",
        //    "unverified_emails": "A list of unverified emails of the user or [] if it is empty",
        //    "verified_emails": "A list with other emails of the user or [] if it is empty",
        //    "openid_identifier": "Like the consumer_key stored in the keychain"
        // }
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        // Check that the preferred email is verified
        NSString *preferredEmail = [responseBody objectForKey:U1_LOGIN_PREFERRED_EMAIL];
        if (preferredEmail == nil && preferredEmail.length == 0) {
            [self.delegate loginError:self];
            return;
        }
        
        NSURL *u1TokenURL = [NSURL URLWithString:[NSString stringWithFormat:U1_OAUTH_SSO_TOKEN_URL, [preferredEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        OAPlaintextSignatureProvider *signatureProvider = [[OAPlaintextSignatureProvider alloc] init];
        OAMutableURLRequest *oauthRequest = [[OAMutableURLRequest alloc] initWithURL:u1TokenURL consumer:self.oauthConsumer token:self.oauthToken realm:nil signatureProvider:signatureProvider];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:oauthRequest delegate:self didFinishSelector:@selector(loginStep2WithTicket:didFinishWithData:) didFailSelector:@selector(loginErrorWithTicket:andError:)];
        
    } else {
        [self.delegate loginError:self];
    }
}

- (void)loginStep2WithTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    if (ticket.didSucceed)
        [self.delegate loginSuccess:self];
    else
        [self.delegate loginError:self];
}

- (void)loginErrorWithTicket:(OAServiceTicket *)ticket andError:(NSError *)error
{
    [self.delegate loginError:self];
}

@end
