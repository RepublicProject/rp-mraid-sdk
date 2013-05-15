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

@protocol RPURLViewControllerDelegate;


/**
 Class to represent a view controller to push an URL in a web view of the size of the screen
 */
@interface RPURLViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id<RPURLViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *currentId;


/**
 Push an URL in the web view inside the view controller
 */
- (void)pushURL:(NSDictionary *)urlDictionary;

@end


@protocol RPURLViewControllerDelegate <NSObject>

- (void)urlViewController:(RPURLViewController *)urlViewController didFinishPushingURL:(BOOL)success;

@end
