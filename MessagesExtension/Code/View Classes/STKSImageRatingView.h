//
//  STKSImageRatingView.h
//  Stacks
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STKSImageRatingDelegate;

@interface STKSImageRatingView : UIView {
    CGPoint _origin;
}

@property(nonatomic, assign) NSInteger rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *emptyRatingImage;
@property(nonatomic, retain) UIImage *fullRatingImage;
@property(nonatomic, assign) NSObject<STKSImageRatingDelegate> *delegate;

- (STKSImageRatingView *)initWithFrame:(CGRect)frame;
- (STKSImageRatingView *)initWithFrame:(CGRect)rect fullImage:(UIImage *)fullImage emptyImage:(UIImage *)emptyImage;

@end

@protocol STKSImageRatingDelegate

- (void)rateView:(STKSImageRatingView *)rateView changedToNewRate:(NSNumber *)rate;

@end
