//
//  BonjourBrowser.m
//  
//
//  Created by Jamin Guy on 11/10/11.
//  Copyright (c) 2011 Jamin Guy
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BonjourBrowser.h"

#import <Foundation/NSNetServices.h>
#include <arpa/inet.h>

#import "PRPConnection.h"

@interface BonjourBrowser () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, retain) NSMutableArray *services;

- (void)setupServiceBrowser;

@end

@implementation BonjourBrowser

@synthesize delegate;
@synthesize serviceBrowser;
@synthesize services;
@synthesize serviceType;

+ (BonjourBrowser *)sharedInstance {
    static BonjourBrowser *sharedID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedID = [[BonjourBrowser alloc] init];
    });
    return sharedID;
}

- (id)init {
    self = [super init];
    if(self) {
        services = [[NSMutableArray alloc] init];
        self.serviceType = @"_http._tcp";
    }
    return self;
}

- (void)setupServiceBrowser {
    self.serviceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:self.serviceType inDomain:@""];
}

- (void)startBrowsing {
    [self setupServiceBrowser];
}

#pragma NSNetServiceBrowserDelegate methods

// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
}

// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {   
}

// Sent when a service appears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    aNetService.delegate = self;
    [aNetService resolveWithTimeout:0.0];
    [services addObject:aNetService];    
}

// Sent when a service disappears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];    
}

#pragma NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSString *address = nil;
    uint16_t port;
    for(NSData *data in sender.addresses) {
        struct sockaddr_in* remoteAddress = (struct sockaddr_in*)CFDataGetBytePtr((CFDataRef)data);
        address = [NSString stringWithCString:inet_ntoa(remoteAddress->sin_addr) encoding:NSASCIIStringEncoding];
        if(![address isEqualToString:@"0.0.0.0"]) {
            port = htons(remoteAddress->sin_port);        
            NSString *url =[NSString stringWithFormat:@"http://%@:%d", address, port];
            if([self.delegate respondsToSelector:@selector(bonjourBrowser:foundServiceWithURL:)]) {
                [self.delegate bonjourBrowser:self foundServiceWithURL:url];
            }
        }
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve: %@", errorDict);
    if([self.delegate respondsToSelector:@selector(bonjourBrowser:didNotResolve:)]) {
        [self.delegate bonjourBrowser:self didNotResolve:errorDict];
    }
}

@end
