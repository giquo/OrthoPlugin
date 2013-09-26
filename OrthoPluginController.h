//
//  OrthoPluginController.h
//  OrthoPlugin
//
//  Created by mmv-lab on 13/08/13.
//
//

/**
 *@short clase que controlala interfaz grafica declarada en OrthoPluginController.xib
 *@class OrthoPluginController
 *@author Giancarlo Quevedo Ochoa
 *@version 0.1
 *@date Agosto 13 2013
 **/


#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

#import "OrthoPluginFilter.h"

@class ROI, DCMView, ViewerController;


@interface OrthoPluginController : NSWindowController {

    OrthoPluginFilter *_pluginFilter;
    ViewerController *_viewerController;
    
    ROI *_femurLayer, *_femurRoi, *_originalFemurOpacityLayer;
    
    BOOL procedureLocked;                               // KVO for chBoxLockProcedure
    
    
    // *** IBOutlets ***
    
    // toolBar
    IBOutlet NSToolbar *toolBar;
    
    IBOutlet NSToolbarItem *bttnCalibrate;
    IBOutlet NSToolbarItem *bttnLayers;
    IBOutlet NSToolbarItem *tItemProcedureList;
    IBOutlet NSComboBox *comBoxOrthoProcedureList;   // KVO with chBoxLockProcedure
    IBOutlet NSButton *chBoxLockProcedure;              // KVC with comBoxOrthoProcedureList
    
    IBOutlet NSTextField *label;
    
    
    
    // Calibration
    //IBOutlet NSMatrix *_magnificationRadio;
	//IBOutlet NSTextField* _magnificationCustomFactor;
    //IBOutlet NSTextField* _magnificationCalibrateLength;
    ROI *_magnificationLine;
	CGFloat _appliedMagnification;
    
    
    
    float angleRoiOld,angleRoiNew,angleValue;
    
}

@property(readonly) ViewerController* viewerController;
@property (assign) IBOutlet NSToolbarItem *bttnLayers;
@property BOOL procedureLocked;



- (id) initWithPlugin:(OrthoPluginFilter*) filter viewerController:(ViewerController*)viewerController;



/*  *   *   *   *   *   *   *   * S E T    O F     I B A C T I O N S *     *   *   *   *   *   *   */
#pragma mark -
#pragma mark IBAction methods

/**
 * --
 *@param sender Object that sends the action to excecute
 *@return IBAction Action to excecute
 **/
-(IBAction)toolbarAction:(id)sender;


/**
 * Method to create a new ROI layer with te capacity to be rotated with the trackPad
 *@param sender Object that sends the action to excecute
 *@return IBAction Action to excecute
 **/
-(IBAction)createOrthopaedicROILayer:(id)sender;


/**
 * Method to establish the calibration parameter for the procedure, automatically creates a line where the plugin
 * will consider it's length to calculate the calibration value
 *@param sender Object that sends the action to excecute
 *@return IBAction Action to excecute
 **/
-(IBAction)calibration:(id)sender;


/**
 * Method to enable/disable the Combo Box that holds the procedure list.
 * When a user will work on a procedure, should check his decision on the check box, then the plugin will load 
 * the environment to the chosen procedure.
 * If user will change the procedure, should enable the Combo Box unchecking the check box, the plugin will ask to
 * confirm and the environment is cleaned up and ready to load another procedure.
 *@param sender Object that sends the action to excecute
 *@return IBAction Action to excecute
 **/
-(IBAction)lockProcedure:(id)sender;


/**
 * Method to load the environment of the selected orthopaedic procedure.
 * When the user has selected a procedure, the plugin will ask to confirm the action, then the environment of the
 * procedure is loaded in the Panel, the procedure is locked automatically.
 *@param sender Object that sends the action to excecute
 *@return IBAction Action to excecute
 **/
-(IBAction)selectOrthopaedicProcedure:(id)sender;



-(void)rotateRoi:(float)rotationAngle;

-(void)removeRoiFromViewer:(ROI*)roi;




@end
