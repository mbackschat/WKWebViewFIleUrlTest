//
//  MainViewController.m
//  WKWebViewFIleUrlTest
//
//  Created by shazron on 2014-08-15.
//  Copyright (c) 2014 shazron. All rights reserved.
//

#import "MainViewController.h"
#import "WebViewController.h"

@interface MainViewController ()

@property (nonatomic, readwrite) BOOL loadFileURLreadAccessURLAvailable;

@end

@implementation MainViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Copy all test files from bundle www, save urls
    self.indexFilePaths = @[
                            [self createFileUrlHelper:self.wwwBundleFolderPath],
                            [self createFileUrlHelper:[self copyBundleWWWFolderToFolder:[self libraryFolderPath]]],
                            [self createFileUrlHelper:[self copyBundleWWWFolderToFolder:[self libraryCachesFolderPath]]],
                            [self createFileUrlHelper:[self copyBundleWWWFolderToFolder:[self documentsFolderPath]]],
                            [self createFileUrlHelper:[self copyBundleWWWFolderToFolder:[self tmpFolderPath]]],
                            @"http://google.com",
                            [self createFileUrlHelper:self.wwwBundleFolderPath]
                            ];

    self.indexFilePathsUselocalFileURLReadAccessURLSelector =
                            @[
                                 @NO,
                                 @NO,
                                 @NO,
                                 @NO,
                                 @NO,
                                 @NO,
                                 @YES
                            ];

    WKWebView* testWebView = [[WKWebView alloc] init];
    SEL sel = NSSelectorFromString(@"loadFileURL:readAccessURL:");

    self.loadFileURLreadAccessURLAvailable = [testWebView respondsToSelector:sel];
    
    if (self.loadFileURLreadAccessURLAvailable) {
        
        // Add the option in the UI
        [self.localFileURLLabel setHidden:NO];
        
        // Notify the user with an alert
        NSString* message = [NSString stringWithFormat:@"[AVAILABLE] loadFileURL:readAccessURL: selector is available. Current iOS version: %@", [[UIDevice currentDevice] systemVersion]];
        NSLog(@"%@", message);
        
        UIAlertController* alertController = [UIAlertController  alertControllerWithTitle:@"Selector Available"  message:message  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    UIButton* button = (UIButton*)sender;
    WebViewController* webViewController = segue.destinationViewController;
    
    webViewController.title = button.titleLabel.text;
    webViewController.urlToLoad = self.indexFilePaths[button.tag];
    webViewController.useLoadFileURLreadAccessURL = self.indexFilePathsUselocalFileURLReadAccessURLSelector[button.tag];
}

- (NSString*) createFileUrlHelper:(NSString*)folderPath
{
    NSString* path = [folderPath stringByAppendingPathComponent:self.indexFileName];
    NSURL* url = [NSURL fileURLWithPath:path];
    return url.absoluteString;
}

- (BOOL)copyFrom:(NSString*)src to:(NSString*)dest error:(NSError* __autoreleasing*)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:src]) {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error != NULL) {
            (*error) = [NSError errorWithDomain:@"TestDomainTODO"
                                           code:1
                                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                            forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    BOOL destExists = [fileManager fileExistsAtPath:dest];
    
    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error]) {
        return NO;
    }
    
    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error]) {
        return NO;
    }
    
    // create path to dest
    if (!destExists && ![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error]) {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    } else {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
}

- (NSString*) libraryFolderPath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString*) libraryCachesFolderPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString*) documentsFolderPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString*) tmpFolderPath
{
    return NSTemporaryDirectory();
}

- (NSString*) wwwBundleFolderPath
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* wwwFileBundlePath = [mainBundle pathForResource:self.indexFileName ofType:@"" inDirectory:self.wwwFolderName];
    return [wwwFileBundlePath stringByDeletingLastPathComponent];
}

- (NSString*) indexFileName
{
    return @"index.html";
}

- (NSString*) wwwFolderName
{
    return @"www";
}

- (NSString*) copyBundleWWWFolderToFolder:(NSString*)folderPath
{
    NSString* location = nil;
    BOOL copyOK = NO;
    
    // is the bundle www index.html there
    NSString* indexFileWWWBundlePath = [self.wwwBundleFolderPath stringByAppendingPathComponent:self.indexFileName];
    BOOL readable = [[NSFileManager defaultManager] isReadableFileAtPath:indexFileWWWBundlePath];
    NSLog(@"File %@ is readable: %@", indexFileWWWBundlePath, readable? @"YES" : @"NO");
    
    if (readable) {
        NSString* newFolderPath = [folderPath stringByAppendingPathComponent:@"www"];
        
        // create the folder, if needed
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // copy
        NSError* error = nil;
        if ((copyOK = [self copyFrom:self.wwwBundleFolderPath to:newFolderPath error:&error])) {
            location = newFolderPath;
        }
        NSLog(@"Copy from %@ to %@ is ok: %@", folderPath, newFolderPath, copyOK? @"YES" : @"NO");
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            location = nil;
        }
    }
    
    return location;
}


@end
