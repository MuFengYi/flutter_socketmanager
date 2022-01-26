//
//  AudioQueuePlay.m
//  Runner
//
//  Created by hao ke on 2021/12/31.
//

#import "AudioQueuePlay.h"
#define QUEUE_BUFFER_SIZE 5 //队列缓冲个数
#define EVERY_READ_LENGTH 370 //每次从文件读取的长度
#define MIN_SIZE_PER_FRAME 2000 //每侦最小数据长度

@interface AudioQueuePlay ()
{
    AudioStreamBasicDescription audioDescription;///音频参数
    AudioQueueRef audioQueue;//音频播放队列
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];//音频缓存
    NSLock *synlock ;//同步控制
    Byte *pcmDataBuffer;//pcm的读文件数据区
    NSInputStream *inputSteam;//用于读pcm文件
}
@end
@implementation AudioQueuePlay





+ (instancetype)shareInstance
{
    static id  _instance;
    static  dispatch_once_t _oncetoken;
    dispatch_once(&_oncetoken, ^{
        _instance   =   [[self alloc] init];
    });
    return _instance;
}

void AudioPlayerAQInputCallback(void *input, AudioQueueRef outQ, AudioQueueBufferRef outQB)
{
   
    
    
    
    
    
    
    
    
    
    
    
    
//    NSLog(@"AudioPlayerAQInputCallback");
//    ViewController *mainviewcontroller = (__bridge ViewController *)input;
//    [mainviewcontroller checkUsedQueueBuffer:outQB];
//    [mainviewcontroller readPCMAndPlay:outQ buffer:outQB];
}

-(void)startPlay:(NSData *)data
{
    [self initFile];
    
    
    
    
    
    
    
    
    Byte *byteData = (Byte *)[data bytes];
    pcmDataBuffer   =   byteData;
    [self initAudio];
    AudioQueueStart(audioQueue, NULL);
    for(int i=0;i<QUEUE_BUFFER_SIZE;i++)
    {
        [self readPCMAndPlay:audioQueue buffer:audioQueueBuffers[i]];
    }
    /*
     audioQueue使用的是驱动回调方式，即通过AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);传入一个buff去播放，播放完buffer区后通过回调通知用户,
     用户得到通知后再重新初始化buff去播放，周而复始,当然，可以使用多个buff提高效率(测试发现使用单个buff会小卡)
     */
    
}


- (void)initFile
{
//    NSString *filepath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"abc.pcm"];
//    inputSteam = [[NSInputStream alloc] initWithFileAtPath:filepath];
//    [inputSteam open];
    pcmDataBuffer = malloc(EVERY_READ_LENGTH);
    
    
    
    
    
    
    
    
//    synlock = [[NSLock alloc] init];
}

-(void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB
{
    
//    [synlock lock];
//    size_t readLength = [inputSteam read:pcmDataBuffer maxLength:EVERY_READ_LENGTH];
//    NSLog(@"read raw data size = %zi",readLength);
//    if (readLength == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"文件读取完成");
//        });
//        return ;
//    }
    outQB->mAudioDataByteSize = (UInt32)EVERY_READ_LENGTH;
    memcpy((Byte *)outQB->mAudioData, pcmDataBuffer, EVERY_READ_LENGTH);
    /*
     将创建的buffer区添加到audioqueue里播放
     AudioQueueBufferRef用来缓存待播放的数据区，AudioQueueBufferRef有两个比较重要的参数，AudioQueueBufferRef->mAudioDataByteSize用来指示数据区大小，AudioQueueBufferRef->mAudioData用来保存数据区
     */
    AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);
//    [synlock unlock];
}

-(void)initAudio
{
    ///设置音频参数
    audioDescription.mSampleRate = 8000;//采样率
    audioDescription.mFormatID = kAudioFormatLinearPCM;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioDescription.mChannelsPerFrame = 1;///单声道
    audioDescription.mFramesPerPacket = 1;//每一个packet一侦数据
    audioDescription.mBitsPerChannel = 16;//每个采样点16bit量化
    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel/8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame ;
    ///创建一个新的从audioqueue到硬件层的通道
//      AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &audioQueue);///使用当前线程播
    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &audioQueue);//使用player的内部线程播
    ////添加buffer区
    for(int i=0;i<QUEUE_BUFFER_SIZE;i++)
    {
        int result =  AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
        NSLog(@"AudioQueueAllocateBuffer i = %d,result = %d",i,result);
    }
}
@end
