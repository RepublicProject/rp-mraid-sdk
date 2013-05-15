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

#import "RPAdViewController.h"
#import "RPShareableMessage.h"

#define CALENDAR_EVENT_KIT_METHOD_FORMAT @"RPCalendarEventKit.getEventWithId(%@)"
#define CALENDAR_EVENT_KIT_CALLBACK_METHOD_FORMAT @"RPCalendarEventKit.callCallbackWithId(%@, %@)"
#define SHARE_KIT_METHOD_FORMAT @"RPShareKit.getShareableWithId(%@)"
#define SHARE_KIT_CALLBACK_METHOD_FORMAT @"RPShareKit.callCallbackWithId(%@, %@)"
#define MODAL_KIT_METHOD_FORMAT @"RPModalKit.getURLWithId(%@)"
#define MODAL_KIT_CALLBACK_METHOD_FORMAT @"RPModalKit.callCallbackWithId(%@, %@)"
#define CUSTOM_CLOSE_METHOD_FORMAT @"RP.getCustomCloseWithId(%@)"
#define RP_CALLBACK_METHOD_FORMAT @"RP.callCallbackWithId(%@, %@)"
#define RESIZE_PROPERTIES_METHOD_FORMAT @"RP.getResizePropertiesWithId(%@)"
#define EXPAND_PROPERTIES_METHOD_FORMAT @"RP.getExpandPropertiesWithId(%@)"
#define RP_UPDATE_SCREEN_SIZE_METHOD_FORMAT @"RP.setScreenSize(%@)"
#define RP_UPDATE_STATE_SIZE_METHOD_FORMAT @"RP.onStateChange('%@')"
#define RP_UPDATE_MAX_SIZE_METHOD_FORMAT @"RP.setMaxSize(%@)"

#define CLOSE_BUTTON_WIDTH 50
#define CLOSE_BUTTON_HEIGHT 50
#define DEFAULT_ANIMATION_DURATION 0.25

typedef void(^WhenClosedBlock)(void);

@interface RPAdViewController()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) RPOrientationProperties *orientationProperties;

@end

@implementation RPAdViewController {
    RPAdView *_adView;
    RPModalKit *_rpModalKit;
    RPEventKit *_rpEventKit;
    RPURLKit *_rpURLKit;
    RPShareKit *_rpShareKit;
    RPURLViewController *_rpURLViewController;
    RPAdPlacementType _placementType;
    BOOL _usesCustomCloseButton;
    BOOL _secondPart;
    WhenClosedBlock _whenClosed;
    BOOL _expanded;
    BOOL _calendarSupported;
    UIViewController *_controller;
    UIView *_superViewBeforeExpand;
}

#pragma mark - properties

- (RPOrientationProperties *)orientationProperties {
    if (!_orientationProperties) {
        _orientationProperties = [[RPOrientationProperties alloc] init];
        _orientationProperties.forceOrientation = RPOrientationPropertiesForceOrientationNone;
        _orientationProperties.allowOrientationChange = YES;
    }
    return _orientationProperties;
}


- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_closeButton addTarget:self
                         action:@selector(closeButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark - Close button

-(CGRect)closeButtonFrameForPosition:(NSString *)position {
    CGFloat x = 0;
    CGFloat y = 0;
    
    if ([position isEqualToString:@"bottom-right"]) {
        
        x = CGRectGetMaxX(_adView.frame) - CLOSE_BUTTON_WIDTH;
        y = CGRectGetMaxY(_adView.frame) - CLOSE_BUTTON_HEIGHT;
        
    } else if ([position isEqualToString:@"top-right"]) {
        
        x = CGRectGetMaxX(_adView.frame) - CLOSE_BUTTON_WIDTH;
        
    } else if ([position isEqualToString:@"bottom-left"]) {
        
        y = CGRectGetMaxY(_adView.frame) - CLOSE_BUTTON_HEIGHT;
        
    } else if ([position isEqualToString:@"center"]) {
        
        x = _adView.center.x - CLOSE_BUTTON_WIDTH/2;
        y = _adView.center.y - CLOSE_BUTTON_HEIGHT/2;
        
    } else if ([position isEqualToString:@"top-center"]) {
    
        x = _adView.center.x - CLOSE_BUTTON_WIDTH/2;
        
    } else if ([position isEqualToString:@"bottom-center"]) {
        
        x = _adView.center.x - CLOSE_BUTTON_WIDTH/2;
        y = CGRectGetMaxY(_adView.frame) - CLOSE_BUTTON_HEIGHT;
        
    }
    
    
    return CGRectMake(x, y, CLOSE_BUTTON_WIDTH, CLOSE_BUTTON_HEIGHT);
}

-(void)closeButtonClicked:(UIButton *)sender {
    NSString *state = _expanded ? @"default" : @"hidden";
    [self updateState:state];
    [self closeAd];
}

-(void)layoutCloseButton {
    [self layoutCloseButton:@"top-right"];
}

-(void)layoutCloseButton:(NSString *)customPosition {
    self.closeButton.frame = [self closeButtonFrameForPosition:customPosition];
    
    NSString *title = @"";
    if (!_usesCustomCloseButton) {
        title = @"✖";
    }
    
    [_closeButton setTitle:title forState:UIControlStateNormal];
    
    [_adView.webView addSubview:self.closeButton];
}

-(void)layoutCloseButton:(NSString *)customPosition useCustomClose:(BOOL)useCustomClose {
    _usesCustomCloseButton = useCustomClose;
    [self layoutCloseButton:customPosition];
}

-(void)closeAd {
    BOOL isInterstitial = _placementType == RPAdPlacementTypeInterstitial;

    if (_expanded) {
        [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
            [self dismissViewControllerAnimated:NO completion:^{
                [_superViewBeforeExpand addSubview:_adView];
                _adView.transform = CGAffineTransformIdentity;
                _adView.frame = _adView.defaultPosition;
            }];
        }];
        _expanded = NO;
        [self layoutCloseButton];       
    } else if (_secondPart || isInterstitial) {
        [self dismissViewControllerAnimated:isInterstitial completion:nil];
    } else {
        [self notifyAdDidClose];
    }

    if (_whenClosed) {
        _whenClosed();
    }
}

-(void)notifyAdDidClose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewControllerDidClose:)]) {
        [self.delegate adViewControllerDidClose:self];
    }
}

#pragma mark - Initialization methods

- (id)initWithPlacementType:(RPAdPlacementType)type forController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        _placementType = type;
        _controller = controller;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (id)initWithPlacementType:(RPAdPlacementType)type forController:(UIViewController *)controller isSecondPart:(BOOL)secondPart usingCustomClose:(BOOL)useCustomClose whenClosed:(void (^)(void))whenClosed {
    self = [self initWithPlacementType:type forController:controller];
    if (self) {
        _secondPart = secondPart;
        _whenClosed = whenClosed;
        _usesCustomCloseButton = useCustomClose;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationChanged:(NSDictionary *)param {
    NSLog(@"Orientation changed");
    [self updateScreenSize];
}

- (void)loadView {
    [super loadView];
    
    _adView = [[RPAdView alloc] init];
    _adView.target = self;
    _adView.delegate = self;

    self.view = _adView;
}

- (void)loadAdFromUrl:(NSURL *)url {
    [_adView loadUrl:url];
}


#pragma mark - UIWebViewDelegate

- (void)adViewDidFinishLoad:(RPAdView *)adView {
    [self layoutCloseButton];

    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewController:didLoadAdWithSize:)]) {
        [self.delegate adViewController:self didLoadAdWithSize:self.view.bounds.size];
    }
}

- (void)adView:(RPAdView *)adView didStopLoadWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adViewController:didLoadAdWithError:)]) {
        [self.delegate adViewController:self didLoadAdWithError:error];
    }
}

