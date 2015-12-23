//
//  XMRecordPlay.h
//  XMAudioSynthesis
//
//  Created by mifit on 15/6/25.
//  Copyright (c) 2015年 mi. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 */

@interface VVERecordPlay : NSObject
/**
 *  开始录音
 *  存储默认路径
 *  @param  rate        录音频率，小于等于0，则内定44110
 */
- (void)beginRecorRate:(float)rate;


/**
 *  开始录音
 *
 *  @param  filePath    录音存放完整路径
 *  @param  rate        录音频率，小于等于0，则内定44110
 */
- (void)beginRecord:(NSString *)filePath rate:(float)rate;

/**
 *  停止录音
 */
- (void)endRecord;

/**
 *  是否在录音
 *  @Param  返回BOOL值     YES，在录音；NO不在录音
 */
- (BOOL)isRecorded;

/**
 *  开始播放录音（路径：默认or指定）
 */
- (void)play;

/**
 *  开始播放音频
 */
- (void)play:(NSString *)filePath;

/**
 *  停止播放录音 or 停止播放音频
 */
- (void)stopPlay;
@end
