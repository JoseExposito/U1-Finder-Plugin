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
#import "U1Volumes.h"
#import "U1AccountManager.h"

static NSString *U1_VOLUMES_URL  = @"https://one.ubuntu.com/api/file_storage/v1/volumes";

@interface U1Volumes ()

    /*!
     The delegate that will receive the list of volumes.
     */
    @property (nonatomic, strong) id<U1VolumesDelegate> delegate;

@end

@implementation U1Volumes

- (void)getVolumesReceivingTheResultInTheDelegate:(id<U1VolumesDelegate>)delegate
{
    self.delegate = delegate;
    
    U1AccountManager *accountManager = [U1AccountManager sharedInstance];
    OAConsumer *consumer = accountManager.oauthConsumer;
    OAToken    *token    = accountManager.oauthToken;
	
	id<OASignatureProviding> signatureProvider = [[OAPlaintextSignatureProvider alloc] init];
	OAMutableURLRequest *oauthRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:U1_VOLUMES_URL] consumer:consumer token:token realm:nil signatureProvider:signatureProvider];
	[oauthRequest setHTTPMethod:@"GET"];
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:oauthRequest delegate:self didFinishSelector:@selector(volumesRequestWithTicket:didFinishWithData:) didFailSelector:@selector(volumesRequestWithTicket:didFailWithError:)];
}

- (void)volumesRequestWithTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    if (ticket.didSucceed) {
        NSArray *responseBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *volumeList = [[NSMutableArray alloc] initWithCapacity:responseBody.count];

        for (NSDictionary *volumeInfo in responseBody) {
            NSString *volumePath = [(NSString *)[volumeInfo objectForKey:@"path"] stringByStandardizingPath];
            [volumeList addObject:volumePath];
        }
        
        // Add the "Shared With Me" folder
        [volumeList addObject:[@"~/Library/Application Support/ubuntuone/shares" stringByStandardizingPath]];
        
        [self.delegate volumesRequest:self didFinishWithVolumeList:volumeList];
        
    } else {
        [self.delegate volumesRequest:self didFailWithError:nil];
    }
}

- (void)volumesRequestWithTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    [self.delegate volumesRequest:self didFailWithError:error];
}

@end
