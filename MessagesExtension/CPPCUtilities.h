//
//  CPPCUtilities.h
//  PicChoose
//
//  Created by Ben Rosen on 10/11/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPPCUtilities : NSObject

+ (NSURL *)URLFromQuestion:(NSString *)question imageNames:(NSArray<NSString *>*)imageNames;

@end
