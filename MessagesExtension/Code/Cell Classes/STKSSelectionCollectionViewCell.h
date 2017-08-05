//
//  STKSSelectionCollectionViewCell.h
//  Stacks
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STKSImageRatingView.h"

@interface STKSSelectionCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *choiceImageView;

@property (nonatomic, strong) STKSImageRatingView *ratingView;

@end
