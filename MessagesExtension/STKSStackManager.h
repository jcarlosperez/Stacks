//
//  STKSStackManager.h
//  Stacks
//
//  Created by Ben Rosen on 11/3/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSNotificationName const STKSImageChangeNotificationName = @"STKSImageChangeNotificationName";

@interface STKSStackManager : NSObject

@property (nonatomic, strong) NSMutableArray *imageKeys;
@property (nonatomic, strong) NSMutableDictionary *imageRatings;

+ (instancetype)sharedInstance;

- (void)addImage:(UIImage *)image;

- (NSArray *)images;

- (UIImage *)previewImage;

- (UIImage *)previewImageLegacy;

- (UIImage *)responseImage;

- (UIImage *)responseImageLegacy;

- (void)removeAllImages;

@end
