//
//  STKSStackManager.m
//  Stacks
//
//  Created by Ben Rosen on 11/3/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSStackManager.h"
#import "UIImage+Optimizations.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface STKSStackManager ()

@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation STKSStackManager

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        _images = [NSMutableArray array];
        _imageKeys = [NSMutableArray array];
        _imageRatings = [NSMutableDictionary dictionary];
        NSLog(@"ok they are ok here %@", _imageRatings);
    }
    return self;
}

- (void)addImage:(UIImage *)image {
    [_images addObject:image];
    [self modificationMade];
}

- (NSArray *)image {
    return [NSArray arrayWithArray:_images];
}

- (UIImage *)previewImageLegacy {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    for (int i = 0; i < [_images count]; i++) {
        UIImage *image = _images[i];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(2, 2);
        containerView.layer.shadowOpacity = 0.8;
        containerView.layer.shadowRadius = 10;
        
        UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        imageLayer.contentMode = UIViewContentModeScaleAspectFill;
        imageLayer.image = image;
        imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
        imageLayer.layer.borderWidth = 6;
        imageLayer.layer.masksToBounds = YES;
        imageLayer.layer.shouldRasterize = YES;
        imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [containerView addSubview:imageLayer];
        [backgroundView addSubview:containerView];
        
        if (i == 0) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));
        } else if (i == 1) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
        }
        
    }
    return [UIImage imageFromView:backgroundView];
}

- (UIImage *)previewImage {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 614, 200)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    
    for (int i = 0; i < [_images count]; i++) {
        UIImage *image = _images[i];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(30, 40, 120, 120)];
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(2, 2);
        containerView.layer.shadowOpacity = 0.5;
        containerView.layer.shadowRadius = 6;
        
        UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        imageLayer.contentMode = UIViewContentModeScaleAspectFill;
        imageLayer.image = image;
        imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
        imageLayer.layer.borderWidth = 6;
        imageLayer.layer.masksToBounds = YES;
        imageLayer.layer.shouldRasterize = YES;
        imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [containerView addSubview:imageLayer];
        [backgroundView addSubview:containerView];
        
        if (i == 0) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));
        } else if (i == 1) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
        }
    }
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 54, 300, 26)];
    questionLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    questionLabel.text = @"Which is your favorite?";
    questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:questionLabel];
    
    UILabel *imageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 90, 300, 26)];
    imageCountLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];
    imageCountLabel.text = [NSString stringWithFormat:@"%lu Images", (unsigned long)_images.count];
    imageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:imageCountLabel];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 126, 300, 26)];
    logoLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
    logoLabel.text = @"Stacks";
    logoLabel.textColor = [UIColor lightGrayColor];
    logoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:logoLabel];
    
    return [UIImage imageFromView:backgroundView];
}

- (UIImage *)responseImage {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 614, 200)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    
    for (int i = 0; i < 3; i++) {
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(30, 40, 120, 120)];
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(2, 2);
        containerView.layer.shadowOpacity = 0.5;
        containerView.layer.shadowRadius = 6;
        
        UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        imageLayer.contentMode = UIViewContentModeScaleAspectFill;
        imageLayer.image = [UIImage imageNamed:@"responseImage"];
        imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
        imageLayer.layer.borderWidth = 6;
        imageLayer.layer.masksToBounds = YES;
        imageLayer.layer.shouldRasterize = YES;
        imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [containerView addSubview:imageLayer];
        [backgroundView addSubview:containerView];
        
        if (i == 0) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));
        } else if (i == 1) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
        }
    }
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 54, 300, 26)];
    questionLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    questionLabel.text = @"I've rated my favorite";
    questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:questionLabel];
    
    UILabel *imageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 90, 300, 26)];
    imageCountLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];
    imageCountLabel.text = @"Tap to view response";
    imageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:imageCountLabel];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 126, 300, 26)];
    logoLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
    logoLabel.text = @"Stacks";
    logoLabel.textColor = [UIColor lightGrayColor];
    logoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [backgroundView addSubview:logoLabel];
    
    return [UIImage imageFromView:backgroundView];
}

- (UIImage *)responseImageLegacy {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    backgroundView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    for (int i = 0; i < 3; i++) {
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(2, 2);
        containerView.layer.shadowOpacity = 0.8;
        containerView.layer.shadowRadius = 10;
        
        UIImageView *imageLayer = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
        imageLayer.contentMode = UIViewContentModeScaleAspectFill;
        imageLayer.image = [UIImage imageNamed:@"responseImage"];
        imageLayer.layer.borderColor = [UIColor whiteColor].CGColor;
        imageLayer.layer.borderWidth = 6;
        imageLayer.layer.masksToBounds = YES;
        imageLayer.layer.shouldRasterize = YES;
        imageLayer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [containerView addSubview:imageLayer];
        [backgroundView addSubview:containerView];
        
        if (i == 0) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5));
        } else if (i == 1) {
            containerView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5));
        }
        
    }
    
    return [UIImage imageFromView:backgroundView];
}

- (void)removeAllImages {
    [_images removeAllObjects];
    [self modificationMade];
}

- (void)modificationMade {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:STKSImageChangeNotificationName object:nil]];
}

@end
