//
//  OrthoPluginController.m
//  OrthoPlugin
//
//  Created by mmv-lab on 13/08/13.
//

/**
 *Class: OrthoPluginController
 *Author: Giancarlo QUevedo Ochoa
 *Version: 0.1
 *Date: Agosto 13 2013
 *E-mail: giquoG@gmail.com
 **/

#import "OrthoPluginController.h"

#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/ViewerController.h>
#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/N2Operators.h>
#import <OsiriXAPI/NSBitmapImageRep+N2.h>


@implementation OrthoPluginController;

@synthesize bttnLayers;
@synthesize viewerController = _viewerController;
@synthesize procedureLocked;



# pragma mark Init Methods

- (id)initWithPlugin:(OrthoPluginFilter *) filter viewerController:(ViewerController*)viewerController {
    
    NSLog(@"OrthoPluginController :: recieve filter...");
    _pluginFilter = [filter retain];
    
    NSLog(@"OrthoPluginController :: recieve ViewerController...");
    _viewerController = [viewerController retain];
    
    
    NSLog(@"OrthoPluginController :: Load UI with .xib file...");
    self = [super initWithWindowNibName:@"OrthoPluginController"];
    //[[self window] setDelegate:self];
    
    
    // place at viewer window upper right corner
	NSRect frame = [[self window] frame];
	NSRect screen = [[[_viewerController window] screen] frame];
	frame.origin.x = screen.origin.x+screen.size.width-frame.size.width;
	frame.origin.y = screen.origin.y+screen.size.height-frame.size.height;
	[[self window] setFrame:frame display:YES];
    
    
    // calibration value
    _appliedMagnification = 1;
    
    
    // to delete after : establish the OsiriX Roi configuration
    [_viewerController roiDeleteAll:self];
    [_viewerController setROIToolTag:tCPolygon];
    
    
    // Setting up the femurLayer configuration
    [_femurRoi setOpacity:1];
    [_femurRoi setSelectable:YES];
    [_femurRoi setROIMode:ROI_selected];
    //[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_femurRoi userInfo:NULL];
    
    angleValue = 0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    return self;
    
}


- (void)awakeFromNib{
    
    procedureLocked = true;
}


- (void)windowDidLoad{
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void)removeRoiFromViewer:(ROI*)roi {
	if (!roi) return;
	[[[_viewerController roiList] objectAtIndex:0] removeObject:roi];
	[[NSNotificationCenter defaultCenter] postNotificationName:OsirixRemoveROINotification object:roi userInfo:NULL];
}




# pragma mark -
# pragma mark IBAction Methods

-(IBAction)toolbarAction:(id)sender{
    
    [label setStringValue:[sender label]];
    
    NSLog(@"preparing the ROI tools :) ...");
        
    /*ROI *_femurRoi = [_viewerController newROI : tCPolygon];
    
    
    / * [_femurRoi setOpacity:1];
     [_femurRoi setSelectable:YES];
     [_femurRoi setROIMode:ROI_selected];
     [_femurRoi setThickness:1];
     [_femurRoi setIsSpline:NO];
     [_femurRoi setDisplayTextualData:NO];
     
     [[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_femurRoi userInfo:NULL];
     */
    
    
}


/*
 * IBAction cuando se desea crear una capa ROI nueva tipo Osteotomia
 */
