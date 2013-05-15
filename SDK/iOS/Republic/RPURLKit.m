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
#import "RPURLKit.h"

@implementation RPURLKit

- (void)openURL:(NSDictionary *)urlDictionary {
    NSURL *url;

    if ([urlDictionary objectForKey:@"url"]) {
        url = [NSURL URLWithString:[urlDictionary objectForKey:@"url"]];
    }

    BOOL safariCalled = [[UIApplication sharedApplication] openURL:url];

    [self.delegate urlKit:self didFinishOpeningURL:safariCalled];
}

- (void)storePicture:(NSDictionary *)urlDictionary {
    _url = nil;
    
    if ([urlDictionary objectForKey:@"url"]) {
        _url = [NSURL URLWithString:urlDictionary[@"url"]];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The ad wishes to store a picture in your device's photo album. Allow storing?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
        UIImage *image;
        if (_url) {
            NSData *imageData = [NSData dataWithContentsOfURL:_url];
            image = [UIImage imageWithData:imageData];
        }
        
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, self.delegate, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)(self));
        } else {
            [self.delegate urlKit:self didFinishStoringPicture:false];
        }
	}
}


@end