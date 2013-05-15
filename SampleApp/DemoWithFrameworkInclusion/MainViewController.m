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

#import "MainViewController.h"
#import "SampleBannerAdViewController.h"

@implementation MainViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (IBAction)loadSampleBanner:(UIButton *)sender {
    self.bannerController = [[SampleBannerAdViewController alloc] initWithAdName];
    
    [self presentViewController:self.bannerController animated:YES completion:nil];
    self.currentAdController = self.bannerController;
}

- (IBAction)loadSampleResizeBanner:(UIButton *)sender {
    self.bannerController = [[SampleBannerAdViewController alloc] initWithAdName];
    
    [self presentViewController:self.bannerController animated:YES completion:nil];
    self.currentAdController = self.bannerController;
}

- (IBAction)requestCalendarAccess:(UIButton *)sender {
    [self requestCalendarAccess];
}

- (IBAction)loadSampleTwoPartBanner:(UIButton *)sender {
    self.bannerController = [[SampleBannerAdViewController alloc] initWithAdName];
    
    [self presentViewController:self.bannerController animated:YES completion:nil];
    self.currentAdController = self.bannerController;
}

- (IBAction)loadSampleInterstitial:(UIButton *)sender {
    
    self.rpAdViewController = [[RPAdViewController alloc] initWithPlacementType:RPAdPlacementTypeInterstitial forController:self];
    self.rpAdViewController.delegate = self;
    
    self.rpAdViewController.title = @"Interstitial Ad View";
    
    [self presentViewController:self.rpAdViewController animated:YES completion:nil];
    self.currentAdController = self.rpAdViewController;
    NSURL *url = [NSURL URLWithString:@"http://dev.republicproject.com/user/188/deploy/embed/mraid_responsive.html"];
    [self.rpAdViewController loadAdFromUrl:url];
    
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
}

- (void)orientationChanged:(NSDictionary *)param {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect newSize= CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        newSize = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
    }
    if(self.currentAdController == self.rpAdViewController) {
        self.rpAdViewController.view.frame = CGRectMake(0, 0, newSize.size.width, newSize.size.height);
        [self.rpAdViewController adjustResizedFrameToFit:newSize];
    } else if (self.currentAdController == self.bannerController) {
        [self.bannerController resize:newSize];
    }
}

- (void)requestCalendarAccess
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSString *alertMessage = @"";
    if (![self needToRequestAccessToCalendar:eventStore]) {
        // iOS 5
        alertMessage = @"You don't need to request calendar access because your device is prior to iOS 6.";
    } else {
        EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        
        switch (authorizationStatus) {
            case EKAuthorizationStatusNotDetermined:
                [self promptForCalendarAccess:eventStore];
                alertMessage = nil;
                break;
            case EKAuthorizationStatusRestricted:
                alertMessage = @"You cannot change authorization status for this device due some restrictions such as parental control.";
                break;
            case EKAuthorizationStatusDenied:
                alertMessage = @"Your access to the calendar is denied. You can change it on Settings > Privacy > Calendars";
                break;
            case EKAuthorizationStatusAuthorized:
                alertMessage = @"You already have access to the calendar.";
                break;
            default:
                break;
        }
    }
    
    if (alertMessage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)needToRequestAccessToCalendar:(EKEventStore *)eventStore {
    return [eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)];
}

- (void)promptForCalendarAccess:(EKEventStore *)eventStore {
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {

    }];
}

@end
