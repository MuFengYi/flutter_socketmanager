//
//  AudioQueuePlay.h
//  Runner
//
//  Created by hao ke on 2021/12/31.
//

#import <Foundation/Foundation.h>


#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioQueuePlay : NSObject


+ (instancetype)shareInstance;
- (void)startPlay:(NSData*)data;
@end

NS_ASSUME_NONNULL_END
