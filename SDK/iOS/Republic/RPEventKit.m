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

#import "RPEventKit.h"

@interface RPEventKit () {
    UIViewController *_viewController;
}

@end


@implementation RPEventKit

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        _viewController = viewController;
    }
    
    return self;
}

- (void)addEvent:(NSDictionary *)eventDictionary {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    if ([eventDictionary objectForKey:@"startDate"]) {
        event.startDate = [self parseDateFromString:[eventDictionary objectForKey:@"startDate"]];
    }
    
    if ([eventDictionary objectForKey:@"endDate"]) {
        event.endDate = [self parseDateFromString:[eventDictionary objectForKey:@"endDate"]];
    }
    
    if ([eventDictionary objectForKey:@"allDay"]) {
        event.allDay = [self parseBooleanFromString:[eventDictionary objectForKey:@"allDay"]];
    }
    
    if ([eventDictionary objectForKey:@"title"]) {
        event.title = [eventDictionary objectForKey:@"title"];
    }
    
    if ([eventDictionary objectForKey:@"location"]) {
        event.location = [eventDictionary objectForKey:@"location"];
    }
    
    if ([eventDictionary objectForKey:@"notes"]) {
        event.notes = [eventDictionary objectForKey:@"notes"];
    }
    
    if ([eventDictionary objectForKey:@"url"]) {
        event.URL = [self parseUrlFromString:[eventDictionary objectForKey:@"url"]];
    }
    
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    eventEditViewController.event = event;
    eventEditViewController.eventStore = eventStore;
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.view.accessibilityLabel = @"rpScheduleOnCalendarView";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_viewController presentViewController:eventEditViewController animated:YES completion:nil];
    });
}

- (NSDate *)parseDateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSRange rangeOfDot = [string rangeOfString:@"."];
    string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString *actualString = string;
    
    if (rangeOfDot.location != NSNotFound) {
        actualString = [string substringToIndex:rangeOfDot.location];
    }
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:actualString];
    
    return date;
}

- (BOOL)parseBooleanFromString:(NSString *)string {
    return [string boolValue];;
}

- (NSURL *)parseUrlFromString:(NSString *)string {
    return [NSURL URLWithString:string];
}


#pragma mark EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(action == EKEventEditViewActionSaved) {
        [self.delegate eventKit:self didFinishAddingEvent:YES];
    } else {
        [self.delegate eventKit:self didFinishAddingEvent:NO];
    }
}

@end
