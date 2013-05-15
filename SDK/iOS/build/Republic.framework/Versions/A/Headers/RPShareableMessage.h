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


@interface RPShareableMessage : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *shortMessage;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *appId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end