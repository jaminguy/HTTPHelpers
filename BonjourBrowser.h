//
//  BonjourBrowser.h
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

#import <Foundation/Foundation.h>

@interface BonjourBrowser : NSObject

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *serviceType;

- (void)startBrowsing;

@end

@protocol BonjourBrowserDelegate <NSObject>

- (void)bonjourBrowser:(BonjourBrowser *)sender foundServiceWithURL:(NSString *)serviceURL;
- (void)bonjourBrowser:(BonjourBrowser *)sender didNotResolve:(NSDictionary *)errorDictionary;

@end
