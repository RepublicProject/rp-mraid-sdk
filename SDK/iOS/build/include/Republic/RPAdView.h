//
// Copyright 2012 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//
#import <UIKit/UIKit.h>

@protocol RPAdViewDelegate;

@interface RPAdView : UIView <UIWebViewDelegate>

/**
 Class to represent the view set to the advertisment view controller to load the advertisment web page
 */
@property (nonatomic, strong) id<RPAdViewDelegate> delegate;
@property (nonatomic, assign) id target;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic) CGRect defaultPosition;

/**
 Shows a web view with the specified URL
 @param url URL with the web page to show
 */
- (void)loadUrl:(NSURL *)url;


/**
 Updates the current state in mraid.js
 */
- (void)updateMraid;

@end


/**
 Protocol to represent the delegate methods of the advertisment view
 */
@protocol RPAdViewDelegate <NSObject>

/**
 Indicates that the view finish loading its content inside the web view
 @param adView Advertisment view that finish loading
 */
- (void)adViewDidFinishLoad:(RPAdView *)adView;

- (void)adView:(RPAdView *)adView didStopLoadWithError:(NSError *)error;

@end