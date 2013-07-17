
#import <QuartzCore/QuartzCore.h>

#import "BezelWindow.h"
#import "BezelView.h"


static BezelWindow *sCurrentWindow = nil;


@interface BezelWindow ()

- (void)reflash:(NSString *)text;
- (void)flash:(NSString *)text;
- (void)fadeInAndMakeKeyAndOrderFront:(BOOL)orderFront;
- (void)fadeOutAndOrderOut:(BOOL)orderOut;

@end


@implementation BezelWindow {
    BezelView *roundedView_;
}


+ (void)flashText:(NSString *)text {
    if (sCurrentWindow) {
        [sCurrentWindow reflash:text];
    } else {
        [[[[self alloc] init] autorelease] flash:text];
    }
}


- (id)init {
    NSRect frame = NSMakeRect(0, 0, 210, 210);
    
    self = [super initWithContentRect:frame
                            styleMask:NSBorderlessWindowMask 
                              backing:NSBackingStoreBuffered 
                                defer:NO];
    if (self) {
        self.level = NSModalPanelWindowLevel;
        self.backgroundColor = [NSColor clearColor];
        self.alphaValue = 1.0f;
        self.opaque = NO;
        self.hasShadow = NO;
        self.ignoresMouseEvents = YES;
        
        [self position];
        
        roundedView_ = [[BezelView alloc] initWithFrame:frame];
        [self setContentView:roundedView_];
        
        [sCurrentWindow release];
        sCurrentWindow = [self retain];
    }
    return self;
}

- (void)dealloc {
    [roundedView_ release];
    
    [super dealloc];
}


- (void)position {
    NSRect frame = [self frame];
    NSRect screenFrame = [self.screen frame];
    
    CGFloat xPos = NSWidth(screenFrame)/2 - NSWidth(frame)/2;
    CGFloat yPos = 140;
    
    NSRect positionedFrame = NSMakeRect(xPos, yPos, NSWidth(frame), NSHeight(frame));
    [self setFrame:positionedFrame display:YES];
}

- (BOOL)canBeVisibleOnAllSpaces {
    return YES;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}


- (BOOL)canBecomeMainWindow {
    return NO;
}


#pragma mark - Private methods

- (void)reflash:(NSString *)text {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[NSAnimationContext currentContext] setDuration:0.2];
    
    [self.animator setAlphaValue:1.0];
    
    [NSAnimationContext endGrouping];
    
    roundedView_.text = text;
    
    [self performSelector:@selector(fadeOutAndOrderOut:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0f];
}

- (void)flash:(NSString *)text {
    roundedView_.text = text;
    [self fadeInAndMakeKeyAndOrderFront:YES];
    [self performSelector:@selector(fadeOutAndOrderOut:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0f];
}


- (void)fadeInAndMakeKeyAndOrderFront:(BOOL)orderFront {
    [self setAlphaValue:0.0];
    if (orderFront) {
        [self makeKeyAndOrderFront:nil];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[NSAnimationContext currentContext] setDuration:0.6];
    [self.animator setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
}


- (void)fadeOutAndOrderOut:(BOOL)orderOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [sCurrentWindow release];
        sCurrentWindow = nil;
    }];
    
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[NSAnimationContext currentContext] setDuration:0.4];
    
    if (orderOut) {
        NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.1;
        [self performSelector:@selector(orderOut:) withObject:nil afterDelay:delay];
    }
    
    [self.animator setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
}

@end
