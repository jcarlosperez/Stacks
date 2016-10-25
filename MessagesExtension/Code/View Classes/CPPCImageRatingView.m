//
//  CPPCImageRatingView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCImageRatingView.h"

static NSString *DefaultFullRatingImage = @"fullHeart";
static NSString *DefaultEmptyRatingImage = @"emptyHeart";

@interface CPPCImageRatingView ()

- (void)commonSetup;

@end

@implementation CPPCImageRatingView

- (CPPCImageRatingView *)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame fullImage:[UIImage imageNamed:DefaultFullRatingImage] emptyImage:[UIImage imageNamed:DefaultEmptyRatingImage]];
}

- (CPPCImageRatingView *)initWithFrame:(CGRect)frame fullImage:(UIImage *)fullImage emptyImage:(UIImage *)emptyImage {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _fullRatingImage = fullImage;
        _emptyRatingImage = emptyImage;
        
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    
    _padding = 4;
    _ratingLimit = 4;
    self.editable = NO;
}

- (void)drawRect:(CGRect)rect {
    
    _origin = CGPointMake((self.bounds.size.width - _ratingLimit * _fullRatingImage.size.width - (_ratingLimit - 1) * _padding)/2, 0);
    
    float x = _origin.x;
    for(int i = 0; i < _ratingLimit; i++) {
        [_emptyRatingImage drawAtPoint:CGPointMake(x, _origin.y)];
        x += _fullRatingImage.size.width + _padding;
    }
    
    
    float floor = floorf(_rate);
    x = _origin.x;
    for (int i = 0; i < floor; i++) {
        [_fullRatingImage drawAtPoint:CGPointMake(x, _origin.y)];
        x += _fullRatingImage.size.width + _padding;
    }
    
    if (_ratingLimit - floor > 0.01) {
        UIRectClip(CGRectMake(x, _origin.y, _fullRatingImage.size.width * (_rate - floor), _fullRatingImage.size.height));
        [_fullRatingImage drawAtPoint:CGPointMake(x, _origin.y)];
    }
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    [self setNeedsDisplay];
    [self notifyDelegate];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.userInteractionEnabled = _editable;
}

- (void)setFullRatingImage:(UIImage *)fullRatingImage {
    if (fullRatingImage != _fullRatingImage) {
        _fullRatingImage = fullRatingImage;
        [self setNeedsDisplay];
    }
}

- (void)setEmptyRatingImage:(UIImage *)emptyRatingImage
{
    if (emptyRatingImage != _emptyRatingImage) {
        _emptyRatingImage = emptyRatingImage;
        [self setNeedsDisplay];
    }
}

- (void)handleTouchAtLocation:(CGPoint)location {
    for(int i = _ratingLimit - 1; i > -1; i--) {
        if (location.x > _origin.x + i * (_fullRatingImage.size.width + _padding) - _padding / 2.) {
            self.rate = i + 1;
            return;
        }
    }
    self.rate = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rateView:changedToNewRate:)]) {
        [self.delegate performSelector:@selector(rateView:changedToNewRate:)
                            withObject:self withObject:[NSNumber numberWithFloat:self.rate]];
    }
}

@end
