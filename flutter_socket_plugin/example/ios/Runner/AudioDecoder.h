//
//  AudioDecoder.h
//  Runner
//
//  Created by hao ke on 2022/1/6.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>






#import "AQPlayer.h"
NS_ASSUME_NONNULL_BEGIN

@interface AudioDecoder : NSObject
{
    
    AQPlayer    *aqPlayer;
}
+ (instancetype)shareInstance;
- (void)decodeAudioAACData:(NSData *)aacData;
@property (nonatomic) AudioConverterRef audioDecodeConverter;
@property (nonatomic, strong) dispatch_queue_t decodeQueue;
@property (nonatomic, strong) dispatch_queue_t decodeCallbackQueue;
@property (nonatomic,assign)Float64             sampleRate;
@property (nonatomic,assign)UInt32              channelCount;
@end

NS_ASSUME_NONNULL_END
