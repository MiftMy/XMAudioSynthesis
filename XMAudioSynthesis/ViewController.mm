//
//  ViewController.m
//  XMAudioSynthesis
//
//  Created by mifit on 15/11/30.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "XMRecordPlay.h"
#import "lame.h"
#import "XMAudioMix.h"

@interface ViewController (){
    NSMutableArray *_audioMixParams;
    
}
@property (nonatomic,strong) VVERecordPlay *rpManager;
@property (nonatomic,strong) NSString *recordPath;
@property (nonatomic,strong) NSString *switchPath;
@property (nonatomic,strong) NSString *exportPath;

@property (weak, nonatomic) IBOutlet UIButton *recorded;

@property (weak, nonatomic) IBOutlet UITextField *beginTime;
@property (weak, nonatomic) IBOutlet UITextField *endTime;

- (IBAction)beginCut:(id)sender;
- (IBAction)switchCode:(id)sender;
- (IBAction)startStopRecord:(id)sender;
- (IBAction)exportAudio:(id)sender;
- (IBAction)switchCode2:(id)sender;
- (IBAction)show:(id)sender;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    XMAudioMix *s = [[XMAudioMix alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (VVERecordPlay *)rpManager{
    if (!_rpManager) {
        _rpManager = [[VVERecordPlay alloc]init];
    }
    return _rpManager;
}
#pragma mark  音频合成
/// 音频合成
- (void) exportAudio {

    AVMutableComposition *composition = [AVMutableComposition composition];
    _audioMixParams = [[NSMutableArray alloc] init];
    
    //Add Audio Tracks to Composition
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"qbd" ofType:@"caf"];
    NSString *path = self.switchPath;
    NSURL *assetURL1 = [NSURL fileURLWithPath:path];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL1 options:nil];
    CMTime startTime = CMTimeMakeWithSeconds(0, 1);
    CMTime trackDuration = songAsset.duration;
    
    [self setUpAndAddAudioAtPath:assetURL1 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0, 44100)];
    
    path = [[NSBundle mainBundle] pathForResource:@"m" ofType:@"mp3"];
    NSURL *assetURL2 = [NSURL fileURLWithPath:path];
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0, 44100)];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:_audioMixParams];
    
    //If you need to query what formats you can export to, here's a way to find out
    NSLog (@"compatible presets for songAsset: %@",
           [AVAssetExportSession exportPresetsCompatibleWithAsset:composition]);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: composition
                                      presetName: AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType = @"com.apple.m4a-audio";

    NSString *exportFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"export.m4a"];//EXPORT_NAME为导出音频文件名
    self.exportPath = exportFile;
    
    // set up export
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:{
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
                
            case AVAssetExportSessionStatusCompleted: NSLog (@"AVAssetExportSessionStatusCompleted"); break;
            case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
            case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
            case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
            case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
            default:  NSLog (@"didn't get export status"); break;
        }
    }];
    
    //    // start up the export progress bar
    //    progressView.hidden = NO;
    //    progressView.progress = 0.0;
    //    [NSTimer scheduledTimerWithTimeInterval:0.1
    //                                     target:self
    //                                   selector:@selector (updateExportProgress:)
    //                                   userInfo:exporter
    //                                    repeats:YES];
    
}

- (void) setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition *)composition start:(CMTime)start dura:(CMTime)dura offset:(CMTime)offset{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    NSError *error = nil;
    BOOL ok = NO;
    
    CMTime startTime = start;
    CMTime trackDuration = dura;
    CMTimeRange tRange = CMTimeRangeMake(startTime, trackDuration);
    
    //Set Volume
    AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    [_audioMixParams addObject:trackMix];
    
    //Insert audio into track  //offset CMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:offset error:&error];
}

#pragma mark - 剪切
- (void)audioCut{
    //1. 创建AVURLAsset对象（继承了AVAsset）
    NSString *path = [[NSBundle mainBundle] pathForResource:@"m" ofType:@"mp3"];
    NSURL *songURL = [NSURL fileURLWithPath:path];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    
    //2.创建音频文件
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"output.m4a"];//EXPORT_NAME为导出音频文件名
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSError *assetError;
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    //3.创建音频输出会话
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:songAsset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    //4.设置音频截取时间区域 （CMTime在Core Medio框架中，所以要事先导入框架）
    CMTime startTime = CMTimeMake([self.beginTime.text floatValue], 1);
    CMTime stopTime = CMTimeMake([self.endTime.text floatValue], 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    //5.设置音频输出会话并执行
    exportSession.outputURL = [NSURL fileURLWithPath:exportPath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
}

- (BOOL)switch2Mp3{
    //在转换mp3端的代码为:
    NSString *cafFilePath = self.recordPath;    //caf文件路径
    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"switch1.%@", @"mp3"]];//存储mp3文件的路径
    self.switchPath = mp3FilePath;
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    if([fileManager removeItemAtPath:mp3FilePath error:nil]){
        NSLog(@"删除");
    }
    
    
    @try {
        int read, write;
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        
        if(pcm == NULL){
            NSLog(@"file not found");
        } else {
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, 8000.0);//11025.0
            //lame_set_VBR(lame, vbr_default);
            
            lame_set_brate(lame,8);
            lame_set_quality(lame,2); /* 2=high 5 = medium 7=low 音质*/
            lame_init_params(lame);
            do {
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            return YES;
        }
        return NO;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    
    @finally {
        NSLog(@"执行完成");
    }
    
}


