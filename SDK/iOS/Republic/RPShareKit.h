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

#import "RPShareableMessage.h"
#import "RPFacebookDialogViewController.h"

@protocol RPShareKitDelegate;

@interface RPShareKit : NSObject <RPFacebookDialogViewControllerDelegate>

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) id<RPShareKitDelegate> delegate;
@property (nonatomic, strong) NSString *currentId;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)shareOnFacebookWithMessage:(RPShareableMessage *)shareableMessage;
- (void)shareOnTwitterWithMessage:(RPShareableMessage *)shareableMessage;
- (void)shareOnDialogWithMessage:(RPShareableMessage *)shareableMessage;

@end

@protocol RPShareKitDelegate <NSObject>

- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithFacebook:(BOOL)success;
- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithTwitter:(BOOL)success;
- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithDialog:(BOOL)success;

@end
