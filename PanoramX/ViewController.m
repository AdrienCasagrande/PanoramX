//
//  ViewController.m
//  PanoramX
//
//  Created by Adrien CASAGRANDE on 22/04/15.
//  Copyright (c) 2015 Adrien Casagrande. All rights reserved.
//

#import "ViewController.h"

float const bordure = 0.1;

@interface ViewController ()

@end

@implementation ViewController

float overlayWidth;
float overlayHeight;
CGRect baseButtonframe;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _pics = [[NSMutableArray alloc] init];
    baseButtonframe = CGRectMake(0, 0, 100, 100);
    _overlap = [NSDictionary dictionaryWithObjectsAndKeys:[[UIImageView alloc] initWithFrame:self.view.bounds], @"down",
                                                          [[UIImageView alloc] initWithFrame:self.view.bounds], @"left", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self overlaySetup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showPicker];
}

#pragma mark UI

- (void)overlaySetup {
    _overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayHeight = _overlay.frame.size.height;
    overlayWidth = _overlay.frame.size.width;
    [self setupButtons];
    [self setupGuides];
}


// les boutons
- (void)setupButtons {
    // bouton reset
    _resetButton = [[UIButton alloc] initWithFrame:baseButtonframe]; // initialiser le bouton
    _resetButton.center = CGPointMake(_overlay.frame.size.width * 0.5,
                                      baseButtonframe.size.height); // rectangle du bouton
    [_resetButton setTitle:@"Reset" forState:UIControlStateNormal]; // titre
    [_resetButton addTarget:self action:@selector(resetSel) forControlEvents:UIControlEventTouchUpInside]; // la fonction du bouton
    [_overlay addSubview:_resetButton]; // on l ajoute a la page
    
    // bouton shoot
    _shootButton = [[UIButton alloc] initWithFrame:baseButtonframe];
    _shootButton.center = CGPointMake(_overlay.frame.size.width * 0.5,
                                      _overlay.frame.size.height - baseButtonframe.size.height);
    [_shootButton setTitle:@"Shoot" forState:UIControlStateNormal];
    [_shootButton addTarget:self action:@selector(shootSel) forControlEvents:UIControlEventTouchUpInside];
    [_overlay addSubview:_shootButton];
}

- (void)setupGuides {
    [self addGuideFrom:CGPointMake(overlayWidth * bordure, 0)
                    to:CGPointMake(overlayWidth * bordure, overlayHeight)];
    [self addGuideFrom:CGPointMake(overlayWidth * (1 - bordure), 0)
                    to:CGPointMake(overlayWidth * (1 - bordure), overlayHeight)];
    [self addGuideFrom:CGPointMake(0, overlayHeight * bordure)
                    to:CGPointMake(overlayWidth, overlayHeight * bordure)];
    [self addGuideFrom:CGPointMake(0, overlayHeight * (1 - bordure))
                    to:CGPointMake(overlayWidth, overlayHeight * (1 - bordure))];
}

- (void)addGuideFrom:(CGPoint)start to:(CGPoint)end {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor blueColor] CGColor];
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [_overlay.layer addSublayer:shapeLayer];
}

- (void)setupPositionGuide {
    
}

- (void)displayOverlap {
    if (_pics.count % 2 == 1) {
        [_overlay insertSubview:_overlap[@"down"] atIndex:0];
        [UIView animateWithDuration:0.5 animations:^{
            [(UIImageView *) _overlap[@"down"] setFrame:CGRectMake(0, overlayHeight * (1 - bordure),
                                                                   overlayWidth, overlayHeight)];
            [(UIImageView *) _overlap[@"down"] setAlpha:0.8];
        }];
    }
    else {
        [_overlay insertSubview:_overlap[@"left"] atIndex:0];
        [UIView animateWithDuration:0.5 animations:^{
            [(UIImageView *) _overlap[@"down"] setFrame:CGRectMake(- overlayWidth * (1 - bordure), 0,
                                                                   overlayWidth, overlayHeight)];
            [(UIImageView *) _overlap[@"left"] setFrame:CGRectMake(- overlayWidth * (1 - bordure), - overlayHeight * (1 - bordure),
                                                                   overlayWidth, overlayHeight)];
            [(UIImageView *) _overlap[@"left"] setAlpha:0.8];
        }];
    }
}

#pragma mark Button selectors

- (void)resetSel {
    _pics = [[NSMutableArray alloc] init];
    
    for (NSString *key in _overlap) {
        [[_overlap objectForKey:key] removeFromSuperview];
    }
    
    _overlap = [NSDictionary dictionaryWithObjectsAndKeys:
                [[UIImageView alloc] initWithFrame:self.view.bounds], @"down",
                [[UIImageView alloc] initWithFrame:self.view.bounds], @"left", nil];
}

- (void)shootSel {
    [_picker takePicture];
}

#pragma mark Image picker

- (void)showPicker {
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = YES;
    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _picker.showsCameraControls = NO;
    _picker.navigationBarHidden = YES;
    
    _picker.cameraOverlayView = _overlay;
    
    [self presentViewController:_picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_pics addObject:info[UIImagePickerControllerOriginalImage]];
    if (_pics.count % 2 == 1) {
        [_overlap[@"down"] setImage:info[UIImagePickerControllerOriginalImage]];
    } else {
        [_overlap[@"left"] setImage:info[UIImagePickerControllerOriginalImage]];
    }
    [self displayOverlap];
    NSLog(@"%lu", (unsigned long)_pics.count);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Nope");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
