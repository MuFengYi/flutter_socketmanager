#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import "PCMPlayer.h"


#import "PlayViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    
    _audioData   =   [[NSMutableData alloc] init];
    
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
    
    
    
    
    
    
    
    
    
    //    [controller.view.layer insertSublayer:self.sampleBufferDisplayLayer atIndex:1];
    //    [controller.view addSubview:self.previewView];
    
    //    [controller.view bringSubviewToFront:self.imageView];
    FlutterMethodChannel* testChannel =
    [
        FlutterMethodChannel methodChannelWithName:@"improject"
        binaryMessenger:controller
    ];
    [testChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([call.method isEqualToString:@"start"]) {
            if ([call.arguments isEqualToString:@"play"]){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *filePath = [path stringByAppendingPathComponent:@"audio.pcm"];
                if ([fileManager fileExistsAtPath:filePath]) {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
                [self->_audioData writeToFile:filePath atomically:YES];
                return;
            }
            [self configureAudioCapture];
            if (self.eventSink!=nil) {
                self.eventSink(@"1234567");
                //                [self->captureg711 startRecord];
                [self->sgaudioSource start];
                //                [self->pcmCapture start];
            }
        }
        else if ([call.method isEqualToString:@"play"])
        {
            NSLog(@"call.arguments==========%@",call.arguments);
            if ([call.arguments isEqual:@"rtmp://ns8.indexforce.com/home/mystream"]) {
                UIStoryboard *storyboard    =   [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                PlayViewController  *playViewController =   [storyboard instantiateViewControllerWithIdentifier:@"PlayViewController"];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller presentViewController:playViewController animated:YES completion:nil];
                    
                    
                });
                return;
            }
            FlutterStandardTypedData *flutterData   =  call.arguments;
            NSData  *data   =   flutterData.data;
            //            Byte *byteData = (Byte *)[data bytes];
            [[PCMPlayer shareInstance] playWithData:data];
        }
    }];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"improject/receiveData" binaryMessenger:[UIApplication sharedApplication].delegate.window.rootViewController];
    [eventChannel setStreamHandler:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments{
    self.eventSink = nil;
    return nil;
}

- (void)configureAudioCapture {
    sgaudioSource   =   [[SGAudioSource alloc] init];
    sgaudioSource.delegate  =   self;
    SGAudioConfig   *sgaudioconfig  =   [[SGAudioConfig alloc] init];
    sgaudioconfig.bitRate   =   SGAudioBitRate_Default;
    sgaudioconfig.sampleRate    =   8000;
    sgaudioconfig.channels  =   1;
    sgaudioSource.config    =   sgaudioconfig;
}



- (void)audioSource:(SGAudioSource *)source didOutputAudioBufferList:(AudioBufferList)bufferList
{
    NSData  *data   =   [[NSData alloc] initWithBytes:bufferList.mBuffers[0].mData length:bufferList.mBuffers[0].mDataByteSize];
    NSUInteger length = data.length;
    NSMutableString *hexStr = [NSMutableString stringWithCapacity:length * 2];
    const unsigned char *byte = data.bytes;
    for (int i = 0; i < length; i++, byte++) {
        [hexStr appendFormat:@"%02X", *byte];
    }
    NSLog(@"这个就是g711a数据：%@",hexStr);
    if (self.eventSink!=nil) {
        self.eventSink(hexStr);
        //        [[DDOpenALAudioPlayer sharePalyer] openAudioFromQueue:audioDataRef->data dataSize:audioDataRef->size samplerate:44100 channels:1 bit:16];
    }
}



- (UIImage *)convert:(CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    
    
    
    
    
    
    
    
    
    

    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return uiImage;
}

@end
