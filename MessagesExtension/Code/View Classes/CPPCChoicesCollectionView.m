//
//  CPPCChoicesCollectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesCollectionView.h"
#import "CPPCChoicesCollectionViewCell.h"
#import "CPPCStackManager.h"

static NSString *const kPCImageSelectionCell = @"CPSSFeaturedPlaylistCell";

@implementation CPPCChoicesCollectionView

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = -16;
    flowLayout.minimumLineSpacing = 10;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[CPPCChoicesCollectionViewCell class] forCellWithReuseIdentifier:kPCImageSelectionCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateCellWithActivityIndicators:(BOOL)indicators {
    
    NSLog(@"Visible Cells: %@", self.visibleCells);
    for(CPPCChoicesCollectionViewCell *cell in self.visibleCells) {
        
        if(indicators) {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.center = cell.center;
            activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:activityIndicator];
            
            [activityIndicator startAnimating];
            
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:20]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:20]];
            
        } else {
            
            for(UIView *subview in cell.contentView.subviews) {
                if([subview isKindOfClass:[UIActivityIndicatorView class]]) {
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPCChoicesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCImageSelectionCell forIndexPath:indexPath];
    cell.selectedImageView.image = [CPPCStackManager sharedInstance].images[indexPath.row];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CPPCStackManager sharedInstance].images.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.height/1.06, self.frame.size.height/1.06);
}

@end
