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

#define MESSAGE_KEY @"message"
#define SHORT_MESSAGE_KEY @"shortMessage"
#define IMAGE_URL_KEY @"imageUrl"
#define URL_KEY @"url"
#define APP_ID_KEY @"appId"

@implementation RPShareableMessage

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.message = [dictionary objectForKey:MESSAGE_KEY];
        self.shortMessage = [dictionary objectForKey:SHORT_MESSAGE_KEY];
        self.imageUrl = [dictionary objectForKey:IMAGE_URL_KEY];
        NSURL *url = [NSURL URLWithString:self.imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.image = [[UIImage alloc] initWithData:data];
        self.url = [dictionary objectForKey:URL_KEY];
        self.appId = [dictionary objectForKey:APP_ID_KEY];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message: %@\n shortMessage: %@, url: %@", self.message, self.shortMessage, self.url];
}

@end
