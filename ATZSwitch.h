//
//  ATZSwitch.h
//  AppTemplatez
//
//  Created by Lucas Best on 10/7/13.
//  Copyright (c) 2013 AppTemplatez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATZSwitch : UIControl

@property (nonatomic) BOOL on;

@property (nonatomic, strong) UIColor *onTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *thumbTintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;

@end
