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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

enum {
    RPOrientationPropertiesForceOrientationPortrait,
    RPOrientationPropertiesForceOrientationLandscape,
    RPOrientationPropertiesForceOrientationNone
};
typedef NSUInteger RPOrientationPropertiesForceOrientation;

@interface RPOrientationProperties : NSObject

@property (nonatomic) RPOrientationPropertiesForceOrientation forceOrientation;
@property (nonatomic) BOOL allowOrientationChange;

- (id)initWithDictionary:(NSDictionary *)properties;
- (UIInterfaceOrientation)forcedOrientation;

@end
