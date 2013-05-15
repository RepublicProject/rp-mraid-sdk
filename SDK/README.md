RP MRAID SDK quick-start guide
==============================
Grab the SDK from: https://github.com/RepublicProject/rp-mraid-sdk/tree/master/SDK/iOS  
A sample app is also available at: https://github.com/RepublicProject/rp-mraid-sdk/tree/master/SampleApp/  

Installation/integration:  
-------------------------  

1. Use the link above to get the Republic Project MRAID SDK either by downloading or cloning the GitHub repository.

2. Take the Republic.framework folder found in SDK/iOS/build/ and drag it into the Frameworks folder of your app's xCode project.  

3. With your view controller's header file, import RPAdController.h and declare an RPAdController property. Your app's view controller should implement the RPAdController delegate protocol.

4. With your view controller's implementation file, create an instance of RPAdViewController (named rpAdController for this example) in your app, passing in the type of ad (banner or interstitial) that you wish to use. This should be either RPAdPlacementTypeInterstitial or RPAdPlacementTypeInterstitial.  
*Example:*  
```RPAdViewController *rpAdViewController = [[RPAdViewController alloc] initWithPlacementType:RPAdPlacementTypeInterstitial forController:self];```

5. Register your view controller as the RPAdController instance's delegate.  
*Example:*  
```rpAdViewController.delegate = self;```

6. To show an ad:  
call loadAdFromUrl:url on your instance of RPAdViewController  (Where url is an NSURL object referencing the URL of the desired ad)  
*Example:*  
```[rpAdViewController loadAdFromUrl:url];```


Design/Layout considerations:
------------------------------  
This SDK was created in least-obstrusive manner. As such, some layout events will need to be handled by the app developer.  
For example, the app developer might like to add an event handler for orientationChange events. Here's a sample block of code (same as found in our sample app)  

```- (void)orientationChanged:(NSDictionary *)param {  
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
}```


