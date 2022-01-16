//
//  plugin_helper.h
//  Multifidus_Atrophy
//
//  Created by René Laqua on 14.01.22.
//
//
// Info - create Alias to Framework by Terminal, otherwise it won't work!!!
// ln -s /Applications/Horos.app/Contents/Frameworks/Horos.framework Horos.framework

#import <Foundation/Foundation.h>
#import <Horos/PluginFilter.h>
#import <Horos/PaletteController.h>
#import "DCMObject.h"
#import "DCMAttribute.h"
#import "DCMAttributeTag.h"

@interface plugin_helper : NSObject
{
    struct PluginVariable {
        
        NSString	*varName;
        NSString	*roiTool;		// tCPolygon, tMesure
        NSString	*varType;		// STRING, DOUBLE, INTEGER
        NSString	*varAttribute;	// Mean, SD, Area, Volume
        NSString    *indexDependencies; // 1,4,6
        
    };
}

+ (long) GetROITool:(NSString*) t;
+ (void) CloseBrushToolWindow;
+ (void) OpenBrushToolWindow:(ViewerController*) view;
+ (void) SetROIName:(NSString*)name andTool:(NSString*)tool;
+ (NSString*) GetPatientData: (NSArray*) list Viewer:(ViewerController*)vc NameIsNumber:(BOOL) NameIsNumber AgeIsNumber:(BOOL) AgeIsNumber SexIsNumber:(BOOL) SexIsNumber;
+ (float) GetROIAttribute:(NSString*) roiAttr roiName:(NSString*) roiName viewer:(ViewerController*) viewer;
+ (void) CopyInformationToClipboard: (NSString*) info;
+ (void) CloseAllOpenViewer;
+ (NSString*) GetMetadata:(NSString*) dicomTag Pix:(DCMPix*)curPix;
+ (NSString*) GetUnit: (NSString*) attribute;
+ (void) DirectoryMustExist: (NSString*) path;
+ (NSString*) GetDocumentDirectory;
+ (NSString *)InputBox: (NSString *)prompt defaultValue: (NSString *)defaultValue;
+ (void) SaveROIs: (NSArray*) list viewer:(ViewerController*)view inFile:(NSString*) path OnlyCurrentSlice:(BOOL) OnlyCurrentSlice;


@end

