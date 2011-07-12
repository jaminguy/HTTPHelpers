/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  PRPConnection.h
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

#import <UIKit/UIKit.h>

@class PRPConnection;

typedef void (^PRPConnectionProgressBlock)(PRPConnection *connection);
typedef void (^PRPConnectionCompletionBlock)(PRPConnection *connection, 
                                             NSError *error);



@interface PRPConnection : NSObject {}

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURLRequest *urlRequest;
@property (nonatomic, assign, readonly) NSInteger httpResponseCode;
@property (nonatomic, assign, readonly) NSInteger contentLength;
@property (nonatomic, retain, readonly) NSMutableData *downloadData;
@property (nonatomic, assign, readonly) float percentComplete;
@property (nonatomic, assign) NSUInteger progressThreshold;


+ (id)connectionWithURL:(NSURL *)requestURL
          progressBlock:(PRPConnectionProgressBlock)progress
        completionBlock:(PRPConnectionCompletionBlock)completion;

+ (id)connectionWithRequest:(NSURLRequest *)request
              progressBlock:(PRPConnectionProgressBlock)progress
            completionBlock:(PRPConnectionCompletionBlock)completion;

- (id)initWithURL:(NSURL *)requestURL
    progressBlock:(PRPConnectionProgressBlock)progress
  completionBlock:(PRPConnectionCompletionBlock)completion;

- (id)initWithRequest:(NSURLRequest *)request
        progressBlock:(PRPConnectionProgressBlock)progress
      completionBlock:(PRPConnectionCompletionBlock)completion;

- (void)start;
- (void)stop;

@end