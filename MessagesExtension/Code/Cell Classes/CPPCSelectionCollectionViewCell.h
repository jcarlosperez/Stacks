//
//  CPPCSelectionCollectionViewCell.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPPCImageRatingView.h"

@interface CPPCSelectionCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *choiceImageView;

@property (nonatomic, strong) CPPCImageRatingView *ratingView;

@end
