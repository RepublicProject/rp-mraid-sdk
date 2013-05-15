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

#import "RPURLViewController.h"

#define SPINNER_SIZE 24


@interface RPURLViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIBarButtonItem *stopButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;

@end

@implementation RPURLViewController

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
    }
    return _webView;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.center = self.webView.center;
    }
    return _spinner;
}

- (UIBarButtonItem *)backButton {
    if (!_backButton) {
        _backButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"assets/back"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
        _backButton.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
        _backButton.width = 18.0f;
    }
    return _backButton;
}

- (UIBarButtonItem *)forwardButton {
    if (!_forwardButton) {
        _forwardButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"assets/forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonClicked:)];
        _forwardButton.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
        _forwardButton.width = 18.0f;
    }
    return _forwardButton;
}

- (UIBarButtonItem *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked:)];
    }
    return _refreshButton;
}

- (UIBarButtonItem *)stopButton {
    if (!_stopButton) {
        _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonClicked:)];
    }
    return _stopButton;
}

- (UIBarButtonItem *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonClicked:)];
    }
    return _closeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)updateToolbar {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    UIBarButtonItem *refreshOrStopButton = self.webView.isLoading ? self.stopButton : self.refreshButton;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5.0f;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = @[fixedSpace, self.backButton, flexibleSpace, self.forwardButton, flexibleSpace, refreshOrStopButton, flexibleSpace, self.closeButton, fixedSpace];
    
    [self.navigationController setToolbarHidden:NO];
}

- (void)pushURL:(NSDictionary *)urlDictionary {
    NSURL *url;
    
    if ([urlDictionary objectForKey:@"url"]) {
        url = [NSURL URLWithString:[urlDictionary objectForKey:@"url"]];
    }
    
    self.view = self.webView;
    self.view.accessibilityLabel = @"rpPushURLView";
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - Target actions

- (void)closeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backButtonClicked:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (void)forwardButtonClicked:(UIBarButtonItem *)sender {
    [self.webView goForward];
}

- (void)refreshButtonClicked:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (void)stopButtonClicked:(UIBarButtonItem *)sender {
    [self.webView stopLoading];
    [self updateToolbar];
}

#pragma mark - UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.webView addSubview:self.spinner];
    [self.spinner startAnimating];
    [self updateToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    [self updateToolbar];
    [self.delegate urlViewController:self didFinishPushingURL:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_spinner stopAnimating];
    [self.delegate urlViewController:self didFinishPushingURL:NO];
    NSLog(@"Error description: %@", error);
}

@end
