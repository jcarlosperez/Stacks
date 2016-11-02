//
//  CPPCCameraImagePreviewsViewController.m
//  PicChoose
//
//  Created by Ben Rosen on 11/1/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCCameraImagePreviewsViewController.h"
#import "CompactConstraint.h"

@interface CPPCCameraImagePreviewsViewController ()

@property (strong, nonatomic) UIImageView *imageView1, *imageView2, *imageView3;

@end

@implementation CPPCCameraImagePreviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _imageView1 = [[UIImageView alloc] init];
    _imageView1.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView1.layer.cornerRadius = 10;
    _imageView1.layer.masksToBounds = YES;
    [self.view addSubview:_imageView1];

    _imageView2 = [[UIImageView alloc] init];
    _imageView2.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView2.layer.cornerRadius = 10;
    _imageView2.layer.masksToBounds = YES;
    [self.view addSubview:_imageView2];

    _imageView3 = [[UIImageView alloc] init];
    _imageView3.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView3.layer.cornerRadius = 10;
    _imageView3.layer.masksToBounds = YES;
    [self.view addSubview:_imageView3];

    _imageView1.backgroundColor = [UIColor redColor];
    _imageView2.backgroundColor = [UIColor blueColor];
    _imageView3.backgroundColor = [UIColor purpleColor];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
