//
//  AAQueuePlayer.m
//  Runner
//
//  Created by hao ke on 2022/1/24.
//

#import "AAQueuePlayer.h"

@implementation AAQueuePlayer
AudioQueueBufferRef pBuffer[QUEUE_BUFFSIZE];




BOOL audioQueueUsed[QUEUE_BUFFSIZE];

+ (instancetype)shareInstance
{
    static AAQueuePlayer   *instance;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        instance   =   [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self    =   [super init];
    if (self) {
        AudioStreamBasicDescription ASBD;
        ASBD.mBitsPerChannel    =   16; //signed16-bit
        ASBD.mSampleRate    =   48000; //采样率
        ASBD.mFormatID  =   kAudioFormatLinearPCM;//pcm
        ASBD.mFormatFlags   =   kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;//保存音频数据格式说明
        ASBD.mChannelsPerFrame  =   1;//1 单声道 2 双声道
        ASBD.mFramesPerPacket   =   1;//每个数据包有多少针数
        ASBD.mBytesPerFrame =   (ASBD.mBitsPerChannel/8)/(ASBD.mChannelsPerFrame);
        ASBD.mBytesPerPacket    =   ASBD.mBytesPerFrame*ASBD.mFramesPerPacket;//每个数据包的bytes总数，每帧的bytes数*每个数据包的帧数
        OSStatus  status  =  AudioQueueNewOutput(&ASBD, OutputCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &playQueue);
        if (status!=noErr) {
            NSLog(@"报错了哦哦哦哦哦哦");
        }
        OSStatus status1 = AudioQueueAddPropertyListener(playQueue, kAudioQueueProperty_IsRunning, ListenerCallback, (__bridge void * _Nullable)(self));
        
        
        OSStatus status2 = AudioQueueSetParameter(playQueue, kAudioQueueParam_Volume, 1.0);
        for (int i=0; i<QUEUE_BUFFSIZE; i++) {
            AudioQueueAllocateBuffer(playQueue, SIZEFRAME, pBuffer+i);
        }
    }
    return self;
}

- (void)playData:(NSData *)data
{
    AudioQueueBufferRef inBuffer = NULL;
    for (int i=0; i<QUEUE_BUFFSIZE; i++) {
        
        if (audioQueueUsed[i]) {
            continue;
        }

        audioQueueUsed[i]    =   YES;
        inBuffer    =   pBuffer[i];
        memcpy(inBuffer->mAudioData, data.bytes, data.length);
        inBuffer->mAudioDataByteSize = (UInt32)data.length;
        AudioQueueEnqueueBuffer(playQueue, inBuffer, 0, nil);
    }
    OSStatus status  = AudioQueueStart(playQueue, NULL);
    
    
    if (status!=noErr) {
        NSLog(@"播放出错");
    }
}

static void OutputCallback(void * __nullable       inUserData,
                           AudioQueueRef           inAQ,
                           AudioQueueBufferRef     inBuffer)
{
    AAQueuePlayer  *player =   (__bridge AAQueuePlayer *)(inUserData);
    for (int i=0; i<QUEUE_BUFFSIZE; i++) {
        if (inBuffer==pBuffer[i]) {
            audioQueueUsed[i]  =   NO;
            NSLog(@"buff(%d) 使用完成",i);
            break;
        }
    }
    
}



static void ListenerCallback(void * __nullable       inUserData,
                             AudioQueueRef           inAQ,
                             AudioQueuePropertyID    inID)
{
    
    
}



@end
