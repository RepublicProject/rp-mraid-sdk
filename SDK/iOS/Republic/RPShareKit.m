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

#import "RPShareKit.h"
#import <Twitter/Twitter.h>
#define BASE_FACEBOOK_URL @"https://www.facebook.com/dialog/feed?"
#define APP_ID_KEY @"app_id=%@&"
#define PICTURE_KEY @"picture=%@&"
#define DESCRIPTION_KEY @"description=%@&"
#define LINK_KEY @"link=%@&"
#define REDIRECT_KEY @"redirect_uri=%@"
#define REDIRECT_URL @"http://127.0.0.1"

@implementation RPShareKit

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];

    if (self) {
        self.viewController = viewController;
    }

    return self;
}

- (void)shareOnFacebookWithMessage:(RPShareableMessage *)shareableMessage {
    if ([self isBellowiOS6]) {
        NSMutableString *dialogUrl = [[NSMutableString alloc] initWithString:BASE_FACEBOOK_URL];

        if (shareableMessage.appId) {
            [dialogUrl appendFormat:APP_ID_KEY, shareableMessage.appId];
        }

        if (shareableMessage.message) {
            [dialogUrl appendFormat:DESCRIPTION_KEY, shareableMessage.message];
        }

        if (shareableMessage.url) {
            [dialogUrl appendFormat:LINK_KEY, shareableMessage.url];
        }

        if (shareableMessage.imageUrl) {
            [dialogUrl appendFormat:PICTURE_KEY, shareableMessage.imageUrl];
        }

        [dialogUrl appendFormat:REDIRECT_KEY, REDIRECT_URL];

        NSURL *url = [NSURL URLWithString:[dialogUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        RPFacebookDialogViewController *urlViewController = [[RPFacebookDialogViewController alloc] initWithUrl:url];
        urlViewController.redirectUrl = REDIRECT_URL;
        urlViewController.delegate = self;
        [self.viewController presentViewController:urlViewController animated:YES completion:nil];
    } else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

            if (shareableMessage.message) {
                [slComposeViewController setInitialText:shareableMessage.message];
            }

            if (shareableMessage.image) {
                [slComposeViewController addImage:shareableMessage.image];
            }

            if (shareableMessage.url) {
                [slComposeViewController addURL:[NSURL URLWithString:shareableMessage.url]];
            }

            [slComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
                    switch (result) {
                        case SLComposeViewControllerResultCancelled:
                            [self.delegate shareKit:self didFinishSharingWithFacebook:NO];
                            break;

                        case SLComposeViewControllerResultDone:
                            [self.delegate shareKit:self didFinishSharingWithFacebook:YES];
                            break;
                            default:
                            break;
                    }
                }];

            [self.viewController presentViewController:slComposeViewController animated:YES completion:nil];
        } else {
            [self.delegate shareKit:self didFinishSharingWithFacebook:NO];
        }
    }
}

- (void)shareOnTwitterWithMessage:(RPShareableMessage *)shareableMessage {
    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *twTweetComposeViewController = [[TWTweetComposeViewController alloc] init];

        if (shareableMessage.shortMessage) {
            [twTweetComposeViewController setInitialText:shareableMessage.shortMessage];
        }

        if (shareableMessage.image) {
            [twTweetComposeViewController addImage:shareableMessage.image];
        }

        if (shareableMessage.url) {
            NSURL *url = [NSURL URLWithString:shareableMessage.url];
            [twTweetComposeViewController addURL:url];
        }

        [twTweetComposeViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                [self.viewController dismissModalViewControllerAnimated:YES];
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [self.delegate shareKit:self didFinishSharingWithTwitter:NO];
                        break;

                    case SLComposeViewControllerResultDone:
                        [self.delegate shareKit:self didFinishSharingWithTwitter:YES];
                        break;
                        default:
                        break;
                }
                ;
            }];

        [self.viewController presentViewController:twTweetComposeViewController animated:YES completion:nil];
    } else {
        [self.delegate shareKit:self didFinishSharingWithTwitter:NO];
    }
}

- (void)shareOnDialogWithMessage:(RPShareableMessage *)shareableMessage {
    if ([self isBellowiOS6]) {
        [self.delegate shareKit:self didFinishSharingWithDialog:NO];
    } else {
        NSArray *shareableMessageArray = @[shareableMessage.shortMessage, shareableMessage.image, shareableMessage.url];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareableMessageArray applicationActivities:nil];
        
        [activityController setCompletionHandler:^(NSString * activityType, BOOL completed) {
            if (completed) {
                [self.delegate shareKit:self didFinishSharingWithDialog:YES];
            } else {
                [self.delegate shareKit:self didFinishSharingWithDialog:NO];
            }
        }];
        
        [self.viewController presentViewController:activityController animated:YES completion:nil];    
    }
}

#pragma mark - iOS version method

- (BOOL)isBellowiOS6 {
    return [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending;
}

#pragma mark - FacebookDialogVieWControllerDelegate methods

- (void)facebookDialogViewController:(RPFacebookDialogViewController *)viewController didFinishFacebookWithCode:(NSInteger)resultCode {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    BOOL success = (resultCode == 0);

    if (self.delegate && [self.delegate respondsToSelector:@selector(shareKit:didFinishSharingWithFacebook:)]) {
        [self.delegate shareKit:self didFinishSharingWithFacebook:success];
    }
}

@end