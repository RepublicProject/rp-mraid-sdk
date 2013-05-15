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

#import <UIKit/UIKit.h>
#import <Republic/Republic.h>
#import "SampleBannerAdViewController.h"

@interface MainViewController : UIViewController  <RPAdViewControllerDelegate>

@property (nonatomic, strong) SampleBannerAdViewController *bannerController;
@property (nonatomic, strong) RPAdViewController *rpAdViewController;
@property (nonatomic, strong) UIViewController *currentAdController;

- (IBAction)loadSampleInterstitial:(UIButton *)sender;
- (IBAction)loadSampleTwoPartBanner:(UIButton *)sender;
- (IBAction)loadSampleBanner:(UIButton *)sender;
- (IBAction)loadSampleResizeBanner:(UIButton *)sender;
- (IBAction)requestCalendarAccess:(UIButton *)sender;

@end
