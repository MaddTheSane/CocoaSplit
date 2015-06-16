//
//  CSDeckLinkCapture.m
//  CSDeckLinkCapturePlugin
//
//  Created by Zakk on 6/13/15.
//  Copyright (c) 2015 Zakk. All rights reserved.
//

#import "CSDeckLinkCapture.h"
#import "CSIOSurfaceLayer.h"

@implementation CSDeckLinkCapture
@synthesize renderType = _renderType;


+(NSString *)label
{
    return @"Blackmagic Decklink";
}


-(instancetype) init
{
    if (self = [super init])
    {
        _discoveryDev = new DeckLinkDeviceDiscovery(self);
        _discoveryDev->Enable();
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    if (self.currentInput && self.currentInput.selectedDisplayMode)
    {
        
        [aCoder encodeObject:self.currentInput.selectedDisplayMode.modeName forKey:@"selectedDisplayMode"];
    }
    
    if (self.currentInput && self.currentInput.selectedPixelFormat)
    {
        [aCoder encodeObject:self.currentInput.selectedPixelFormat forKey:@"selectedPixelFormat"];
    }
    
    [aCoder encodeInt:self.renderType forKey:@"renderType"];
    
}


-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        


        
        if ([aDecoder containsValueForKey:@"selectedDisplayMode"])
        {
            _restoredMode = [aDecoder decodeObjectForKey:@"selectedDisplayMode"];
        }
        
        if ([aDecoder containsValueForKey:@"selectedPixelFormat"])
        {
            _restoredFormat = [aDecoder decodeObjectForKey:@"selectedPixelFormat"];
        }
        
        
        
        self.renderType = (frame_render_behavior)[aDecoder decodeIntForKey:@"renderType"];
        [self restoreInputSettings];
        
        
    }
    
    return self;
}

-(void)restoreInputSettings
{
    
    
    if (self.currentInput)
    {
        if (_restoredMode)
        {
            
            [self.currentInput setDisplayModeForName:_restoredMode];
            _restoredMode = nil;
        }
        
        if (_restoredFormat)
        {
            self.currentInput.selectedPixelFormat = _restoredFormat;
            _restoredFormat = nil;
        }
    }
}

-(CALayer *)createNewLayer
{
    
    CSDeckLinkLayer *newLayer = [CSDeckLinkLayer layer];
    if (self.renderType == kCSRenderAsync)
    {
        newLayer.asynchronous = YES;
    } else {
        newLayer.asynchronous = NO;
    }
    
    return newLayer;
}


-(void)setActiveVideoDevice:(CSAbstractCaptureDevice *)activeVideoDevice
{
    
    super.activeVideoDevice = activeVideoDevice;
    
    if (activeVideoDevice)
    {
        NSValue *devValue = activeVideoDevice.captureDevice;
        IDeckLink *deckLink = (IDeckLink *)[devValue pointerValue];
    
        NSLog(@"SET ACTIVE DEVICE %@", activeVideoDevice);
        
        self.currentInput = [[CSDeckLinkDevice alloc] initWithDevice:deckLink];
        [self.currentInput registerOutput:self];
    } else {
        self.currentInput = nil;
    }
}



-(void)setRenderType:(frame_render_behavior)renderType
{
    bool asyncValue = NO;
    if (renderType == kCSRenderAsync)
    {
        asyncValue = YES;
    }
    
    
    [self updateLayersWithBlock:^(CALayer *layer) {
        ((CSDeckLinkLayer *)layer).asynchronous = asyncValue;
    }];
    
    _renderType = renderType;
}


-(frame_render_behavior)renderType
{
    return _renderType;
}


-(void)addDevice:(CSAbstractCaptureDevice *)device
{

    if (!self.availableVideoDevices)
    {
        self.availableVideoDevices = [NSArray array];
    }
    
    
    NSLog(@"NEW DEVICE ARRIVED %@", device);
    
    NSArray *newArray = [self.availableVideoDevices arrayByAddingObject:device];
    self.availableVideoDevices = newArray;
    if (!self.activeVideoDevice && self.savedUniqueID)
    {
        [self setDeviceForUniqueID:self.savedUniqueID];
        [self restoreInputSettings];

    }
}



-(void)frameArrived:(IDeckLinkVideoFrame *)frame
{
    if (frame)
    {
        [self updateLayersWithBlock:^(CALayer *layer) {
            [(CSDeckLinkLayer *)layer setRenderFrame:frame];
            if (self.renderType == kCSRenderFrameArrived)
            {
                [((CSDeckLinkLayer *)layer) setNeedsDisplay];
            }
            
        }];
    }
}

-(void)frameTick
{
    
    if (self.renderType == kCSRenderOnFrameTick)
    {
        
        [self updateLayersWithBlock:^(CALayer *layer) {
            [((CSDeckLinkLayer *)layer) setNeedsDisplay];
        }];
    }
    
}

-(void)dealloc
{
    
     if (self.currentInput)
    {
        [self.currentInput removeOutput:self];
    }
}


@end