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

#import "RPWebViewDelegate.h" 

#define OBJC_METHOD_PREFIX @"objc"
#define PARAM_DELIMITER @"&"
#define METHOD_NAME_BEGINING @":%20"
#define SELECTOR_PARAMETER_DELIMITER @":"

@implementation RPWebViewDelegate

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *lastUrlPart = request.URL.relativeString;
    if ([lastUrlPart hasPrefix:OBJC_METHOD_PREFIX]) {
        [self callMethodRequestedByString:lastUrlPart onWebView:webView];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Javascript handling methods

- (void)callMethodRequestedByString:(NSString *)methodRequest onWebView:(UIWebView *)requestingWebView {
    NSString *methodName = [self methodNameFromRequest:methodRequest];
    NSLog(@"found method with name: %@", methodName);
    SEL methodSelector = NSSelectorFromString(methodName);
    
    
    NSString *methodParameter = [self methodParameterForRequest:methodRequest];
    
    if (methodParameter) {
        methodName = [methodName stringByAppendingString:SELECTOR_PARAMETER_DELIMITER];
        methodSelector = NSSelectorFromString(methodName);

        if ([_target respondsToSelector:methodSelector]) {
            [_target performSelector:methodSelector withObject:methodParameter];
        }
    } else {
        if ([_target respondsToSelector:methodSelector]) {
            [_target performSelector:methodSelector];
        }
    }
}

- (NSString *)methodNameFromRequest:(NSString *)methodRequest {
    NSRange startNameRange = [methodRequest rangeOfString:METHOD_NAME_BEGINING];
    NSRange endNameRange = [methodRequest rangeOfString:PARAM_DELIMITER];
    
    NSInteger methodNameLocation = startNameRange.location + startNameRange.length;
    NSRange nameRange;
    if (endNameRange.location != NSNotFound) {
        nameRange = NSMakeRange(methodNameLocation, endNameRange.location - methodNameLocation);
    } else {
        nameRange = NSMakeRange(methodNameLocation, methodRequest.length - methodNameLocation);
    }
    
    NSString *methodName = [methodRequest substringWithRange:nameRange];
    
    return methodName;
}

- (NSString *)methodParameterForRequest:(NSString *)methodRequest {
    NSRange parameterBeginingRange = [methodRequest rangeOfString:PARAM_DELIMITER];
    
    if (parameterBeginingRange.location != NSNotFound) {
        NSString *methodParameter = [methodRequest substringFromIndex:(parameterBeginingRange.location + 1)];
        return [methodParameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

@end
