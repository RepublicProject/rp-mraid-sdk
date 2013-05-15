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

#import "RPAdView.h"
#import "RPShareKit.h"
#import "RPModalKit.h"
#import "RPURLKit.h"
#import "RPEventKit.h"
#import "RPOrientationProperties.h"
#import "RPURLViewController.h"


@protocol RPAdViewControllerDelegate;

enum {
    RPAdPlacementTypeInline,
    RPAdPlacementTypeInterstitial
};
typedef NSUInteger RPAdPlacementType;

/**
 Class to represent a view controller to load the advertisment web page
 */
@interface RPAdViewController : UIViewController <RPAdViewDelegate, RPShareKitDelegate, RPModalKitDelegate, RPEventKitDelegate, RPURLKitDelegate, RPURLViewControllerDelegate>


/**
 Delegate to notify the end of the load and size of the frame loaded
 */
@property (nonatomic, strong) id<RPAdViewControllerDelegate> delegate;

- (id)initWithPlacementType:(RPAdPlacementType)type forController:(UIViewController *)controller;

/**
 Starts loading the advertisment
 */
- (void)loadAdFromUrl:(NSURL *)url;

/**
 Allows us to resize the adview area to match our new frame (if we change its size, e.g.: on orientation change
 */
- (CGRect)adjustResizedFrameToFit:(CGRect)resizedFrame;
@end


/**
 Protocol to represent the delegate methods of the advertisment view controller
 */
@protocol RPAdViewControllerDelegate <NSObject>

/**
 Indicates the end of the load
 @param adViewController View controller that finish the load
 @param adSize width and length of the frame loaded
 */
- (void)adViewController:(RPAdViewController *)adViewController didLoadAdWithSize:(CGSize)adSize;

/**
 Indicates that an error occurred while loading the ad
 */
- (void)adViewController:(RPAdViewController *)adViewController didLoadAdWithError:(NSError *)error;

/**
 Indicates the view controller opened modally
 @param adViewController View controller that open modally
 */
- (void)adViewControllerDidOpenModal:(RPAdViewController *)adViewController;

- (void)adViewControllerDidClose:(RPAdViewController *)adViewController;

@end