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

#import "RPOrientationProperties.h"

@implementation RPOrientationProperties

- (id)initWithDictionary:(NSDictionary *)properties {
    self = [super init];
    if (self) {
        self.allowOrientationChange = [[properties objectForKey:@"allowOrientationChange"] boolValue];
        
        self.forceOrientation = RPOrientationPropertiesForceOrientationNone;
        NSString *forceOrientation = [properties objectForKey:@"forceOrientation"];
        if ([forceOrientation isEqualToString:@"portrait"]) {
            self.forceOrientation = RPOrientationPropertiesForceOrientationPortrait;
        } else if ([forceOrientation isEqualToString:@"landscape"]) {
            self.forceOrientation = RPOrientationPropertiesForceOrientationLandscape;
        }
    }
    return self;
}

- (NSString *)description {
    NSString *allowOrientationChange = self.allowOrientationChange ? @"true" : @"false";
    NSString *forceOrientation = @"none";
    
    if (self.forceOrientation == RPOrientationPropertiesForceOrientationLandscape) {
        forceOrientation = @"landscape";
    } else if (self.forceOrientation == RPOrientationPropertiesForceOrientationPortrait) {
        forceOrientation = @"portrait";
    }
    
    return [NSString stringWithFormat:@"allowOrientationChange: %@, forceOrientation: %@", allowOrientationChange, forceOrientation];
}

- (UIInterfaceOrientation)forcedOrientation {
    if (self.forceOrientation == RPOrientationPropertiesForceOrientationLandscape) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if (self.forceOrientation == RPOrientationPropertiesForceOrientationPortrait) {
        return UIInterfaceOrientationPortrait;
    }
    
    return nil;
}

@end
