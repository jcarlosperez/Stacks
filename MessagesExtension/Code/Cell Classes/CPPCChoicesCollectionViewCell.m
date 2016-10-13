//
//  CPPCChoicesCollectionViewCell.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesCollectionViewCell.h"
#import "CompactConstraint.h"

@implementation CPPCChoicesCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.layer.masksToBounds = YES;
        _selectedImageView.layer.cornerRadius = 10.0;
        _selectedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _selectedImageView.clipsToBounds = YES;
        _selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_selectedImageView];
        
        [self.contentView addCompactConstraints:@[@"selectedImageView.left = view.left+10",
                                                  @"selectedImageView.right = view.right-10",
                                                  @"selectedImageView.top = view.top+10",
                                                  @"selectedImageView.bottom = view.bottom-10"]
                                        metrics:nil
                                          views:@{@"selectedImageView": _selectedImageView,
                                                  @"view": self.contentView}];
    }
    return self;
}

@end
