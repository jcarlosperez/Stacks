//
//  CPPCStackManager.m
//  PicChoose
//
//  Created by Ben Rosen on 11/3/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCStackManager.h"

@interface CPPCStackManager ()

@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation CPPCStackManager

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)addImage:(UIImage *)image {
    [_images addObject:image];
}

@end
