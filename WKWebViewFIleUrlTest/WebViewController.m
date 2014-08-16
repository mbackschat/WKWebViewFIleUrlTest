//
//  WebViewController.m
//  WKWebViewFileUrlTest
//
//  Created by shazron on 2014-08-15.
//  Copyright (c) 2014 shazron. All rights reserved.
//

#import "WebViewController.h"
#import "SAWKWebViewUIDelegate.h"

@interface WebViewController ()

@end

@implementation WebViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"Load %@", self.urlToLoad);
    
    CGRect webViewBounds = self.view.bounds;
    webViewBounds.origin = self.view.bounds.origin;

    WKUserContentController* userContentController = [[WKUserContentController alloc] init];
    
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:webViewBounds configuration:configuration];

    self.webViewUIDelegate = [[SAWKWebViewUIDelegate alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] viewController:self];
    self.webView.UIDelegate = self.webViewUIDelegate;
    self.webView.navigationDelegate = self;
    
    // load the passed in URL
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlToLoad]]];
    
    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WKNavigationDelegate

- (void)alert:(NSString*)message
{
    UIAlertController* alert =
    [UIAlertController
     alertControllerWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                    message:message
                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok =
    [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                    style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction* action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    NSLog(@"%@", [error localizedDescription]);
    [self alert:[error localizedDescription]];
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    NSLog(@"%@", [error localizedDescription]);
    [self alert:[error localizedDescription]];
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation
{
    // update the location element with the url
    NSString* js = [NSString stringWithFormat:@"document.getElementById('location').innerHTML='%@';", self.urlToLoad];
    [webView evaluateJavaScript:js completionHandler:^(id obj, NSError* error) {
        
    }];
}

@end
