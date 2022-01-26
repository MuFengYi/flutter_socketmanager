//
//  VideoDecoder.h
//  Runner
//
//  Created by hao ke on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "avformat.h"
#import "avcodec.h"
#import "avio.h"
#import "swscale.h"
#import "avutil.h"
#import <AvFoundation/AvFoundation.h>
#import "AvVideoDataManager.h"
#import <pthread.h>
NS_ASSUME_NONNULL_BEGIN


@protocol VideoDecoderDelegate <NSObject>
- (void)getVideoDecodeDataCallback:(CMSampleBufferRef)samleBufferRef isFirstFrame:(BOOL)isFirstFrame;
@end
@interface VideoDecoder : NSObject
- (void)startDecodeVideoData:(AAVideoInfo*)videoInfo;
@property (weak,nonatomic)id <VideoDecoderDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
