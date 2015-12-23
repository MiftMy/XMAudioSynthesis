//
//  MLButton.h
//  GCDTemp
//
//  Created by molon on 5/21/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MLButtonDirection){
    MLButtonDirectionNo = -1,
    MLButtonDirectionLeft,
    MLButtonDirectionTop,
    MLButtonDirectionRight,
    MLButtonDirectionBottom
};
@protocol MLButtonDelegate <NSObject>

- (void)buttonDidPress:(MLButtonDirection)dir;

@end

@interface MLButton : UIButton
/**
 *  忽略点击到了透明区域
 */
@property (nonatomic, assign) BOOL isIgnoreTouchInTransparentPoint;
@property (nonatomic,assign) id<MLButtonDelegate> delegate;

@end
