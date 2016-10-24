//
//  CPPCSelectionCollectionViewCell.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCSelectionCollectionViewCell.h"
#import "CompactConstraint.h"

@implementation CPPCSelectionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _choiceImageView = [[UIImageView alloc] init];
        _choiceImageView.backgroundColor = [UIColor blueColor];
        _choiceImageView.image = [UIImage imageNamed:@"library"];
        _choiceImageView.layer.masksToBounds = YES;
        _choiceImageView.layer.cornerRadius = 10.0;
        _choiceImageView.contentMode = UIViewContentModeScaleAspectFill;
        _choiceImageView.clipsToBounds = YES;
        _choiceImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_choiceImageView];
        
        [self.contentView addCompactConstraints:@[@"choiceImageView.height = view.width - 20",
                                                  @"choiceImageView.width = view.width - 20",
                                                  @"choiceImageView.centerX = view.centerX",
                                                  @"choiceImageView.centerY = view.centerY"
                                                  ]
                                        metrics:nil
                                          views:@{@"choiceImageView": _choiceImageView,
                                                  @"view": self.contentView}];
    }
    return self;
}

@end
