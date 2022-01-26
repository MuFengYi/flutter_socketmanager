//
//  AudioDecoder.m
//  Runner
//
//  Created by hao ke on 2022/1/6.
//

#import "AudioDecoder.h"








typedef struct {
    char * data;
    UInt32 size;
    UInt32 channelCount;
    AudioStreamPacketDescription packetDesc;
} CCAudioUserData;

@implementation AudioDecoder

static OSStatus AudioDecoderConverterComplexInputDataProc(  AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData,  AudioStreamPacketDescription **outDataPacketDescription,  void *inUserData) {
    CCAudioUserData *audioDecoder = (CCAudioUserData *)(inUserData);
    if (audioDecoder->size <= 0) {
        ioNumberDataPackets = 0;
        return -1;
    }
    //填充数据
    *outDataPacketDescription = &audioDecoder->packetDesc;
    (*outDataPacketDescription)[0].mStartOffset = 0;
    (*outDataPacketDescription)[0].mDataByteSize = audioDecoder->size;
    (*outDataPacketDescription)[0].mVariableFramesInPacket = 0;
    ioData->mBuffers[0].mData = audioDecoder->data;
    ioData->mBuffers[0].mDataByteSize = audioDecoder->size;
    ioData->mBuffers[0].mNumberChannels = audioDecoder->channelCount;
    return noErr;
}
+ (instancetype)shareInstance{
    static id _instance;
    static dispatch_once_t _once_t;
    dispatch_once(&_once_t, ^{
        _instance   =   [[self alloc] init];
    });
    return _instance;
}
- (dispatch_queue_t)decodeQueue{
    if (!_decodeQueue) {
        _decodeQueue = dispatch_queue_create("decode queue", NULL);
    }
    return _decodeQueue;
}
- (dispatch_queue_t)decodeCallbackQueue{
    if (!_decodeCallbackQueue) {
        _decodeCallbackQueue = dispatch_queue_create("decode callback queue", NULL);
    }
    return _decodeCallbackQueue;
}


- (void)setupEncoder {
    
    
    aqPlayer    =   [[AQPlayer alloc] initWithSampleRate:self.sampleRate];
    //输出参数pcm
    AudioStreamBasicDescription outputAudioDes = {0};
    outputAudioDes.mSampleRate = self.sampleRate;       //采样率
    outputAudioDes.mChannelsPerFrame = self.channelCount; //输出声道数
    outputAudioDes.mFormatID = kAudioFormatLinearPCM;                //输出格式
    outputAudioDes.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked); //编码 12
    outputAudioDes.mFramesPerPacket = 1;                            //每一个packet帧数 ；
    outputAudioDes.mBitsPerChannel = 16;                             //数据帧中每个通道的采样位数。
    outputAudioDes.mBytesPerFrame = outputAudioDes.mBitsPerChannel / 8 *outputAudioDes.mChannelsPerFrame;                              //每一帧大小（采样位数 / 8 *声道数）
    outputAudioDes.mBytesPerPacket = outputAudioDes.mBytesPerFrame * outputAudioDes.mFramesPerPacket;                             //每个packet大小（帧大小 * 帧数）
    outputAudioDes.mReserved =  0;                                  //对其方式 0(8字节对齐)
    
    //输入参数aac
    AudioStreamBasicDescription inputAduioDes = {0};
    inputAduioDes.mSampleRate = (Float64)self.sampleRate;
    inputAduioDes.mFormatID = kAudioFormatMPEG4AAC;
    inputAduioDes.mFormatFlags = kMPEG4Object_AAC_LC;
    inputAduioDes.mFramesPerPacket = 1024;
    inputAduioDes.mChannelsPerFrame = (UInt32)self.channelCount;
    
    //填充输入相关信息
    UInt32 inDesSize = sizeof(inputAduioDes);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &inDesSize, &inputAduioDes);
    
    OSStatus status = AudioConverterNew(&inputAduioDes, &outputAudioDes, &_audioDecodeConverter);
    if (status != noErr) {
        NSLog(@"Error！：硬解码AAC创建失败, status= %d", (int)status);
        return;
    }
}

- (void)decodeAudioAACData:(NSData *)aacData {
   
    if (!_audioDecodeConverter) {
        [self setupEncoder];
    }
    
    dispatch_async(self.decodeQueue, ^{
     
        //记录aac 作为参数参入解码回调函数
        CCAudioUserData userData = {0};
        userData.channelCount = (UInt32)self.channelCount;
        userData.data = (char *)[aacData bytes];
        userData.size = (UInt32)aacData.length;
        userData.packetDesc.mDataByteSize = (UInt32)aacData.length;
        userData.packetDesc.mStartOffset = 0;
        userData.packetDesc.mVariableFramesInPacket = 0;
        
        //输出大小和packet个数
        UInt32 pcmBufferSize = (UInt32)(2048 * self.channelCount);
        UInt32 pcmDataPacketSize = 1024;
        
        //创建临时容器pcm
        uint8_t *pcmBuffer = malloc(pcmBufferSize);
        memset(pcmBuffer, 0, pcmBufferSize);
        
        //输出buffer
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = (uint32_t)self.channelCount;
        outAudioBufferList.mBuffers[0].mDataByteSize = (UInt32)pcmBufferSize;
        outAudioBufferList.mBuffers[0].mData = pcmBuffer;
        
        //输出描述
        AudioStreamPacketDescription outputPacketDesc = {0};
        
        //配置填充函数，获取输出数据
        OSStatus status = AudioConverterFillComplexBuffer(self->_audioDecodeConverter, AudioDecoderConverterComplexInputDataProc, &userData, &pcmDataPacketSize, &outAudioBufferList, &outputPacketDesc);
        if (status != noErr) {
            NSLog(@"Error: AAC Decoder error, status=%d",(int)status);
            return;
        }
        //如果获取到数据
        if (outAudioBufferList.mBuffers[0].mDataByteSize > 0) {
            NSData *rawData = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            dispatch_async(self.decodeCallbackQueue, ^{
                // 这里可以处理解码出来的pcm数据
                NSLog(@"%@",rawData);
//                [[PCMPlayer shareInstance] playWithData:rawData];
                [aqPlayer playWithData:rawData];
            });
        }
        free(pcmBuffer);
    });
}

@end
