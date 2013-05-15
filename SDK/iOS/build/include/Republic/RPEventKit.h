//
// Copyright 2012 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@protocol RPEventKitDelegate;

/**
 Class to open the default calendar to add events
 */
@interface RPEventKit : NSObject <EKEventEditViewDelegate>

@property (nonatomic, assign) id<RPEventKitDelegate> delegate;
@property (nonatomic, strong) NSString *currentId;

/**
 Inits the class with a view controller
 @param viewController View controller where to present the iOS event view controller
 @return The newly initialized event kit
 */
- (id)initWithViewController:(UIViewController *)viewController;

/**
 Opens a popup allowing the user to add events to the calendar, using the dictionary to prepopulate the event
 */
- (void)addEvent:(NSDictionary *)eventDictionary;

@end


@protocol RPEventKitDelegate <NSObject>

- (void)eventKit:(RPEventKit *)eventKit didFinishAddingEvent:(BOOL)success;

@end