//
//  PicChooseImageSelectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "PicChooseImageSelectionView.h"
#import "PicChooseImageSelectionCollectionViewCell.h"

static NSString *const kPCImageSelectionCell = @"CPSSFeaturedPlaylistCell";

@interface PicChooseImageSelectionView () {
    NSMutableArray *_imageAssets;
    UICollectionViewFlowLayout *_flowLayout;
}

@end

@implementation PicChooseImageSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]) {
        
        _imageAssets = [NSMutableArray new];
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(75, 75);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 10;
        _flowLayout.minimumLineSpacing = 10;
        
        _imageSelectionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _imageSelectionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageSelectionCollectionView.backgroundColor = [UIColor clearColor];
        _imageSelectionCollectionView.delegate = self;
        _imageSelectionCollectionView.dataSource = self;
        _imageSelectionCollectionView.scrollEnabled = YES;
        _imageSelectionCollectionView.pagingEnabled = YES;
        _imageSelectionCollectionView.showsHorizontalScrollIndicator = NO;
        [_imageSelectionCollectionView registerClass:[PicChooseImageSelectionCollectionViewCell class] forCellWithReuseIdentifier:kPCImageSelectionCell];
        [self addSubview:_imageSelectionCollectionView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageSelectionCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
    
    return self;
    
}

- (void)updateViewWithImageAtPath:(NSString *)filePath {
    
    NSLog(@"updateViewWithImageAtPath: %@", filePath);
    [_imageAssets addObject:filePath];
    [_imageSelectionCollectionView reloadData];
}
#pragma mark - Collection View Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PicChooseImageSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCImageSelectionCell forIndexPath:indexPath];
    
    // If we're on the cell to be the "New Image" cell
    if(_imageAssets.count == 0) {
        cell.selectedImageView.image = [UIImage imageNamed:@"newImageSelection"];
    } else {
        if(indexPath.row > _imageAssets.count - 1) {
            cell.selectedImageView.image = [UIImage imageNamed:@"newImageSelection"];
        } else {
            
            NSLog(@"Shoud show user image");
            
            UIImage *userImage = [UIImage imageWithContentsOfFile:_imageAssets[indexPath.row]];
            
            NSLog(@"User image: %@", userImage);
            cell.selectedImageView.image = userImage;
        }
    }
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    //Calculate space required and add appropriate inset spacing to center the cells
    NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
    if( cellCount >0 )
    {
        CGFloat cellWidth = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.width+((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing;
        CGFloat totalCellWidth = cellWidth*cellCount;
        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;
        if( totalCellWidth<contentWidth )
        {
            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
            return UIEdgeInsetsMake(0, padding, 0, padding);
        }
    }
    return UIEdgeInsetsZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    // Count the image assets and add 1 for the "New Image" cell
    return _imageAssets.count + 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //CGFloat pageWidth = scrollView.frame.size.width;
    //int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

@end
