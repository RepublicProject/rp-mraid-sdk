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

@protocol RPURLKitDelegate;

/**
 Class to perform operations based on URL
 */
@interface RPURLKit : NSObject

@property (nonatomic, assign) id<RPURLKitDelegate> delegate;
@property (nonatomic, strong) NSString *currentId;
@property (nonatomic, strong) NSURL *url;

/**
 Open an URL on the the default external browser
 */
- (void)openURL:(NSDictionary *)urlDictionary;

/**
 Stores the picture in the camera roll
 */
- (void)storePicture:(NSDictionary *)urlDictionary;

@end


@protocol RPURLKitDelegate <NSObject>

- (void)urlKit:(RPURLKit *)urlKit didFinishOpeningURL:(BOOL)success;

- (void)urlKit:(RPURLKit *)urlKit didFinishStoringPicture:(BOOL)success;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end
