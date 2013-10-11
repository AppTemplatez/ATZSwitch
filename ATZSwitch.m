//
//  ATZSwitch.m
//  AppTemplatez
//
//  Created by Lucas Best on 10/7/13.
//  Copyright (c) 2013 AppTemplatez. All rights reserved.
//

#import "ATZSwitch.h"

@class ATZSwitchThumb;

//Track Colors
#define kDefaultGreenOnColor     [UIColor colorWithRed:83/255.0 green: 214/255.0 blue: 105/255.0 alpha: 1]
#define kThumbOffset 3.0
#define kThumbBorderWidth 1.5
#define kTouchDownThumbScaleFactor 1.25
#define kThumbDeactivateBounceFactor .25


@protocol ATZSwitchThumbDelegate <NSObject>

-(void) thumbBeganPress:(ATZSwitchThumb*) thumb;
-(void) thumbTouch:(UITouch*) touch moved:(ATZSwitchThumb*) thumb;
-(void) thumbEndedPress:(ATZSwitchThumb*) thumb;

-(void) thumbOnChanged:(ATZSwitchThumb*) thumb;

@end

@interface ATZSwitchThumb : UIView{
    float pressedWidth;
    
    BOOL shouldSwitch;
}

@property (nonatomic) BOOL on;
@property (nonatomic, assign) id<ATZSwitchThumbDelegate> thumbDelegate;

-(void) setSizeFromTouch;

@end

@implementation ATZSwitchThumb

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        pressedWidth = self.frame.size.width * kTouchDownThumbScaleFactor;
        shouldSwitch = TRUE;
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UIView animateWithDuration:.2 animations:^{
        [self setSizeFromTouch];
    }];
    
    [self.thumbDelegate thumbBeganPress:self];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.thumbDelegate thumbTouch:[touches anyObject] moved:self];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (shouldSwitch){
        _on = !_on;
        
        [self.thumbDelegate thumbOnChanged:self];
    }
    
    [self.thumbDelegate thumbEndedPress:self];
    
    shouldSwitch = TRUE;
}

-(void) setSizeFromTouch{
    if (self.on) {
        float x = self.superview.frame.size.width - pressedWidth - (kThumbOffset / 2.0);
        
        self.frame = CGRectMake(x,
                                kThumbOffset / 2.0,
                                pressedWidth,
                                self.frame.size.height);
    }
    else{
        self.frame = CGRectMake(kThumbOffset / 2.0,
                                kThumbOffset / 2.0,
                                pressedWidth,
                                self.frame.size.height);
    }
}

-(void) setOn:(BOOL)on{
    BOOL oldOn = _on;
    
    _on = on;
    
    shouldSwitch = FALSE;
    
    [UIView animateWithDuration:.2 animations:^{
        [self setSizeFromTouch];
    }];
    
    if (oldOn != on){
        [self.thumbDelegate thumbOnChanged:self];
    }
}

@end

@interface ATZSwitch ()<ATZSwitchThumbDelegate>{
    UIView* track;
    ATZSwitchThumb* switchThumb;
}

-(void) privateATZSwitchInit;

-(void) animateTrackBorderColor:(UIColor*) color withDuration:(float) duration;
-(void) animateTrackBorderWidth:(float) width withDuration:(float) duration;

@end

@implementation ATZSwitch

-(void) privateATZSwitchInit{
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    
    track = [[UIView alloc] initWithFrame:self.bounds];
    track.backgroundColor = [UIColor clearColor];
    track.layer.cornerRadius = self.frame.size.height / 2.0;
    track.layer.borderWidth = kThumbBorderWidth;
    
    [self addSubview:track];
    
    
    float thumbSize = self.frame.size.height - kThumbOffset;
    
    switchThumb = [[ATZSwitchThumb alloc] initWithFrame:CGRectMake(kThumbOffset / 2.0, kThumbOffset / 2.0, thumbSize, thumbSize)];
    switchThumb.thumbDelegate = self;
    
    switchThumb.layer.cornerRadius = switchThumb.frame.size.height / 2.0;
    [switchThumb.layer setShadowColor: [[UIColor blackColor] CGColor]];
    [switchThumb.layer setShadowOffset: CGSizeMake(-.5, 1.0)];
    [switchThumb.layer setShadowOpacity: 0.30f];
    [switchThumb.layer setShadowRadius:.6];
    
    [self addSubview:switchThumb];
    
    self.onTintColor = kDefaultGreenOnColor;
    self.thumbTintColor = [UIColor whiteColor];
    self.borderColor = [UIColor colorWithWhite:.9 alpha:1.0];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self privateATZSwitchInit];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self privateATZSwitchInit];
    }
    return self;
}