#pragma mark - Private methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    NSLog(@"shouldAutorotateToInterfaceOrientation: %d", toInterfaceOrientation);

    if (self.orientationProperties.allowOrientationChange) {
        return YES;
    }
    
    if (toInterfaceOrientation == self.orientationProperties.forcedOrientation) {
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldAutorotate {
    NSLog(@"shouldAutorotate: %d", self.orientationProperties.allowOrientationChange);
    return self.orientationProperties.allowOrientationChange;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    NSLog(@"preferredInterfaceOrientationForPresentation: %d", self.orientationProperties.forcedOrientation);

    if (self.orientationProperties.allowOrientationChange) {
        return [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    return self.orientationProperties.forcedOrientation;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSLog(@"supportedInterfaceOrientations: %d", self.orientationProperties.forcedOrientation);

    if (self.orientationProperties.forcedOrientation == UIInterfaceOrientationLandscapeLeft) {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    if (self.orientationProperties.forcedOrientation == UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (NSDictionary *)identifySupportedFeatures {
    BOOL telSupported = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];

    BOOL smsSupported = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]];

    BOOL isIos6 = [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedDescending;
    
    NSLog(@"Device is iOS 6: %d", isIos6);
    
    _calendarSupported = YES;
    
    if (isIos6) {
        _calendarSupported = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized;
    }

    BOOL storePictureSupported = YES;
    BOOL inlineVideoSupported = YES;

    NSDictionary *supportedFeatures = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithBool:telSupported], @"tel",
                                       [NSNumber numberWithBool:smsSupported], @"sms",
                                       [NSNumber numberWithBool:_calendarSupported], @"calendar",
                                       [NSNumber numberWithBool:storePictureSupported], @"storePicture",
                                       [NSNumber numberWithBool:inlineVideoSupported], @"inlineVideo", nil];

    return supportedFeatures;
}

- (void)executeInitCallbackForId:(NSString *)currentId withSupportedFeatures:(NSDictionary *)supportedFeatures andPlacementType:(NSString *)placementType {

    NSMutableDictionary *initData =  [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               supportedFeatures, @"deviceFeatures",
                               placementType, @"placementType", nil];

    if (_secondPart) {
        [initData setObject:@"expanded" forKey:@"state"];
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:initData
                                                       options:0
                                                         error:&error];

    NSString *jsonString = @"false";
    if (!error) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_CALLBACK_METHOD_FORMAT, currentId, jsonString];

    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

- (NSString *)placementTypeAsJavascriptString {
    if (_placementType == RPAdPlacementTypeInterstitial) {
        return @"interstitial";
    }

    if (_placementType == RPAdPlacementTypeInline) {
        return @"inline";
    }

    return @"unknown";
}


#pragma mark - Javascript methods

- (void)initSDKForId:(NSString *)currentId {
    NSDictionary *supportedFeatures = [self identifySupportedFeatures];
    [self executeInitCallbackForId:currentId withSupportedFeatures:supportedFeatures andPlacementType:[self placementTypeAsJavascriptString]];
    [self updateScreenSize];
}

- (void)changeOrientationProperties:(NSString *)orientationPropertiesJSON {
    NSError *error;
    NSDictionary *orientationPropertiesDictionary = [NSJSONSerialization JSONObjectWithData:[orientationPropertiesJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    NSLog(@"Current orientation properties: %@", self.orientationProperties);
    
    self.orientationProperties = [[RPOrientationProperties alloc] initWithDictionary:orientationPropertiesDictionary];
    
    NSLog(@"New orientation properties: %@", self.orientationProperties);
    
}

- (void)useCustomClose:(NSString *)currentId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:CUSTOM_CLOSE_METHOD_FORMAT, currentId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    _usesCustomCloseButton = [[responseDictionary objectForKey:@"useCustomClose"] boolValue];

    [self layoutCloseButton];
}

- (void)close:(NSString *)currentId {

    [self closeAd];

    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_CALLBACK_METHOD_FORMAT, currentId, @"true"];

    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

- (void)expand:(NSString *)currentId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:EXPAND_PROPERTIES_METHOD_FORMAT, currentId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    if (error) {
        NSLog(@"Error getting expand properties cannot proceed with the expand method.");
        return;
    }
    
    _usesCustomCloseButton = [responseDictionary objectForKey:@"useCustomClose"];
    
    RPAdViewController *expandedController = self;
    
    NSString *urlString = [responseDictionary objectForKey:@"url"];
	NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        NSLog(@"Two-part ad expanding to %@:", url);

        expandedController = [[RPAdViewController alloc] initWithPlacementType:RPAdPlacementTypeInline forController:_controller isSecondPart:YES usingCustomClose:_usesCustomCloseButton whenClosed:^{
            [self updateState:@"default"];
        }];
    } else {
        _superViewBeforeExpand = _adView.superview;
        [_adView removeFromSuperview];
        
        [self layoutCloseButton];
        _expanded = YES;
    }
        
    [_controller presentViewController:expandedController animated:NO completion:^{
        CGRect expandFrame = _adView.bounds;
        
        float width = [[responseDictionary objectForKey:@"width"] floatValue];
        float height = [[responseDictionary objectForKey:@"height"] floatValue];
        
        BOOL frameHasChanged = NO;
        
        if (width > 0 && width < expandFrame.size.width) {
            expandFrame.size.width = width;
            frameHasChanged = YES;
        }
        
        if (height > 0 && height < expandFrame.size.height) {
            expandFrame.size.height = height;
            frameHasChanged = YES;
        }
        
        if (frameHasChanged) {
            expandedController.view.frame = expandFrame;
        }
    }];
    
    if (url) {
        [expandedController loadAdFromUrl:url];
    }
}

- (void)resize:(NSString *)currentId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:RESIZE_PROPERTIES_METHOD_FORMAT, currentId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];
    
    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"Error getting resize properties cannot proceed with the resize method.");
        return;
    }
    
    NSLog(@"Resizing with properties: %@", responseDictionary);
    
    NSNumber *width = [responseDictionary objectForKey:@"width"];
    NSNumber *height = [responseDictionary objectForKey:@"height"];
    NSNumber *x = [responseDictionary objectForKey:@"offsetX"];
    NSNumber *y = [responseDictionary objectForKey:@"offsetY"];
    
    CGRect currentFrame = _adView.frame;
    CGRect resizedFrame = currentFrame;
    
    resizedFrame.origin.x += [x floatValue];
    resizedFrame.origin.y += [y floatValue];
    
    resizedFrame.size.height = [height floatValue];
    resizedFrame.size.width = [width floatValue];
    
    BOOL allowOffscreen = [[responseDictionary objectForKey:@"allowOffscreen"]  boolValue];
    
    if (!allowOffscreen) {
        NSLog(@"Offscreen is not allowed, adjusting the size to fit the screen");
        resizedFrame = [self adjustResizedFrameToFit:resizedFrame];
    }

    [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
        _adView.frame = resizedFrame;
    }];
    
    [self layoutCloseButton:[responseDictionary objectForKey:@"customClosePosition"] useCustomClose:YES];
}

