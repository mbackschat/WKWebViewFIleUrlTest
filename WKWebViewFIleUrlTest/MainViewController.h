//
//  MainViewController.h
//  WKWebViewFIleUrlTest
//
//  Created by shazron on 2014-08-15.
//  Copyright (c) 2014 shazron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController<UITableViewDelegate>

@property (nonatomic, strong) NSArray* indexFilePaths;
@property (nonatomic, strong) NSArray* indexFilePathsUselocalFileURLReadAccessURLSelector;
@property (weak, nonatomic) IBOutlet UIButton* localFileURLLabel;

@end

