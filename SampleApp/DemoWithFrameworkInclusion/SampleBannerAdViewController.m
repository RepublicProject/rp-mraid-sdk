//
// Copyright 2013 Republic Project.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "SampleBannerAdViewController.h"

@interface SampleBannerAdViewController()


@end

@implementation SampleBannerAdViewController


- (id)initWithAdName {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rpAdViewController = [[RPAdViewController alloc] initWithPlacementType:RPAdPlacementTypeInline forController:self];
    self.rpAdViewController.delegate = self;
    
    self.rpAdViewController.title = @"Banner Ad View";
    
    self.rpAdViewController.view.frame = CGRectMake(0, 0, 320, 50);
    
    [self.view addSubview:self.rpAdViewController.view];
    NSURL *url = [NSURL URLWithString:@"http://dev.republicproject.com/user/188/deploy/embed/mraid_banner.html"];
    
    [self.rpAdViewController loadAdFromUrl:url];
}

-(void) resize:(CGRect)rect {
    self.rpAdViewController.view.frame = CGRectMake(0,0, rect.size.width, 50);
}

#pragma mark RPAdViewControllerDelegate

- (void)adViewController:(RPAdViewController *)adViewController didLoadAdWithSize:(CGSize)adSize {
    NSLog(@"Width: %f  Height: %f", adSize.width, adSize.height);
}

- (void)adViewController:(RPAdViewController *)adViewController didLoadAdWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)adViewControllerDidOpenModal:(RPAdViewController *)adViewController {
    NSLog(@"Open Modal");
}

- (void)adViewControllerDidClose:(RPAdViewController *)adViewController {
    NSLog(@"Dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect newSize= CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        newSize = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
    }
    self.rpAdViewController.view.frame = CGRectMake(0,0, newSize.size.width,newSize.size.height);
}

@end
