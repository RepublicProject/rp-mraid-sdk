//
// Copyright 2013 Republic Project
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//


#import "RPFacebookDialogViewController.h"

@implementation RPFacebookDialogViewController {
    UIWebView *_webView;
}

- (id)initWithUrl:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.url = url;
    }
    
    return self;
}

- (void)loadView {
    _webView = [[UIWebView alloc] init];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.accessibilityLabel = @"rpShareToFacebookView";
    [_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    self.view = _webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *host = request.URL.host;
    if ([self.redirectUrl hasSuffix:host]) {
        [self.delegate facebookDialogViewController:self didFinishFacebookWithCode:0];
        
        return NO;
    }
    
    return YES;
}


@end
