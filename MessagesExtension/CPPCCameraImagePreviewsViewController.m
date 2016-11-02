//
//  CPPCCameraImagePreviewsViewController.m
//  PicChoose
//
//  Created by Ben Rosen on 11/1/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCCameraImagePreviewsViewController.h"
#import "CompactConstraint.h"

#import <Photos/Photos.h>

@import AssetsLibrary;

@interface CPPCCameraImagePreviewsViewController () {
    int nextPhotoIndex;
}

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
    _imageView3.userInteractionEnabled = YES;
    [self.view addSubview:_imageView3];

    _imageView1.backgroundColor = [UIColor redColor];
    _imageView2.backgroundColor = [UIColor blueColor];
    _imageView3.backgroundColor = [UIColor purpleColor];
    
    UITapGestureRecognizer *tapG1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
    tapG1.numberOfTapsRequired = 1;
    [_imageView1 addGestureRecognizer:tapG1];
    
    UITapGestureRecognizer *tapG2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
    tapG2.numberOfTapsRequired = 1;
    [_imageView2 addGestureRecognizer:tapG2];
    
    UITapGestureRecognizer *tapG3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageViewTap:)];
    tapG3.numberOfTapsRequired = 1;
    [_imageView3 addGestureRecognizer:tapG3];
    
    nextPhotoIndex = 3;
    
    [self updateImageView:_imageView1 withRecentImageAtPath:0];
    [self updateImageView:_imageView2 withRecentImageAtPath:1];
    [self updateImageView:_imageView3 withRecentImageAtPath:2];

}

- (void)handleImageViewTap:(UITapGestureRecognizer *)recognizer {
    
    [self updateImageView:(UIImageView *)recognizer.view withRecentImageAtPath:nextPhotoIndex];
    nextPhotoIndex++;
    
    NSLog(@"Something is not working right");
    
}

-(void)updateImageView:(UIImageView *)imageView withRecentImageAtPath:(int)index {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *photos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    if (photos) {
        // 500x500 is the smallet you can do without it being pixelated
        [[PHImageManager defaultManager] requestImageForAsset:[photos objectAtIndex:index] targetSize:CGSizeMake(500, 500) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            imageView.image = result;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        }];
    }
    
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