#pragma mark ATZSwitchThumb delegate methods

-(void) thumbBeganPress:(ATZSwitchThumb *)thumb{
    if (!thumb.on){
        [self animateTrackBorderWidth:self.frame.size.height * .6 withDuration:.35];
        [self animateTrackBorderColor:self.borderColor withDuration:.35];
    }
}

-(void) thumbTouch:(UITouch *)touch moved:(ATZSwitchThumb *)thumb{
    CGPoint touchLoc = [touch locationInView:self];
    if (thumb.on){
        if (touchLoc.x < 0){
            thumb.on = FALSE;
            
            [self animateTrackBorderColor:self.borderColor withDuration:.1];
        }
    }
    else{
        if (touchLoc.x > self.frame.size.width / 2.0){
            thumb.on = TRUE;
            
            [self animateTrackBorderColor:self.onTintColor withDuration:.1];
        }
    }
}

-(void) thumbEndedPress:(ATZSwitchThumb *)thumb{
    float thumbSize = self.frame.size.height - kThumbOffset;
    
    [UIView animateWithDuration:.25 animations:^{
        if (thumb.on){
            switchThumb.frame = CGRectMake(self.frame.size.width - thumbSize - (kThumbOffset / 2.0) + kTouchDownThumbScaleFactor, kThumbOffset / 2.0, thumbSize, thumbSize);
        }
        else{
            switchThumb.frame = CGRectMake(kThumbOffset / 2.0 - kTouchDownThumbScaleFactor, kThumbOffset / 2.0, thumbSize, thumbSize);
        }
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.25 animations:^{
            if (thumb.on){
                switchThumb.center = CGPointMake(switchThumb.center.x - kTouchDownThumbScaleFactor, switchThumb.center.y);
            }
            else{
                switchThumb.center = CGPointMake(switchThumb.center.x + kTouchDownThumbScaleFactor, switchThumb.center.y);

            }
        }];
    }];
    
    if (thumb.on){
        CABasicAnimation* colorAnimation = (CABasicAnimation*)[track.layer animationForKey:@"borderColor"];
        
        CABasicAnimation* newColorAnimation = [colorAnimation copy];
        newColorAnimation.toValue = (id)self.onTintColor.CGColor;
        
        [track.layer removeAnimationForKey:@"borderColor"];
        [track.layer addAnimation:newColorAnimation forKey:@"borderColor"];
        
        track.layer.borderColor = self.onTintColor.CGColor;
    }
    else{
        [self animateTrackBorderWidth:kThumbBorderWidth withDuration:.3];
        [self animateTrackBorderColor:self.borderColor withDuration:.25];
    }
}

-(void) thumbOnChanged:(ATZSwitchThumb *)thumb{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark property setters and getters

-(void) setOn:(BOOL)on{
    switchThumb.on = on;
}

-(BOOL) on{
    return switchThumb.on;
}

-(void) setThumbTintColor:(UIColor *)thumbTintColor{
    if (thumbTintColor){
        _thumbTintColor = thumbTintColor;
        switchThumb.backgroundColor = thumbTintColor;
    }
}

-(void) setBorderColor:(UIColor *)borderColor{
    if (borderColor){
        _borderColor = borderColor;
        
        track.layer.borderColor = borderColor.CGColor;
    }
}

#pragma mark private methods

-(void) animateTrackBorderColor:(UIColor *)color withDuration:(float)duration{
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation.fromValue = (id)track.layer.borderColor;
    colorAnimation.toValue = (id)color.CGColor;
    [colorAnimation setDuration:duration];
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [track.layer addAnimation:colorAnimation forKey:@"borderColor"];
    track.layer.borderColor = color.CGColor;
}

-(void) animateTrackBorderWidth:(float)width withDuration:(float)duration{
    CABasicAnimation *widthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    [widthAnimation setFromValue:[NSNumber numberWithFloat:track.layer.borderWidth]];
    [widthAnimation setToValue:[NSNumber numberWithFloat:width]];
    [widthAnimation setDuration:duration];
    widthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [track.layer addAnimation:widthAnimation forKey:@"borderWidth"];
    track.layer.borderWidth = width;
}

@end