- (CGRect)adjustResizedFrameToFit:(CGRect)resizedFrame {
    
    CGRect maxSize = [_adView superview].bounds;
    CGRect adjustedFrame = resizedFrame;
    
    if (!CGRectContainsRect(maxSize, resizedFrame)) {
        if (CGRectGetWidth(resizedFrame) > CGRectGetWidth(maxSize)) {
            adjustedFrame.size.width = CGRectGetWidth(maxSize);
        }
        
        if (CGRectGetHeight(resizedFrame) > CGRectGetHeight(maxSize)) {
            adjustedFrame.size.height = CGRectGetHeight(maxSize);
        }
        
        if (CGRectGetMaxX(resizedFrame) > CGRectGetMaxX(maxSize)) {
            adjustedFrame.origin.x -= CGRectGetMaxX(resizedFrame) - CGRectGetMaxX(maxSize);
        } else if (CGRectGetMinX(resizedFrame) < CGRectGetMinX(maxSize)) {
            adjustedFrame.origin.x = CGRectGetMinX(maxSize);
        }
        
        if (CGRectGetMaxY(resizedFrame) > CGRectGetMaxY(maxSize)) {
            adjustedFrame.origin.y -= CGRectGetMaxY(resizedFrame) - CGRectGetMaxY(maxSize);
        } else if (CGRectGetMinY(resizedFrame) < CGRectGetMinY(maxSize)) {
            adjustedFrame.origin.y = CGRectGetMinY(maxSize);
        }
    }
    
    NSLog(@"Frame %@ adjusted to %@", NSStringFromCGRect(resizedFrame), NSStringFromCGRect(adjustedFrame));
    [self layoutCloseButton];
    return adjustedFrame;
}

