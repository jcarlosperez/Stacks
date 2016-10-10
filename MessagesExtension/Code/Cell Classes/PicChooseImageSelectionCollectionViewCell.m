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
        
        self.layer.borderWidth = 2.5;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        _selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add"]];
        _selectedImageView.frame = self.contentView.bounds;
        _selectedImageView.center = self.contentView.center;
        [_selectedImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_selectedImageView setClipsToBounds:YES];
        [self.contentView addSubview:_selectedImageView];
        
        
    }
    
    return self;
}

@end
