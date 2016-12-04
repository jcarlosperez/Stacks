//
//  CPPCCameraImagePreviewsViewController.m
//  PicChoose
//
//  Created by Ben Rosen on 11/1/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCCameraImagePreviewsViewController.h"
#import "CompactConstraint.h"
#import "CPPCUtilities.h"

@interface CPPCCameraImagePreviewsViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *imageView1, *imageView2, *imageView3;

@end

@implementation CPPCCameraImagePreviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;

    _imageView1 = [[UIImageView alloc] init];
    _imageView1.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView1.layer.cornerRadius = 10;
    _imageView1.layer.masksToBounds = YES;
    _imageView1.contentMode = UIViewContentModeScaleAspectFill;
    _imageView1.tag = 0;
    [self.view addSubview:_imageView1];

    _imageView2 = [[UIImageView alloc] init];
    _imageView2.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView2.layer.cornerRadius = 10;
    _imageView2.layer.masksToBounds = YES;
    _imageView2.contentMode = UIViewContentModeScaleAspectFill;
    _imageView2.tag = 1;
    [self.view addSubview:_imageView2];

    _imageView3 = [[UIImageView alloc] init];
    _imageView3.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView3.layer.cornerRadius = 10;
    _imageView3.layer.masksToBounds = YES;
    _imageView3.userInteractionEnabled = YES;
    _imageView3.contentMode = UIViewContentModeScaleAspectFill;
    _imageView3.tag = 2;
    [self.view addSubview:_imageView3];
    
    _nextImageIndex = 3;
    
    [self loadInImages];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.view addCompactConstraints:@[@"imageView1.left = view.left",
                                       @"imageView1.right = view.right",
                                       @"imageView1.height = imageView1.width",
                                       @"imageView1.top = view.top",
                                       @"imageView2.left = view.left",
                                       @"imageView2.right = view.right",
                                       @"imageView2.top = imageView1.bottom+dividerConstant",
                                       @"imageView2.height = imageView2.width",
                                       @"imageView3.left = view.left",
                                       @"imageView3.right = view.right",
                                       @"imageView3.top = imageView2.bottom+dividerConstant",
                                       @"imageView3.height = imageView3.width"]
                             metrics:@{@"dividerConstant": @(((self.view.frame.size.height-(self.view.frame.size.width * 3)) / 2.0))}
                               views:@{@"imageView1": _imageView1,
                                       @"imageView2": _imageView2,
                                       @"imageView3": _imageView3,
                                       @"view": self.view}];
}

- (void)updateImageAtIndexWithNextAvailableImage:(NSInteger)index {
    
    if (index == 1) {
        [self loadInImageForIndex:_nextImageIndex-1 forImageView:_imageView1];
    } else if (index == 2) {
        [self loadInImageForIndex:_nextImageIndex-1 forImageView:_imageView2];
    } else if (index == 3) {
        [self loadInImageForIndex:_nextImageIndex-1 forImageView:_imageView3];
    }
}

#pragma mark - Loading methods for images

- (void)loadInImageForIndex:(NSInteger)index forImageView:(UIImageView *)imageView {
    
    [CPPCUtilities recentImageNumberFromRecent:index completionBlock:^(UIImage *image) {
        imageView.image = image;
        
        ////*
        //
        // We have two options for this transition between images. We can do a dissolve/fade with this code
        //
        ////*/
        
        /*
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [imageView.layer addAnimation:transition forKey:nil];
        */
        
        ////*
        //
        // Or we do a little bouncy animation as shown here
        //
        ////*/
        
        CGAffineTransform expansiveTransform = CGAffineTransformMakeScale(1.15, 1.15);
        
        [UIView transitionWithView:imageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            imageView.image = image;
                            imageView.transform = expansiveTransform;
                        } completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.30 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                imageView.transform = CGAffineTransformIdentity;
                            } completion:nil];
                            
                        }];
        
    }];
}

- (void)loadInImages {
    
    [CPPCUtilities recentImageNumberFromRecent:0 completionBlock:^(UIImage *image) {
        _imageView1.image = image;
    }];
    
    [CPPCUtilities recentImageNumberFromRecent:1 completionBlock:^(UIImage *image) {
        _imageView2.image = image;
    }];
    
    [CPPCUtilities recentImageNumberFromRecent:2 completionBlock:^(UIImage *image) {
        _imageView3.image = image;
    }];
}

#pragma mark - Gesture recognition

- (CGPoint)indexPointsForTappedImageAtPoint:(CGPoint)point {
    
    CGRect imageView1Frame = [self.view.superview convertRect:_imageView1.frame fromView:self.view];
    CGRect imageView2Frame = [self.view.superview convertRect:_imageView2.frame fromView:self.view];
    CGRect imageView3Frame = [self.view.superview convertRect:_imageView3.frame fromView:self.view];
    
    int selectedImageIndex;
    int imageViewIndex;
    
    NSLog(@"ImageView1 Tag: %ld", (long)_imageView1.tag);
    NSLog(@"ImageView2 Tag: %ld", (long)_imageView2.tag);
    NSLog(@"ImageView3 Tag: %ld", (long)_imageView3.tag);
    
    if (CGRectContainsPoint(imageView1Frame, point)) {
        selectedImageIndex = (int)_imageView1.tag;
        imageViewIndex = 1;
        _imageView1.tag = _nextImageIndex;
    } else if (CGRectContainsPoint(imageView2Frame, point)) {
        selectedImageIndex = (int)_imageView2.tag;
        imageViewIndex = 2;
        _imageView2.tag = _nextImageIndex;
    } else if (CGRectContainsPoint(imageView3Frame, point)) {
        selectedImageIndex = (int)_imageView3.tag;
        imageViewIndex = 3;
        _imageView3.tag = _nextImageIndex;
    }
    
    _nextImageIndex ++;
    
    return CGPointMake(selectedImageIndex, imageViewIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
