//
//  STKSCarouselFlowLayout.h
//  SongShift
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SpacingMode) {
    FixedMode,
    OverlapMode
};

@interface STKSCarouselFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat sideItemScale;
@property (nonatomic) CGFloat sideItemAlpha;
@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGFloat visibleOffset;
@property (nonatomic) SpacingMode spacingMode;

@end
