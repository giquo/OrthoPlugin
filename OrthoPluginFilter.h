//
//  OrthoPluginFilter.h
//  OrthoPlugin
//
//  Copyright (c) 2013 Giancarlo. All rights reserved.
//

/**
 *@short Clase que realiza la conexion con OsiriX.
 *Es la clase principal del plugin ortopedico.
 *@class OrthoPluginFilter
 *@author Giancarlo Quevedo Ochoa
 *@version 0.1
 *@date Agosto 13 2013
 **/

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>


@interface OrthoPluginFilter : PluginFilter {
    
    NSWindow *window;
    
    // newer*/ OrthopaedicTemplatingWindowController *_templatesWindowController;
    
    
    /*/ newer ***
    //Calibration
    CGFloat *_appliedMagnification;
     */
    
    
    // newer*/
    // newer*/
    
	//**Hip arthroplasty** ArthroplastyTemplatingWindowController *_templatesWindowController;
	//**Hip arthroplasty** NSMutableArray* _windows;
	//**Hip arthroplasty** BOOL _initialized;
}


// newer*/    @property(readonly) OrthopaedicTemplatingWindowController* templatesWindowController;
// newer*/    @property(readonly) CGFloat magnification;

//**Hip arthroplasty** @property(readonly) ArthroplastyTemplatingWindowController* templatesWindowController;
//**Hip arthroplasty** -(ArthroplastyTemplatingStepsController*)windowControllerForViewer:(ViewerController*)viewer;

@end
