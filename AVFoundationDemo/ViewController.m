//
//  ViewController.m
//  AVFoundationDemo
//
//  Created by Jinah Adam on 5/27/13.
//  Copyright (c) 2013 Jinah Adam. All rights reserved.
//

#import "ViewController.h"


@interface ViewController()
@property (nonatomic,strong) AVCaptureSession * session;
@property (strong) AVCaptureDevice * videoDevice;
@property (strong) AVCaptureDeviceInput * videoInput;
@property (strong) AVCaptureVideoDataOutput * frameOutput;
@property (strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic,strong) IBOutlet UIImageView* imgView;
@property (nonatomic,strong) CIDetector * faceDetector;
@property (nonatomic,strong) CIContext * context;
@property (nonatomic,strong) UIImageView * glasses;

@end

@implementation ViewController


-(CIContext*) context{
    if(!_context){
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
    
    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];
    self.imgView.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(ref);
    

}

-(IBAction)captureStill:(id)sender {
    AVCaptureConnection *stillImageConnection = [[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo];
    
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                             NSLog(@"Capture still image");
                                                             if (imageDataSampleBuffer != NULL) {
                                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                                 
                                                                 
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 NSLog(@"Image %f", image.size.height);
                                                             }
                                                             
                                                         }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [self.stillImageOutput setOutputSettings:outputSettings];

    
    self.videoInput =[AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    [self.session addOutput:self.stillImageOutput];
    
    
    [self.frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.session startRunning];
    

    
}

@end