-(IBAction)createOrthopaedicROILayer:(id)sender {
    
    //[self removeRoiFromViewer:_femurLayer];
    
    [_viewerController setROIToolTag:tPencil];
    
    NSMutableArray  *pixList;
    NSMutableArray  *roiSeriesList;
    NSMutableArray  *roiImageList;
    DCMPix			*curPix;
    
    
    
    //NSString		*roiName = 0L;
    long			i;
    // In this plugin, we will take the selected roi of the current 2D viewer
    // and search all rois with same name in other images of the series
    pixList = [_viewerController pixList];
    curPix = [pixList objectAtIndex: [[_viewerController imageView] curImage]];
    // All rois contained in the current series
    roiSeriesList = [_viewerController roiList];
    // All rois contained in the current image
    roiImageList = [roiSeriesList objectAtIndex: [[_viewerController imageView] curImage]];
    // Find the first selected ROI of current image
    //use previous lines for others purposes
    //in our case we search for selected rois at current image only
    for( i = 0; i < [roiImageList count]; i++)
    {
        if( [[roiImageList objectAtIndex: i] ROImode] == ROI_selected)
        {
            // We find it! What's his name?
            //roiName = [[roiImageList objectAtIndex: i] name];
            _femurLayer = [_viewerController createLayerROIFromROI:[roiImageList objectAtIndex: i]];
            [_femurLayer roiMove:NSMakePoint(-10,10)]; // when the layer is created it is shifted, but we don't want this so we move it back
            [_femurLayer setOpacity:1];
            [_femurLayer setDisplayTextualData:NO];
            
            
            //****************** opacity
            
            NSBitmapImageRep* femur = [NSBitmapImageRep imageRepWithData:[[_femurLayer layerImage] TIFFRepresentation]];
            NSSize size = [[_femurLayer layerImage] size];
            NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:size.width pixelsHigh:size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:size.width*4 bitsPerPixel:32];
            unsigned char* bitmapData = [bitmap bitmapData];
            int bytesPerRow = [bitmap bytesPerRow], bitsPerPixel = [bitmap bitsPerPixel];
            for (int y = 0; y < size.height; ++y)
                for (int x = 0; x < size.width; ++x) {
                    int base = bytesPerRow*y+bitsPerPixel/8*x;
                    bitmapData[base+0] = 0;
                    bitmapData[base+1] = 0;
                    bitmapData[base+2] = 0;
                    bitmapData[base+3] = [[femur colorAtX:x y:y] alphaComponent]>0? 128 : 0;
                }
            
            NSImage* image = [[NSImage alloc] init];
            unsigned kernelSize = 5;
            NSBitmapImageRep* temp = [bitmap smoothen:kernelSize];
            [image addRepresentation:temp];
            
            
            _originalFemurOpacityLayer = [_viewerController addLayerRoiToCurrentSliceWithImage:[image autorelease] referenceFilePath:@"none" layerPixelSpacingX:[[[_viewerController imageView] curDCM] pixelSpacingX] layerPixelSpacingY:[[[_viewerController imageView] curDCM] pixelSpacingY]];
            [_originalFemurOpacityLayer setSelectable:NO];
            [_originalFemurOpacityLayer setDisplayTextualData:NO];
            [_originalFemurOpacityLayer roiMove:[[[_femurLayer points] objectAtIndex:0] point]-[[[_originalFemurOpacityLayer points] objectAtIndex:0] point]-([temp size]-[bitmap size])/2];
            [_originalFemurOpacityLayer setNSColor:[[NSColor redColor] colorWithAlphaComponent:.5]];
            [[_viewerController imageView] roiSet:_originalFemurOpacityLayer];
            [[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_originalFemurOpacityLayer userInfo:NULL];
            
            [_femurRoi setROIMode:ROI_sleep];
            [_femurRoi setSelectable:NO];
            [_femurRoi setOpacity:0.2];
            [[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_femurRoi userInfo:NULL];
            
            [_viewerController selectROI:_femurLayer deselectingOther:YES];
            //[_viewerController bringToFrontROI:_femurLayer];
        }
    }
    
    // layer point, rotation center
    _rotationCenter = [_viewerController newROI:t2DPoint];
    
    //NSMutableArray *centerPoint = [rotationCenter points];           // points of _magnificationLine (empty)
    
    // values in pixels (NOT IN mm!)
    NSRect myRect = NSMakeRect([_femurLayer centroid].x, [_femurLayer centroid].y, 0, 0);
    [_rotationCenter setROIRect:myRect];
    
    [roiImageList addObject:_rotationCenter];
    [_rotationCenter setDisplayTextualData:NO];
    [_viewerController bringToFrontROI:_rotationCenter];
}


/*
 * IBAction cuando se desea establecer un valor de calibracion para la imagen
 */
-(IBAction)calibration:(id)sender {

    [label setStringValue:[sender label]];
    
    NSMutableArray *roiSeriesList = [_viewerController roiList];
    NSMutableArray *roiImageList = [roiSeriesList objectAtIndex: [[_viewerController imageView] curImage]];
    
    _magnificationLine = [_viewerController newROI:tMesure];    // create ROI layer for measure
    
    // points of _magnificationLine (empty)
    NSMutableArray *points = [_magnificationLine points];
    
    // values in pixels (NOT IN mm!)
    [points addObject: [_viewerController newPoint:20 :70]];
    [points addObject: [_viewerController newPoint:20 :500]];
    
    [roiImageList addObject:_magnificationLine];
    [_magnificationLine setName:@"Calibration Line"];
}


- (IBAction)lockProcedure:(id)sender {
    
    if ( [chBoxLockProcedure state] == NSOnState ) {
        [label setStringValue:@"ON"];
        procedureLocked = !procedureLocked;
        [comBoxOrthoProcedureList setEnabled:false];
    } else {
        
        
        NSAlert *myAlert = [NSAlert alertWithMessageText:@"Cancelar Procedimiento..."
                                           defaultButton:@"Ok"
                                         alternateButton:@"Cancel"
                                             otherButton:nil
                               informativeTextWithFormat:@"Esta seguro que desea cancelar el procedimiento?"];
        
        // let's check the selected item
        if ( [myAlert runModal] == NSAlertDefaultReturn) {
            
            [label setStringValue:@"OFF"];
            procedureLocked = !procedureLocked;
            [comBoxOrthoProcedureList setEnabled:true];
            [comBoxOrthoProcedureList selectItemAtIndex:0];
            
        } else
            [chBoxLockProcedure setState:NSOnState];
    }
}


- (IBAction)selectOrthopaedicProcedure:(id)sender {
    
    
    // check if the selected item isn't the first one
    if ([comBoxOrthoProcedureList indexOfSelectedItem] != 0) {
        
        // get the selected item in the comBox
        NSString *nstrSelectedItem = [comBoxOrthoProcedureList objectValueOfSelectedItem];
        
        NSAlert *myAlert = [NSAlert alertWithMessageText:@"Seleccionar Procedimiento..."
                                           defaultButton:@"Ok"
                                         alternateButton:@"Cancel"
                                             otherButton:nil
                               informativeTextWithFormat:@"Desea cargar el ambiente para trabajar con %@", nstrSelectedItem];
        
        // let's check the selected item
        if ( [myAlert runModal] == NSAlertDefaultReturn ) {
            // stuff
            [chBoxLockProcedure setState:NSOnState];
            [self lockProcedure:chBoxLockProcedure];
            /*
            
             */
        }
        
        // guessing that is Cancel Operation
        else {
            [comBoxOrthoProcedureList selectItemAtIndex:0];
        }
    }
}





# pragma mark -
# pragma mark Rotation

- (void)rotateWithEvent:(NSEvent *) event {
    
    /*float angleRoi = [event rotation];
     angleRoiNew = angleRoi;
     //NSLog(@"Rotation angle obtained: %f",angleRoi);
     
     if (angleRoiNew<angleRoiOld) {
     angleRoi=-[event rotation];
     angleValue--;
     } else {
     angleRoi=[event rotation];
     angleValue++;
     }
     
     [label setStringValue: [[NSNumber numberWithFloat:angleValue] stringValue]];
     
     angleRoiOld=angleRoiNew;
     [self rotateRoi:angleRoi];*/
    
    
    
    // first approach
    [self rotateRoi:angleValue - [event rotation]];
    
    
}


-(void)rotateRoi:(float)rotationAngle{
    
    NSMutableArray  *pixList;
    NSMutableArray  *roiSeriesList;
    NSMutableArray  *roiImageList;
    DCMPix			*curPix;
    NSString		*roiName = 0L;
    long			i;
    // In this plugin, we will take the selected roi of the current 2D viewer
    // and search all rois with same name in other images of the series
    pixList = [_viewerController pixList];
    curPix = [pixList objectAtIndex: [[_viewerController imageView] curImage]];
    // All rois contained in the current series
    roiSeriesList = [_viewerController roiList];
    // All rois contained in the current image
    roiImageList = [roiSeriesList objectAtIndex: [[_viewerController imageView] curImage]];
    // Find the first selected ROI of current image
    //use previous lines for others purposes
    //in our case we search for selected rois at current image only
    for( i = 0; i < [roiImageList count]; i++)
    {
        if( [[roiImageList objectAtIndex: i] ROImode] == ROI_selected)
        {
            // We find it! What's his name?
            roiName = [[roiImageList objectAtIndex: i] name];
            //Let's try so rotate the roi
            NSPoint testPoint;
            //testPoint = NSMakePoint (0, 0);
            ROI *myRoi;
            myRoi=[roiImageList objectAtIndex: i];
            
            
            testPoint = [_rotationCenter pointAtIndex:0];
            
            //testPoint=[myRoi centroid];           // normal rotation
            
            
            
            [myRoi rotate:rotationAngle :testPoint];
            //NSLog(@"Applied rotation angle: %f degrees. Roi %d centroid at %f,%f",rotationAngle,i,testPoint.x,testPoint.y);
        }
    }
    if (i==0)
    {
        NSRunInformationalAlertPanel(@"ROI Rotation", @"You need to create and select a ROI!", @"OK", 0L, 0L);
        return ;
    }
    else
    {
        if( roiName == 0L)
        {
            NSRunInformationalAlertPanel(@"ROI Rotation", @"You need to select a ROI!", @"OK", 0L, 0L);
            return ;
        }
    }
}




# pragma mark -
# pragma mark Dealloc

- (void) dealloc {
    
    [bttnLayers dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
	
    [super dealloc];
    
}


- (void)viewerWillClose:(NSNotification*)notification {
    /*if( [notification object] == _viewerController){
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        [self release];
    }*/
}


- (void)windowWillClose:(NSNotification *)notification{
    //[[NSNotificationCenter defaultCenter] removeObserver: self];
	//[self release];
}




@end