- (void)shareToFacebook:(NSString *)shareableId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:SHARE_KIT_METHOD_FORMAT, shareableId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    RPShareableMessage *shareableMessage = [[RPShareableMessage alloc] initWithDictionary:responseDictionary];

    _rpShareKit = [[RPShareKit alloc] initWithViewController:self];
    _rpShareKit.delegate = self;
    _rpShareKit.currentId = shareableId;
    [_rpShareKit shareOnFacebookWithMessage:shareableMessage];

    [self notifyOpenModal];
}

- (void)shareToTwitter:(NSString *)shareableId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:SHARE_KIT_METHOD_FORMAT, shareableId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    RPShareableMessage *shareableMessage = [[RPShareableMessage alloc] initWithDictionary:responseDictionary];

    _rpShareKit = [[RPShareKit alloc] initWithViewController:self];
    _rpShareKit.delegate = self;
    _rpShareKit.currentId = shareableId;
    [_rpShareKit shareOnTwitterWithMessage:shareableMessage];

    [self notifyOpenModal];
}

- (void)shareDialog:(NSString *)shareableId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:SHARE_KIT_METHOD_FORMAT, shareableId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    RPShareableMessage *shareableMessage = [[RPShareableMessage alloc] initWithDictionary:responseDictionary];

    _rpShareKit = [[RPShareKit alloc] initWithViewController:self];
    _rpShareKit.delegate = self;
    _rpShareKit.currentId = shareableId;
    [_rpShareKit shareOnDialogWithMessage:shareableMessage];

    [self notifyOpenModal];
}

- (void)addEventToUserCalendar:(NSString *)shareableId {
    if (!_calendarSupported) {
        NSLog(@"Calendar not supported");
        [self executeCallback:CALENDAR_EVENT_KIT_CALLBACK_METHOD_FORMAT forId:shareableId withStatus:NO];
    } else {
        NSString *javascriptMethodCallString = [NSString stringWithFormat:CALENDAR_EVENT_KIT_METHOD_FORMAT, shareableId];
        NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];
        
        NSError *error;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        _rpEventKit = [[RPEventKit alloc] initWithViewController:self];
        _rpEventKit.delegate = self;
        _rpEventKit.currentId = shareableId;
        [_rpEventKit addEvent:responseDictionary];
        
        [self notifyOpenModal];
    }
}

- (void)showVideoPlayer:(NSString *)urlId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:MODAL_KIT_METHOD_FORMAT, urlId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    _rpModalKit = [[RPModalKit alloc] initWithViewController:self];
    _rpModalKit.delegate = self;
    _rpModalKit.currentId = urlId;
    [_rpModalKit showVideoPlayer:responseDictionary];

    [self notifyOpenModal];
}

- (void)pushURL:(NSString *)urlId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:MODAL_KIT_METHOD_FORMAT, urlId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    _rpURLViewController = [[RPURLViewController alloc] init];
    _rpURLViewController.delegate = self;
    _rpURLViewController.currentId = urlId;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_rpURLViewController];

    [self presentViewController:navigationController animated:YES completion:nil];

    [_rpURLViewController pushURL:responseDictionary];

    [self notifyOpenModal];
}

- (void)openURL:(NSString *)urlId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:MODAL_KIT_METHOD_FORMAT, urlId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];

    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    _rpURLKit = [[RPURLKit alloc] init];
    _rpURLKit.delegate = self;
    _rpURLKit.currentId = urlId;
    [_rpURLKit openURL:responseDictionary];

    [self notifyOpenModal];
}

- (void)storePicture:(NSString *)urlId {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:MODAL_KIT_METHOD_FORMAT, urlId];
    NSString *response = [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];
    
    NSError *error;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    _rpURLKit = [[RPURLKit alloc] init];
    _rpURLKit.delegate = self;
    _rpURLKit.currentId = urlId;
    [_rpURLKit storePicture:responseDictionary];
    
    [self notifyOpenModal];
}

