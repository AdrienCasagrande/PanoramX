//
//  ViewController.m
//  PanoramX
//
//  Created by Adrien CASAGRANDE on 22/04/15.
//  Copyright (c) 2015 Adrien Casagrande. All rights reserved.
//

#import "ViewController.h"

float const bordure = 0.15;

@interface ViewController ()

@end

@implementation ViewController

float overlayWidth;
float overlayHeight;
CGRect baseButtonframe;

CMMotionManager *motionManager;
CMAttitude *referenceAttitude;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _pics = [[NSMutableArray alloc] init];
    baseButtonframe = CGRectMake(0, 0, 100, 100);
    _overlap = [NSDictionary dictionaryWithObjectsAndKeys:[[UIImageView alloc] initWithFrame:self.view.bounds], @"down",
                                                          [[UIImageView alloc] initWithFrame:self.view.bounds], @"left", nil];
    //_height = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self overlaySetup];
    motionManager = [[CMMotionManager alloc] init];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hauteur" message:@"Pouvez vous prendre le rayon sur toute ca hauteur en une fois ?" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Hauteur"] && buttonIndex == 1) {
        if (buttonIndex == 1) {
            _height = 1;
        } else if (buttonIndex == 0) {
            _height = 2;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showPicker];
    [self addPointers];
    [self startMotionDetection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UI

- (void)overlaySetup {
    _overlay = [[UIView alloc] initWithFrame:self.view.frame];
    overlayHeight = _overlay.frame.size.height;
    overlayWidth = _overlay.frame.size.width;
    [self setupButtons];
    [self setupGuides];
    [_overlay insertSubview:_overlap[@"down"] atIndex:0];
    [_overlay insertSubview:_overlap[@"left"] atIndex:0];
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
    [_shootButton addTarget:self action:@selector(shootSel) forControlEvents:UIControlEventTouchUpInside];
    UIImage *buttonCapture = [UIImage imageNamed:@"toto.png"];
    [_shootButton setBackgroundImage:buttonCapture forState:UIControlStateNormal];
    [_overlay addSubview:_shootButton];
    
    _finishButton = [[UIButton alloc] initWithFrame:baseButtonframe];
    _finishButton.center = CGPointMake(_resetButton.center.x + _finishButton.frame.size.width, _resetButton.center.y);
    [_finishButton addTarget:self action:@selector(finishSel) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *buttonFinish = [UIImage imageNamed:@"validate_360.png"];
    [_finishButton setBackgroundImage:buttonFinish forState:UIControlStateNormal];
    [_overlay addSubview:_finishButton];
    
}

- (void)setupGuides {
    [self addGuideFrom:CGPointMake(overlayWidth * bordure, 0)
                    to:CGPointMake(overlayWidth * bordure, overlayHeight)];
    if (_height == 2) {
        [self addGuideFrom:CGPointMake(0, overlayHeight * (1 - bordure))
                    to:CGPointMake(overlayWidth, overlayHeight * (1 - bordure))];
    }
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
    if (_height == 2) {
        [self overlapTwo];
    } else {
        [self overlapOne];
    }
}

- (void)overlapOne {
    [UIView animateWithDuration:0.5 animations:^{
        [(UIImageView *) _overlap[@"left"] setFrame:CGRectMake(- overlayWidth * (1 - bordure), 0,
                                                               overlayWidth, overlayHeight)];
        [(UIImageView *) _overlap[@"left"] setAlpha:0.8];
    }];
}

- (void)overlapTwo {
    if (_pics.count % 2 == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            
            [(UIImageView *) _overlap[@"down"] setFrame:CGRectMake(0, overlayHeight * (1 - bordure),
                                                                   overlayWidth, overlayHeight)];
            [(UIImageView *) _overlap[@"down"] setAlpha:0.8];
        }];
    } else {
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
    [_overlay insertSubview:_overlap[@"down"] atIndex:0];
    [_overlay insertSubview:_overlap[@"left"] atIndex:0];
    [_preview removeFromSuperview];
    [self startMotionDetection];
}

- (void)shootSel {
    [_picker takePicture];
}

- (void)finishSel {
    [motionManager stopDeviceMotionUpdates];
    UIImage *img = [self mergeIMG:_pics withParams:YES height:_height];
    float w = img.size.height > img.size.width ? self.view.frame.size.width * 0.7 : self.view.frame.size.width;
    float h = ((img.size.width * w) / 100) * img.size.height;
    _preview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    _preview.center = self.view.center;
    _preview.contentMode = UIViewContentModeScaleAspectFit;
    [_preview setImage:img];
    [_overlay addSubview:_preview];
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
    
    [[_overlay layer] setBorderColor: [UIColor redColor].CGColor];
    
    [self presentViewController:_picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_pics addObject:info[UIImagePickerControllerOriginalImage]];
    if (_pics.count % _height == 1) {
        [_overlap[@"down"] setFrame:_overlay.frame];
        [_overlap[@"down"] setImage:info[UIImagePickerControllerOriginalImage]];
        [_overlap[@"left"] setImage:nil];
    } else {
        [_overlap[@"left"] setFrame:_overlay.frame];
        [_overlap[@"left"] setImage:info[UIImagePickerControllerOriginalImage]];
    }
    [self displayOverlap];
    NSLog(@"%lu", (unsigned long)_pics.count);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Nope");
}

#pragma mark IMG Merge

- (UIImage *)mergeIMG:(NSMutableArray *)pics withParams:(BOOL)leftToRight height:(int)height {
    CGSize size = [(UIImage *)_pics[0] size];
    float w = size.width * (pics.count / height) * (1 - bordure);
    float h = size.height * height * (1 - bordure);
    CGSize finalSize = CGSizeMake(w, h);
    UIGraphicsBeginImageContext(finalSize);
    
    for (int i = 0; i < _pics.count; i++) {
        [(UIImage *)_pics[i] drawAtPoint:[self positionWith:leftToRight height:height iteration:i picSize:size]];
        NSLog(@"pic=%d", i);
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (CGPoint)positionWith:(BOOL)leftToRight height:(int)height iteration:(int)i picSize:(CGSize)size {
    CGPoint pt = CGPointMake(0, 0);
    int row = (i + 1) % height;
    int col = i / height;
    
    NSLog(@"col=%d row=%d", col, row);
    pt.y = row * size.height;
    if (leftToRight) {
        pt.x = col * size.width;
    } else {
        
    }
    
    return pt;
}

#pragma mark Motion

- (void)startMotionDetection {
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 0.01f;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(CMDeviceMotion *data, NSError *error) {
                                         CGRect tmp = _horizontalPointer.frame;
                                         tmp.origin.y = (data.gravity.z * (overlayHeight / 2)) + (overlayHeight / 2);
                                         [_horizontalPointer setFrame:tmp];
                                         
                                         double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
                                         _verticalPointer.transform = CGAffineTransformMakeRotation(rotation);
                                         
                                         if (data.gravity.z > -0.01 && data.gravity.z < 0.01 && rotation > -0.015 && rotation < 0.015) {
                                             [_indicator setBackgroundColor:[UIColor greenColor]];
                                             [_shootButton setEnabled:YES];
                                         } else {
                                             [_indicator setBackgroundColor:[UIColor redColor]];
                                             [_shootButton setEnabled:NO];
                                         }
                                         if (_height > 0 && _pics.count != 0 && _pics.count % _height == 0) {
                                             [_finishButton setEnabled:YES];
                                         } else {
                                             [_finishButton setEnabled:NO];
                                         }
                                     }];
    }
}

- (void)addPointers {
    _verticalPointer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, overlayWidth * 0.4, overlayWidth * 0.4)];
    UIImageView *target = [[UIImageView alloc] initWithFrame:_verticalPointer.frame];
    [target setContentMode:UIViewContentModeScaleAspectFit];
    [target setImage:[UIImage imageNamed:@"cible.png"]];
    [_verticalPointer addSubview:target];
    _indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _verticalPointer.frame.size.width / 2,
                                                             _verticalPointer.frame.size.width / 2)];
    _indicator.layer.cornerRadius = _verticalPointer.frame.size.height / 4;
    _indicator.center = _verticalPointer.center;
    _indicator.layer.masksToBounds = YES;
    [_indicator setBackgroundColor:[UIColor redColor]];
    [_indicator setAlpha:0.4];
    [_verticalPointer insertSubview:_indicator atIndex:0];
    [_verticalPointer setCenter:_overlay.center];
    [_overlay addSubview:_verticalPointer];
    
    _horizontalPointer = [[UIView alloc] initWithFrame:CGRectMake(0, overlayHeight / 2, overlayWidth, 4)];
    [_horizontalPointer setBackgroundColor:[UIColor redColor]];
    [_overlay addSubview:_horizontalPointer];
}

@end