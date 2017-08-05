//
//  STKSSelectionCollectionViewCell.m
//  Stacks
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSSelectionCollectionViewCell.h"
#import "CompactConstraint.h"

@implementation STKSSelectionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _choiceImageView = [[UIImageView alloc] init];
        _choiceImageView.backgroundColor = [UIColor clearColor];
        _choiceImageView.image = [UIImage imageNamed:@"library"];
        _choiceImageView.layer.masksToBounds = YES;
        _choiceImageView.layer.cornerRadius = 10.0;
        _choiceImageView.contentMode = UIViewContentModeScaleAspectFill;
        _choiceImageView.clipsToBounds = YES;
        _choiceImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_choiceImageView];
        
        _ratingView = [[STKSImageRatingView alloc] initWithFrame:CGRectZero];
        _ratingView.editable = YES;
        _ratingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_ratingView];
        
        [self.contentView addCompactConstraints:@[@"choiceImageView.height = view.width - 20",
                                                  @"choiceImageView.width = view.width - 20",
                                                  @"choiceImageView.centerX = view.centerX",
                                                  @"choiceImageView.centerY = view.centerY-10",
                                                  @"ratingView.top = choiceImageView.bottom+5",
                                                  @"ratingView.right = choiceImageView.right-5",
                                                  @"ratingView.height = 50",
                                                  @"ratingView.width = choiceImageView.width"
                                                  ]
                                        metrics:nil
                                          views:@{@"choiceImageView": _choiceImageView,
                                                  @"ratingView" : _ratingView,
                                                  @"view": self.contentView}];
    }
    return self;
}

@end