- (IBAction)beginCut:(id)sender {
    [self audioCut];
}

- (IBAction)switchCode:(id)sender {
    [self switch2Mp3];
}

- (IBAction)startStopRecord:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (btn.selected) {
        NSLog(@"end");
        [self.rpManager endRecord];
    } else {
        NSLog(@"begin");
        self.recordPath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"record.%@", @"caf"]];
        [self.rpManager beginRecord:self.recordPath rate:8000];
    }
    btn.selected = !btn.selected;
}

- (IBAction)exportAudio:(id)sender {
    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"result.%@", @"mp3"]];//存储mp3文件的路径
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"m" ofType:@"mp3"];
     //合成时间由最长的那个决定。
    [XMAudioMix mixAudio:self.recordPath andAudio:audioPath toFile:mp3FilePath preferedSampleRate:44110];
   
}

- (IBAction)switchCode2:(id)sender {
    [self exportAudio];
}

- (short *)readAudioData:(NSString *)path{
    NSURL *url1 = [NSURL fileURLWithPath:path];
    NSError *error;
    AVURLAsset *item1=[AVURLAsset URLAssetWithURL:url1 options:Nil];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:item1 error:&error];
    if (error) {
        NSLog(@"11111");
    }
    
    AVAssetReaderAudioMixOutput *outPut = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:[item1 tracks] audioSettings:nil];
    if ([reader canAddOutput:outPut]) {
        [reader addOutput:outPut];
    }
    
    
    UInt64 total_converted_bytes;
    UInt64 converted_count;
    UInt64 converted_sample_num;
    size_t sample_size;
    short* data_buffer=nil;
    
    CMBlockBufferRef next_buffer_data=nil;
    
    [reader startReading];
    while (reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef buffer = [outPut copyNextSampleBuffer];
        if (buffer) {
            total_converted_bytes = CMSampleBufferGetTotalSampleSize(buffer);//next_buffer的总字节数；
            sample_size = CMSampleBufferGetSampleSize(buffer, 0);//next_buffer中序号为0的sample的大小；
            converted_sample_num = CMSampleBufferGetNumSamples(buffer);//next_buffer中
            
            if (!data_buffer) {
                data_buffer = new short[4096*sample_size];
            }
            next_buffer_data = CMSampleBufferGetDataBuffer(buffer);
            OSStatus buffer_status = CMBlockBufferCopyDataBytes(next_buffer_data, 0, total_converted_bytes, data_buffer);
            if (buffer_status != kCMBlockBufferNoErr) {
                NSLog(@"something wrong happened when copying data bytes");
            }
        }else {
            NSLog(@"total sameple size %lld", converted_count);
            size_t total_data_length = CMBlockBufferGetDataLength(next_buffer_data);
            NSLog(@"item buffer length is %f",(float)total_data_length);
            break;
        }
    }
    if (reader.status == AVAssetReaderStatusCompleted) {
        NSLog(@"read over......");
        return data_buffer;
    }else {
        NSLog(@"read failed;");
        return NULL;
    }
}

- (void)writeAudio:(NSString *)path{
    NSError *error;
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeMPEGLayer3 error:&error];
    if (!error) {
//        NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithDouble:128.0*1024.0],AVVideoAverageBitRateKey, nil ];
//        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey, [NSNumber numberWithInt:300], AVVideoWidthKey, [NSNumber numberWithInt:300],AVVideoHeightKey,videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
//        
//        AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
//        videoWriterInput.expectsMediaDataInRealTime = YES;
//        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
//        
//        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        NSDictionary* audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys: @(kAudioFormatMPEG4AAC), AVFormatIDKey, @(64000), AVEncoderBitRateKey, @(44100.0), AVSampleRateKey, @(1), AVNumberOfChannelsKey, [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,nil ];
        
        AVAssetWriterInput *audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings: audioOutputSettings];
        audioWriterInput.expectsMediaDataInRealTime = YES;
        
        [writer addInput:audioWriterInput];
        //[writer addInput:videoWriterInput];
        [writer startWriting];
    }
}

- (IBAction)show:(id)sender{
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"m" ofType:@"mp3"];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"qbd" ofType:@"caf"];
    [self readAudioData:path1];
    [self readAudioData:path1];
}
@end
