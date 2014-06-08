//
//  OZViewController.h
//  Objective-Zip
//
//  Created by Bogdan Iusco on 6/8/14.
//  Copyright (c) 2014 yourcompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OZViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;

- (IBAction)zipUnzip;
- (IBAction)zipUnzip2;
- (IBAction)zipCheck1;
- (IBAction)zipCheck2;

@end