- (void)notifyOpenModal {
if (self.delegate && [self.delegate respondsToSelector:@selector(adViewControllerDidOpenModal:)]) {
        [self.delegate adViewControllerDidOpenModal:self];
    }
}

- (void)updateScreenSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize maxSize = [_adView superview].bounds.size;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        screenSize = CGSizeMake(screenSize.height, screenSize.width);
    }
    
    NSLog(@"Orientation changed, screen size: %@, max size: %@", NSStringFromCGSize(screenSize), NSStringFromCGSize(maxSize));
    
    NSString *sizeObject = [NSString stringWithFormat:@"{\"width\": %f, \"height\": %f}", screenSize.width, screenSize.height];
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_UPDATE_SCREEN_SIZE_METHOD_FORMAT, sizeObject];
    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
    
    NSString *maxSizeObject = [NSString stringWithFormat:@"{\"width\": %f, \"height\": %f}", maxSize.width, maxSize.height];
    javascriptCallbackMethodCallString = [NSString stringWithFormat:RP_UPDATE_MAX_SIZE_METHOD_FORMAT, maxSizeObject];
    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

-(void)updateState:(NSString *)state {
    NSString *javascriptMethodCallString = [NSString stringWithFormat:RP_UPDATE_STATE_SIZE_METHOD_FORMAT, state];

    NSLog(@"Executing javascript %@ on webView %@", javascriptMethodCallString, _adView.webView);

    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptMethodCallString];
}

#pragma mark - RPShareKitDelegate methods

- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithFacebook:(BOOL)success {
    [self executeCallback:SHARE_KIT_CALLBACK_METHOD_FORMAT forId:shareKit.currentId withStatus:success];
}

- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithTwitter:(BOOL)success {
    [self executeCallback:SHARE_KIT_CALLBACK_METHOD_FORMAT forId:shareKit.currentId withStatus:success];
}

- (void)shareKit:(RPShareKit *)shareKit didFinishSharingWithDialog:(BOOL)success {
    [self executeCallback:SHARE_KIT_CALLBACK_METHOD_FORMAT forId:shareKit.currentId withStatus:success];
}


#pragma mark - RPModalKitDelegate methods

- (void)modalKit:(RPModalKit *)modalKit didFinishShowingVideoPlayer:(BOOL)success {
    [self executeCallback:MODAL_KIT_CALLBACK_METHOD_FORMAT forId:modalKit.currentId withStatus:success];
}


#pragma mark - RPURLKitDelegate methods

- (void)urlKit:(RPURLKit *)urlKit didFinishOpeningURL:(BOOL)success {
    [self executeCallback:MODAL_KIT_CALLBACK_METHOD_FORMAT forId:urlKit.currentId withStatus:success];
}

- (void)urlKit:(RPURLKit *)urlKit didFinishStoringPicture:(BOOL)success {
    [self executeCallback:MODAL_KIT_CALLBACK_METHOD_FORMAT forId:urlKit.currentId withStatus:success];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    BOOL sucess = (error == nil);
    [self executeCallback:MODAL_KIT_CALLBACK_METHOD_FORMAT forId:((__bridge RPURLKit *) contextInfo).currentId withStatus:sucess];
}


#pragma mark - RPURLViewControllerDelegate methods

- (void)urlViewController:(RPURLViewController *)urlViewController didFinishPushingURL:(BOOL)success {
    [self executeCallback:MODAL_KIT_CALLBACK_METHOD_FORMAT forId:urlViewController.currentId withStatus:success];
}


#pragma mark - RPEventKitDelegate methods

- (void)eventKit:(RPEventKit *)eventKit didFinishAddingEvent:(BOOL)success {
    [self executeCallback:CALENDAR_EVENT_KIT_CALLBACK_METHOD_FORMAT forId:eventKit.currentId withStatus:success];
}

- (void)executeCallback:(NSString *)callback forId:(NSString *)currentId withStatus:(BOOL)success {
    NSString *successString = success ? @"true" : @"false";
    NSString *javascriptCallbackMethodCallString = [NSString stringWithFormat:callback, currentId, successString];
    
    [_adView.webView stringByEvaluatingJavaScriptFromString:javascriptCallbackMethodCallString];
}

@end
