//
//  DDOpenALAudioPlayer.h
//  Runner
//
//  Created by hao ke on 2021/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDOpenALAudioPlayer : NSObject





+(id)sharePalyer;

/**
 *  播放
 *
 *  @param data       数据
 *  @param dataSize   长度
 *  @param samplerate 采样率
 *  @param channels   通道
 *  @param bit        位数
 */
-(void)openAudioFromQueue:(uint8_t *)data dataSize:(size_t)dataSize samplerate:(int)samplerate channels:(int)channels bit:(int)bit;

/**
 *  停止播放
 */
-(void)stopSound;

@end

NS_ASSUME_NONNULL_END
