//
//  CPPCChoicesCollectionViewCell.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesCollectionViewCell.h"

@implementation CPPCChoicesCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.frame = self.contentView.bounds;
        _selectedImageView.center = self.contentView.center;
        [_selectedImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_selectedImageView setClipsToBounds:YES];
        [self.contentView addSubview:_selectedImageView];
    }
    return self;
}

@end
