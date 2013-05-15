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

#import "RPAdView.h"
#import "RPWebViewDelegate.h"

#define RP_UPDATE_CURRENT_POSITION_METHOD_FORMAT @"RP.setCurrentPosition(%@)"
#define RP_UPDATE_DEFAULT_POSITION_METHOD_FORMAT @"RP.setDefaultPosition(%@)"
#define RP_FIRE_SIZE_CHANGE_EVENT_METHOD_FORMAT @"RP.onSizeChange(%@)"
#define RP_FIRE_VIEWABLE_CHANGE_EVENT_METHOD_FORMAT @"RP.onViewableChange(%@)"
#define MRAID_SCRIPT_REGEX @"(<script[^>]*src=\"mraid.js\"[^>]*>[^<]*</script>|<script.*src=\"mraid.js\".*/>)"
#define MRAID_SCRIPT_TAG @"<script type=\"application/javascript\">%@</script>"

#define SPINNER_SIZE 24

@interface RPAdView()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation RPAdView {
    RPWebViewDelegate *_webViewDelegate;
    BOOL _viewable;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.accessibilityLabel = @"rpAdView";
        _webView = [[UIWebView alloc] init];
        _webViewDelegate = [[RPWebViewDelegate alloc] init];
        _webViewDelegate.adView = self;
        _webView.delegate = self;
    }

    return self;
}

- (void)setTarget:(id)target {
    _webViewDelegate.target = target;
}

- (void)setDelegate:(id<RPAdViewDelegate>)delegate{
    _delegate = delegate;
}

- (void)updateMraid {
    [self updateCurrentPosition];
    [self updateDefaultPosition];
    [self fireSizeChangeEvent];
    [self checkViewableChangeEvent];
}

- (void)updateCurrentPosition {
    CGRect frame = self.frame;
    
    NSLog(@"Updating current position: %@", NSStringFromCGRect(frame));
    
    NSString *currentPositionObject = [NSString stringWithFormat:@"{\"x\": %f, \"y\": %f, \"width\": %f, \"height\": %f}",
                                       frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_UPDATE_CURRENT_POSITION_METHOD_FORMAT, currentPositionObject];
    [_webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

- (void)updateDefaultPosition {
    NSLog(@"Publishing default position: %@", NSStringFromCGRect(self.defaultPosition));
    
    NSString *defaultPositionObject = [NSString stringWithFormat:@"{\"x\": %f, \"y\": %f, \"width\": %f, \"height\": %f}",
                                       self.defaultPosition.origin.x, self.defaultPosition.origin.y, self.defaultPosition.size.width, self.defaultPosition.size.height];
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_UPDATE_DEFAULT_POSITION_METHOD_FORMAT, defaultPositionObject];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

- (void)fireSizeChangeEvent {
    CGSize size = self.frame.size;
    
    NSLog(@"Firing sizeChange: %@", NSStringFromCGSize(size));
    
    NSString *defaultPositionObject = [NSString stringWithFormat:@"{\"width\": %f, \"height\": %f}", size.width, size.height];
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_FIRE_SIZE_CHANGE_EVENT_METHOD_FORMAT, defaultPositionObject];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
    
}

- (void)checkViewableChangeEvent {
    CGRect currentPosition = self.frame;
    CGRect maxFrame = [self superview].bounds;
    
    BOOL viewableNow = !_webView.isLoading && !_webView.isHidden && CGRectContainsRect(maxFrame, currentPosition);
    
    [self fireViewableChangeEvent:viewableNow];
}

- (void)fireViewableChangeEvent:(BOOL)viewable {
    NSString *viewableString = viewable ? @"true" : @"false";
    NSLog(@"Firing viewableChange: %@", viewableString);
    
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_FIRE_VIEWABLE_CHANGE_EVENT_METHOD_FORMAT, viewableString];
    [self.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect webViewFrame = frame;
    webViewFrame.origin = CGPointZero;
    _webView.frame = webViewFrame;
    
    if (!CGRectIsEmpty(frame)) {
        
        if (CGRectIsEmpty(_defaultPosition)) {
            [self setDefaultPosition:frame];
        }
        
        [self updateMraid];
    }
}

- (NSString *)injectMraid:(NSString *)adHtml {
    NSString *mraid = [[NSBundle mainBundle] pathForResource:@"mraid" ofType:@"js" inDirectory:@"assets"];
    
    NSString *mraidCode = [NSString stringWithContentsOfFile:mraid encoding:NSUTF8StringEncoding error:nil];

    NSString *template = [NSString stringWithFormat:MRAID_SCRIPT_TAG, mraidCode];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MRAID_SCRIPT_REGEX options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *adHtmlWithMraid = [regex stringByReplacingMatchesInString:adHtml options:0 range:NSMakeRange(0, [adHtml length]) withTemplate:template];
    return adHtmlWithMraid;
}

- (void)load:(NSString *)adHtmlWithMraid from:(NSURL *)url {
    [self addSubview:_webView];
    [_webView loadHTMLString:adHtmlWithMraid baseURL:url];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewDidFinishLoad:)]) {
        [self.delegate adViewDidFinishLoad:self];
    }
}

- (void)loadUrl:(NSURL *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error;
        NSString *adHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(adView:didStopLoadWithError:)]) {
                    [self.delegate adView:self didStopLoadWithError:error];
                }
            } else {
                NSString *adHtmlWithMraid = [self injectMraid:adHtml];
                [self load:adHtmlWithMraid from:url];
            }
        });
    });
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [_webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    [self updateMraid];
}


#pragma mark - properties

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.center = self.webView.center;
    }
    return _spinner;
}

@end
