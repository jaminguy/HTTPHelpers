/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  PRPConnection.m
//  SimpleDownload
//
//  Created by Matt Drance on 3/1/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//
//  Added to open source repository by Jamin Guy on 7/12/2011
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

#import "PRPConnection.h"
#import "UIApplication+PRPNetworkActivity.h"

@interface PRPConnection ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy)   NSURL *url;
@property (nonatomic, copy) NSURLRequest *urlRequest;
@property (nonatomic, assign) NSInteger httpResponseCode;
@property (nonatomic, retain) NSMutableData *downloadData;
@property (nonatomic, assign) NSInteger contentLength;

@property (nonatomic, assign) float previousMilestone;

@property (nonatomic, copy) PRPConnectionProgressBlock progressBlock;
@property (nonatomic, copy) PRPConnectionCompletionBlock completionBlock;

@end


@implementation PRPConnection

@synthesize url;
@synthesize urlRequest;
@synthesize httpResponseCode;
@synthesize connection;
@synthesize contentLength;
@synthesize downloadData;
@synthesize progressThreshold;
@synthesize previousMilestone;

@synthesize progressBlock;
@synthesize completionBlock;

- (void)dealloc {
    [url release], url = nil;
    [urlRequest release], urlRequest = nil;
    [connection cancel], [connection release], connection = nil;
    [downloadData release], downloadData = nil;
    [progressBlock release], progressBlock = nil;
    [completionBlock release], completionBlock = nil;
    
    [super dealloc];
}

+ (id)connectionWithRequest:(NSURLRequest *)request
              progressBlock:(PRPConnectionProgressBlock)progress
            completionBlock:(PRPConnectionCompletionBlock)completion {
    return [[[self alloc] initWithRequest:request
                            progressBlock:progress
                          completionBlock:completion]
            autorelease];
}

+ (id)connectionWithURL:(NSURL *)downloadURL
          progressBlock:(PRPConnectionProgressBlock)progress
        completionBlock:(PRPConnectionCompletionBlock)completion {
    return [[[self alloc] initWithURL:downloadURL
                        progressBlock:progress
                      completionBlock:completion] 
            autorelease];
}

- (id)initWithURL:(NSURL *)requestURL
    progressBlock:(PRPConnectionProgressBlock)progress
  completionBlock:(PRPConnectionCompletionBlock)completion {
    return [self initWithRequest:[NSURLRequest requestWithURL:requestURL]
                   progressBlock:progress
                 completionBlock:completion];
}

- (id)initWithRequest:(NSURLRequest *)request
        progressBlock:(PRPConnectionProgressBlock)progress 
      completionBlock:(PRPConnectionCompletionBlock)completion {
    if ((self = [super init])) {
        urlRequest = [request copy];
        progressBlock = [progress copy];
        completionBlock = [completion copy];
        url = [[request URL] copy];
        progressThreshold = 1.0;
    }
    return self;
}

#pragma mark -
#pragma mark 

- (void)start {
    [[UIApplication sharedApplication] prp_pushNetworkActivity];
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
}

- (void)stop {
    if (self.connection) {
        [[UIApplication sharedApplication] prp_popNetworkActivity];
    }
    
    [self.connection cancel];
    self.connection = nil;
    self.downloadData = nil;
    self.contentLength = 0;
    self.progressBlock = nil;
    self.completionBlock = nil;
}

- (float)percentComplete {
    if (self.contentLength <= 0) return 0;
    return (([self.downloadData length] * 1.0f) / self.contentLength) * 100;
}

#pragma mark 
#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.httpResponseCode = [httpResponse statusCode];
        if (self.httpResponseCode == 200) {
            NSDictionary *header = [httpResponse allHeaderFields];
            NSString *contentLen = [header valueForKey:@"Content-Length"];
            NSInteger length = self.contentLength = [contentLen integerValue];
            self.downloadData = [NSMutableData dataWithCapacity:length];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadData appendData:data];
    float pctComplete = floor([self percentComplete]);
    if ((pctComplete - self.previousMilestone) >= self.progressThreshold) {
        self.previousMilestone = pctComplete;
        if (self.progressBlock) self.progressBlock(self);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"Connection failed");
    if (self.completionBlock) self.completionBlock(self, error);
    self.connection = nil;
    [[UIApplication sharedApplication] prp_popNetworkActivity];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.completionBlock) self.completionBlock(self, nil);
    self.connection = nil;
    [[UIApplication sharedApplication] prp_popNetworkActivity];
}

@end