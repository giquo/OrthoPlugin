//
//  OrthoPluginFilter.m
//  OrthoPlugin
//
//  Copyright (c) 2013 Giancarlo. All rights reserved.
//

/**
 *Class: OrthoPluginFilter
 *Author: Giancarlo Quevedo Ochoa
 *Version: 0.1
 *Date: Agosto 12 2013
 *E-mail: giquoG@gmail.com
 **/

#import "OrthoPluginFilter.h"
#import "OrthoPluginController.h"

#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/NSPanel+N2.h>

@implementation OrthoPluginFilter


# pragma mark Init Methods

- (void) initPlugin{
}

- (long) filterImage:(NSString*) menuName {
    
    NSLog(@"OrthoPluginFilter :: create instance of OPController");
    OrthoPluginController* controller = [[OrthoPluginController alloc] initWithPlugin:self viewerController:viewerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:viewerController];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[controller window]];
    
	[controller showWindow:self];
    
    
    return 0;
}



# pragma mark - 
# pragma mark release memory

- (void)viewerWillClose:(NSNotification*)notification {
    
    NSAlert *myAlert = [NSAlert alertWithMessageText:@"About ...!"
                                       defaultButton:@"Ok"
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@"Bobadisha"];
    
    [myAlert runModal];
    
    NSWindowController* wc = (NSWindowController*)[notification object];
    if (wc && [wc.window isVisible])
        [[wc window] close];
}

- (void)windowWillClose:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[notification object]];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self release];
}


@end
