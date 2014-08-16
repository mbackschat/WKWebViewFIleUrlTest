//
//  WebViewController.h
//  WKWebViewFIleUrlTest
//
//  Created by shazron on 2014-08-15.
//  Copyright (c) 2014 shazron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, copy) NSString* urlToLoad;
@property (nonatomic, strong) WKWebView* webView;
@property (nonatomic, strong) id <WKUIDelegate> webViewUIDelegate;

@end

