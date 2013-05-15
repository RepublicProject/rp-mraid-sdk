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

#import <MediaPlayer/MediaPlayer.h>
#import "RPModalKit.h"

@interface RPModalKit () {
    MPMoviePlayerViewController *_moviePlayerViewController;
    UIViewController *_viewController;
}

@end


@implementation RPModalKit

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        _viewController = viewController;
    }

    return self;
}

- (void)showVideoPlayer:(NSDictionary *)urlDictionary {
    NSURL *url;
    
    if ([urlDictionary objectForKey:@"url"]) {
        url = [NSURL URLWithString:[urlDictionary objectForKey:@"url"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEnd:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    _moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    _moviePlayerViewController.view.accessibilityLabel = @"rpVideoPlayerView";
    [_viewController presentMoviePlayerViewControllerAnimated:_moviePlayerViewController];
}


#pragma mark - Notification handling methods

- (void)movieDidEnd:(NSNotification *)notification {
    if ([[notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackError) {
       [self.delegate modalKit:self didFinishShowingVideoPlayer:NO];
    } else {
       [self.delegate modalKit:self didFinishShowingVideoPlayer:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end