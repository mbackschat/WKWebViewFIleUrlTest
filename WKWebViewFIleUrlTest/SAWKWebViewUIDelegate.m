/*
Copyright [2014] Shazron Abdullah

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "SAWKWebViewUIDelegate.h"

@implementation SAWKWebViewUIDelegate

- (instancetype) init
{
    self = [super init];
    if (self) {
        [self __initWithTitle:nil viewController:nil];
    }

    return self;
}

- (instancetype) initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        [self __initWithTitle:title viewController:nil];
    }

    return self;
}

- (instancetype) initWithTitle:(NSString*)title viewController:(UIViewController*)viewController
{
    self = [super init];
    if (self) {
        [self __initWithTitle:title viewController:viewController];
    }

    return self;
}

- (void) __initWithTitle:(NSString*)title viewController:(UIViewController*)viewController
{
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    self.viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (title != nil) {
        self.title = title;
    }
    
    if (viewController != nil) {
        self.viewController = viewController;
    }
}

- (void) webView:(WKWebView*)webView runJavaScriptAlertPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)())completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler();
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];
    
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void) webView:(WKWebView*)webView runJavaScriptConfirmPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler(YES);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
        {
            completionHandler(NO);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
    [alert addAction:cancel];

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void) webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:prompt
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler(((UITextField*)alert.textFields[0]).text);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
        {
            completionHandler(nil);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
        textField.text = defaultText;
    }];

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

@end
