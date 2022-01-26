#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>








#import "SGAudioSource.h"


@interface AppDelegate : FlutterAppDelegate<SGAudioSourceDelegate,FlutterStreamHandler>
{
    SGAudioSource *sgaudioSource;
}
@property (nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic,strong)NSMutableData *audioData;
@end
