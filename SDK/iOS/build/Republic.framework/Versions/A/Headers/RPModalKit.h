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


@protocol RPModalKitDelegate;

/**
 Class to show a video in modal mode
 */
@interface RPModalKit : NSObject

@property (nonatomic, assign) id<RPModalKitDelegate> delegate;
@property (nonatomic, strong) NSString *currentId;

/**
 Inits the class with a view controller
 @param viewController View controller where to present the iOS video view controller
 @return The newly initialized modal kit
 */
- (id)initWithViewController:(UIViewController *)viewController;

/**
 Shows the video player and plays the specified URL
 @param videoUrl URL with the video to play
 */
- (void)showVideoPlayer:(NSDictionary *)urlDictionary;

@end


@protocol RPModalKitDelegate <NSObject>

- (void)modalKit:(RPModalKit *)modalKit didFinishShowingVideoPlayer:(BOOL)success;

@end