//
//  PicChooseImageSelectionCollectionViewCell.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "PicChooseImageSelectionCollectionViewCell.h"

@implementation PicChooseImageSelectionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        _selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nothing"]];
        _selectedImageView.center = self.contentView.center;
        //_selectedImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_selectedImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_selectedImageView setClipsToBounds:YES];
        //_selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        _selectedImageView.layer.minificationFilter = kCAFilterTrilinear;
        [self.contentView addSubview:_selectedImageView];
        
        //[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        //[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_selectedImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    
    return self;
}

@end
