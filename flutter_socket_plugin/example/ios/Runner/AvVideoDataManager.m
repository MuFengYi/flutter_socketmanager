//
//  AvVideoDataManager.m
//  Runner
//
//  Created by hao ke on 2022/1/6.
//
#import "AvVideoDataManager.h"
@implementation AvVideoDataManager

+ (instancetype)shareInstance{
    static id _instance;
    static dispatch_once_t _once_t;
    dispatch_once(&_once_t, ^{
        _instance    =   [[self alloc] init];
    });
    return _instance;
}

- (void)openVideo:(NSString*)videoPath
{
    av_register_all();
    
    avformat_network_init();
    self.avformatContext    = [self creatFormatContext:videoPath];
    self.aa_videoStreamIndex   = [self getVideoStreamIndex:self.avformatContext isVideoStream:YES];
    self.aa_audioStreamIndex    =   [self getVideoStreamIndex:self.avformatContext isVideoStream:NO];
}

- (AVFormatContext*)creatFormatContext:(NSString*)videoPath
{
    if (videoPath==nil) {
        return NULL;
    }
    AVFormatContext *aa =   NULL;
    AVDictionary    *opts   =   NULL;
    
    
    
    
    aa = avformat_alloc_context();
    BOOL isSuccess   = avformat_open_input(&aa, [videoPath cStringUsingEncoding:NSUTF8StringEncoding], NULL, &opts)<0?NO:YES;
    

    av_dict_free(&opts);
    if (!isSuccess) {
        if (aa) {
            avformat_free_context(aa);
        }
        return NULL;
    }
    if (avformat_find_stream_info(aa, NULL)<0) {
        avformat_close_input(&aa);
        
        return NULL;
    }
    
    return aa;
}


- (int)getVideoStreamIndex:(AVFormatContext*)aa isVideoStream:(BOOL)isVideoStream
{
    int avStramIndex    =   -1;
    for (int i=0; i<aa->nb_streams; i++) {
        if ((isVideoStream?AVMEDIA_TYPE_VIDEO:AVMEDIA_TYPE_AUDIO)==aa->streams[i]->codecpar->codec_type) {
            avStramIndex   =    i;
        }
    }
    return avStramIndex;
}


- (void)strartParseWithCompletionHandler:(void (^)(BOOL isVideoFrame, BOOL isFinish, AAVideoInfo * videoInfo))handler


{
    [self strartParseWithFormatContext:self.avformatContext videoStreamIndex:self.aa_videoStreamIndex audioStreamIndex:self.aa_audioStreamIndex completionHandler:handler];
}

- (void)strartParseWithFormatContext:(AVFormatContext*)avformatContext videoStreamIndex:(int)videoStreamIndex audioStreamIndex:(int)audioStreamIndex completionHandler:(void (^)(BOOL isVideoFrame,BOOL isFinish,AAVideoInfo* videoInfo))handler
{
    
    self.isStopParse    =   NO;
    dispatch_queue_t parseQueue =   dispatch_queue_create("parseQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(parseQueue, ^{
        AVPacket    packet;
        AVRational  input_base;
        input_base.num = 1;
        input_base.den = 1000;
        while (!self.isStopParse) {
            av_init_packet(&packet);
            if (!avformatContext) {
                break;
            }
             int size    = av_read_frame(avformatContext, &packet);
            if (size<0||packet.size<0) {
                NSLog(@"解析完成,没有读取到数据");
                break;
            }
            if (packet.stream_index == videoStreamIndex) {
                
                AAVideoInfo videoInfo   =   {0};
                int video_size  =   packet.size;
                uint8_t *video_data =   packet.data;
                memcpy(video_data, packet.data, video_size);
                static char filter_name[32];
                if (avformatContext->streams[videoStreamIndex]->codecpar->codec_id==AV_CODEC_ID_H264) {
                    strncpy(filter_name, "h264_mp4toannexb", 32);
                    videoInfo.videoFormat   =   AAH264VideoFormat;
                }
                AVPacket newPacket  =   packet;
                if (self.avbitstreamFilterContext==NULL) {
                    self.avbitstreamFilterContext   =   av_bitstream_filter_init(filter_name);
                }
                
                av_bitstream_filter_filter(self.avbitstreamFilterContext, self.avformatContext->streams[videoStreamIndex]->codec, NULL, &newPacket.data, &newPacket.size, packet.data, packet.size, 0);
                
                videoInfo.data  = video_data;
                videoInfo.dataSize  =   video_size;
                videoInfo.extraDataSize = self.avformatContext->streams[videoStreamIndex]->codec->extradata_size;
                videoInfo.extraData =   malloc(videoInfo.extraDataSize);
                memcpy(videoInfo.extraData, self.avformatContext->streams[videoStreamIndex]->codec->extradata, videoInfo.extraDataSize);
                av_free(newPacket.data);
                
                if (handler) {
                    handler(YES,NO,&videoInfo);
                }
                free(videoInfo.extraData);
                free(videoInfo.data);
            }
            
            
            
            
            
            
            
            
            
            if (packet.stream_index==audioStreamIndex) {
                [[PCMPlayer shareInstance] playWithData:[NSData dataWithBytes:packet.data length:packet.size]];
            }
            
            
            
            
            
            
            
             
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        
            
            
//            av_packet_unref(&packet);
        }
        
        
        
        [self freeAllResources];
    });
}















- (void)freeAllResources{
    if (self.avformatContext) {
        avformat_close_input(&_avformatContext);
        self.avformatContext    =   NULL;
    }
    if (self.avbitstreamFilterContext) {
        av_bitstream_filter_close(self.avbitstreamFilterContext);
        self.avbitstreamFilterContext   =   NULL;
    }
}
@end
