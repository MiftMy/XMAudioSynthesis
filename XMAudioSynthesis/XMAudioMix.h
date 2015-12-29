//
//  XMAudioMix.h
//  XMAudioSynthesis
//
//  Created by mifit on 15/12/17.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 合成时间有最长的那个决定，短的不会重复
@interface XMAudioMix : NSObject

/*! 
 ffdsfs
 */
@property (nonatomic,assign) BOOL f;


+ (OSStatus)mixAudio:(NSString *)audioPath1
            andAudio:(NSString *)audioPath2
              toFile:(NSString *)outputPath
  preferedSampleRate:(float)sampleRate;
@end
