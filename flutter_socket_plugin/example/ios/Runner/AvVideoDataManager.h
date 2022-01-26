//
//  AvVideoDataManager.h
//  Runner
//
//  Created by hao ke on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import "avformat.h"
#import "avcodec.h"
#import "avio.h"
#import "swscale.h"
#import "avutil.h"
#import <AvFoundation/AvFoundation.h>

#import "PCMPlayer.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum:NSUInteger{
    AAH264VideoFormat,
    AAH265VideoFormat
} AAVideoFormat;
typedef struct AAVideoInfo{
    uint8_t                 *data;
    int                     dataSize;
    uint8_t                 *extraData;
    int                     extraDataSize;
    Float64                 pts;
    Float64                 time_base;
    int                     videoRotate;
    int                     fps;
    CMSampleTimingInfo      timingInfo;
    AAVideoFormat    videoFormat;
} AAVideoInfo;
@interface AvVideoDataManager : NSObject
/// 单列初始化
+ (instancetype)shareInstance;

/// 打开视频地址或者流
/// @param videoPath 视频地址
- (void)openVideo:(NSString*)videoPath;
/// ffmpeg formatContext
@property (nonatomic,assign)AVFormatContext *avformatContext;
///  avstream video steam index
@property (nonatomic,assign)int aa_videoStreamIndex;
///  avstream audio steam index
@property (nonatomic,assign)int aa_audioStreamIndex;
/// 解析视频
/// @param handler 解析视频回调
- (void)strartParseWithCompletionHandler:(void(^)(BOOL isVideoFrame,BOOL isFinish,AAVideoInfo *videoInfo))handler;
/// 是否停止解析
@property (nonatomic,assign)BOOL isStopParse;
/// ffmpeg avbitstreamfiltercontext
@property (nonatomic,assign)AVBitStreamFilterContext *avbitstreamFilterContext;
@end

NS_ASSUME_NONNULL_END
