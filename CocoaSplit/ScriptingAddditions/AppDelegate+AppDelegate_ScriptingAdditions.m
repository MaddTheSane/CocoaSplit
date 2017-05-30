//
//  AppDelegate+AppDelegate_ScriptingAdditions.m
//  CocoaSplit
//
//  Created by Zakk on 8/31/14.
//

#import "AppDelegate+AppDelegate_ScriptingAdditions.h"

@implementation AppDelegate (AppDelegate_ScriptingAdditions)


-(NSArray *)layouts
{
    return self.captureController.sourceLayouts;
}

-(NSArray *)layoutscripts
{
    return self.captureController.layoutSequences;
}

-(NSArray *)audioInputs
{
    return self.captureController.multiAudioEngine.audioInputs;
}


-(NSArray *)captureDestinations
{
    return self.captureController.captureDestinations;
}

- (unsigned int)countOfCaptureDestinations {
    return (unsigned int)self.captureController.captureDestinations;
}

- (unsigned int)countOfAudioInputsArray {
    return (unsigned int)self.captureController.multiAudioEngine.audioInputs;
}


- (unsigned int)countOfLayoutScriptsArray {
    return (unsigned int)self.captureController.layoutSequences.count;
}


- (unsigned int)countOfLayoutsArray {
    return (unsigned int)self.captureController.sourceLayouts.count;
}


-(void)setActivelayoutByString:(NSString *)byString
{
    NSUInteger selectedIdx = [self.captureController.sourceLayouts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [((SourceLayout *)obj).name isEqualToString:byString];

    }];
    
    
    SourceLayout *selectedLayout = nil;
    
    if (selectedIdx != NSNotFound)
    {
        selectedLayout = [self.captureController.sourceLayouts objectAtIndex:selectedIdx];
    }
    
    
    if (selectedLayout)
    {
        [self setActiveLayout:selectedLayout];
    }
}


-(void)setActiveLayout:(SourceLayout *)layout
{
    self.captureController.selectedLayout = layout;
}


-(int)width
{
    return self.captureController.selectedLayout.canvas_width;
}

-(int)height
{
    return self.captureController.selectedLayout.canvas_height;
}

-(float)fps
{
    return self.captureController.selectedLayout.frameRate;
}

-(void)setFps:(double)fps
{
    self.captureController.captureFPS = fps;
}

-(SourceLayout *)activelayout
{
    return self.captureController.selectedLayout;
}


-(SourceLayout *)staginglayout
{
    return self.captureController.stagingLayout;
}

-(SourceLayout *)livelayout
{
    return self.captureController.selectedLayout;
}


-(bool)useTransitions
{
    return self.captureController.useTransitions;
}

-(void)setUseTransitions:(bool)useValue
{
    self.captureController.useTransitions = useValue;
}


-(BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
    
    
    NSArray *keys = @[@"layouts", @"width", @"height", @"fps", @"activelayout", @"layoutscripts", @"audioInputs", @"captureDestinations", @"staginglayout", @"livelayout", @"useTransitions"];
    
    return [keys containsObject:key];
}


@end
