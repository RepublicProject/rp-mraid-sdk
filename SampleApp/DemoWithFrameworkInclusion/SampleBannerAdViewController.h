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

#import <Republic/Republic.h>

@interface SampleBannerAdViewController : UIViewController <RPAdViewControllerDelegate>

@property (nonatomic, strong) RPAdViewController *rpAdViewController;

-(void) resize:(CGRect)rect;
- (id)initWithAdName;



@end
