//
//  AAQueuePlayer.h
//  Runner
//
//  Created by hao ke on 2022/1/24.
//

#import <Foundation/Foundation.h>
#import <AudioToolBox/AudioToolBox.h>
#define QUEUE_BUFFSIZE 6 //队列缓冲个数
#define SIZEFRAME 1024 //每帧最小数据长度









NS_ASSUME_NONNULL_BEGIN

@interface AAQueuePlayer : NSObject
{
    AudioQueueRef   playQueue;
    
    
    
    
    
    
    
    
    
    
    
    
    
}







@property (nonatomic,assign)int sampleRate;




@property (nonatomic,assign)int channles;




+ (instancetype)shareInstance;





- (void)playData:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
