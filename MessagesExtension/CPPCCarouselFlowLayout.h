//
//  CPPCCarouselFlowLayout.h
//  SongShift
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SpacingMode) {
    FixedMode,
    OverlapMode
};

@interface CPPCCarouselFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat sideItemScale;
@property (nonatomic) CGFloat sideItemAlpha;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGFloat visibleOffset;
@property (nonatomic) SpacingMode spacingMode;

@end
