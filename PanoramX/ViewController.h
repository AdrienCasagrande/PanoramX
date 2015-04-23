//
//  ViewController.h
//  PanoramX
//
//  Created by Adrien CASAGRANDE on 22/04/15.
//  Copyright (c) 2015 Adrien Casagrande. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIButton *resetButton;
@property (strong, nonatomic) UIButton *shootButton;
@property (strong, nonatomic) NSDictionary *overlap;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) NSMutableArray *pics;

@end

