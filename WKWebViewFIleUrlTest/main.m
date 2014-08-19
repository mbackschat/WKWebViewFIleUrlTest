//
//  main.m
//  WKWebViewFIleUrlTest
//
//  Created by shazron on 2014-08-15.
//  Copyright (c) 2014 shazron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GCDWebServer.h"

int main(int argc, char * argv[]) {
    
    @autoreleasepool {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* wwwFileBundlePath = [mainBundle pathForResource:@"index.html" ofType:@"" inDirectory:@"www"];
        NSString* wwwFolderPath = [wwwFileBundlePath stringByDeletingLastPathComponent];

        
        GCDWebServer* webServer = [[GCDWebServer alloc] init];
        [webServer addGETHandlerForBasePath:@"/" directoryPath:wwwFolderPath indexFilename:@"index.html" cacheAge:3600 allowRangeRequests:YES];
        [webServer startWithPort:8080 bonjourName:@"CordovaTest"];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
