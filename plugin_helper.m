//
//  plugin_helper.m
//  Multifidus_Atrophy
//
//  Created by René Laqua on 14.01.22.
//
//

#import "plugin_helper.h"


@implementation plugin_helper

+(long) GetROITool:(NSString*) t
{
    
    long tool;
    t = [t lowercaseString];
    
    NSLog(@"%@", t);
    
    
    if ([t isEqualToString:@"tmesure"]) {
        
        tool = tMesure;
        
    } else if ([t isEqualToString:@"troi"]) {
        
        tool = tROI;
        
    } else if ([t isEqualToString:@"toval"]) {
        
        tool = tOval;
        
    } else if ([t isEqualToString:@"topolygon"]) {
        
        tool = tOPolygon;
        
    } else if ([t isEqualToString:@"tcpolygon"]) {
        
        tool = tCPolygon;
        
    } else if ([t isEqualToString:@"tangle"]) {
        
        tool = tAngle;
        
    } else if ([t isEqualToString:@"ttext"]) {
        
        tool = tText;
        
    } else if ([t isEqualToString:@"tarrow"]) {
        
        tool = tArrow;
        
    } else if ([t isEqualToString:@"tpencil"]) {
        
        tool = tPencil;
        
    } else if ([t isEqualToString:@"t2dpoint"]) {
        
        tool = t2DPoint;
        
    } else if ([t isEqualToString:@"t3dpoint"]) {
        
        tool = t3Dpoint;
        
    } else if ([t isEqualToString:@"tplain"]) {
        
        tool = tPlain;
        
    } else if ([t isEqualToString:@"tlayerroi"]) {
        
        tool = tLayerROI;
        
    } else if ([t isEqualToString:@"taxis"]) {
        
        tool = tAxis;
        
    } else if ([t isEqualToString:@"tdynangle"]) {
        
        tool = tDynAngle;
        
    } else
    {
        
        NSLog(@"Tool not found. Chosing 'tMesure' tool.");
        tool = tMesure;
        
    }
    
    return tool;
}

+ (void) CloseBrushToolWindow
{
    
    NSArray *winList = [NSApp windows];
    
    for( id loopItem in winList)
    {
        if( [[[loopItem windowController] windowNibName] isEqualToString:@"PaletteBrush"])
        {
            NSLog(@"BrushWindow found.");
            [[loopItem windowController] close];
        }
    }
    
}

+ (void) OpenBrushToolWindow:(ViewerController*) view
{
    
    BOOL found = NO;
    NSArray *winList = [NSApp windows];
    
    for( id loopItem in winList)
    {
        if( [[[loopItem windowController] windowNibName] isEqualToString:@"PaletteBrush"])
        {
            found = YES;
        }
    }
    
    if( !found)
    {
        PaletteController *palette = [[PaletteController alloc] initWithViewer: view];
    }
    
}

+(void) SetROIName:(NSString*)name andTool:(NSString*)tool
{
    //	[plugintools CloseBrushToolWindow];
    NSLog(@"set roi name");
    
    long selectedTool = [self GetROITool: tool];
    
    NSLog(@"toolnr. %li", selectedTool);
    
    [ROI setDefaultName: name ];
    
    NSLog(@"done");
    
    if (selectedTool != tPlain)
    {
        [self CloseBrushToolWindow];
    }
    
    for (unsigned int i=0; i < [[ViewerController getDisplayed2DViewers] count]; i++) {
        
        ViewerController *curView = [[ViewerController getDisplayed2DViewers] objectAtIndex:i];
        
        if (selectedTool == tPlain )
        {
            
            [self OpenBrushToolWindow:curView];
            
        } else
        {
            [curView setROIToolTag: selectedTool ];
        }
        
    }
    
}
+ (NSString*) GetPatientData: (NSArray*) list Viewer:(ViewerController*)vc NameIsNumber:(BOOL) NameIsNumber AgeIsNumber:(BOOL) AgeIsNumber SexIsNumber:(BOOL) SexIsNumber
{
    
    NSString	*Result = @"";
    
    NSArray		*pixList = [vc pixList:0];
    DCMPix		*Pix = [pixList objectAtIndex: 0];
    
    NSCharacterSet	*charactersToRemove = [[ NSCharacterSet decimalDigitCharacterSet ] invertedSet ];
    
    for (unsigned int i=0; i < [list count]; i++)
    {
        
        // Get Metadata from Dicom File
        NSString	*MetaDataName = [list objectAtIndex:i];
        NSString	*MetaData = [self GetMetadata:MetaDataName Pix:Pix];
        
        // Clean up String
        MetaData = [MetaData stringByReplacingOccurrencesOfString:@"^" withString:@" "];
        MetaData = [MetaData stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Postprocessing of Meta Data
        if (([MetaDataName isEqualToString:@"PatientsName"]) && NameIsNumber) {
            
            NSString	*PatientNumber = [ MetaData stringByTrimmingCharactersInSet:charactersToRemove ];
            
            if ([PatientNumber isEqualToString:@""] ) {
                // MetaData = MetaData;
            }
            else {
                MetaData = PatientNumber;
            }
            
        } else if (([MetaDataName isEqualToString:@"PatientsAge"]) && AgeIsNumber) {
            
            MetaData = [ MetaData stringByTrimmingCharactersInSet:charactersToRemove ];
            
        } else if (([MetaDataName isEqualToString:@"PatientsSex"]) && SexIsNumber) {
            
            if ([[MetaData lowercaseString] isEqualToString:@"m"]) {
                MetaData = @"0";
            } else 	if ([[MetaData lowercaseString] isEqualToString:@"f"]) {
                MetaData = @"1";
            } else {
                MetaData = @"-1";
            }
            
        }	
        
        // add meta information to the result
        if ([Result isEqualToString:@""]) {
            
            Result = (NSMutableString*)MetaData;
            
        } else {
            
            Result = [Result stringByAppendingFormat: @"\t%@",MetaData];
            
        }
        
        
    }
    
    return Result;
    
    
}

+ (float) GetROIAttribute:(NSString*) roiAttr roiName:(NSString*) roiName viewer:(ViewerController*) viewer
{
    
    // viewer == nil scheint nicht zu funktionieren
    
    /*
     possible roiAttr are:
     - length (cm)
     - area (cm2)
     - volume (cm3)
     - mean (no unit)
     - sd (no unit)
     
     - angle
     - distance (Abstand des 2. Punktes von Verbindungslinie der ersten zwei Punkte)
     
     viewer = nil, if you want to search in all opened viewers
     
     
     // Distance berechnen
     
     Entfernungen
     AC = a
     AB = b
     BC = c
     
     s=(1/2)(a+b+c)
     Höhe =(2/a)sqrt[s(s-a)(s-b)(s-c)]
     
     */
    
    NSArray			*displayedViewers = [[NSArray alloc] init];
    NSMutableArray  *curROISeriesList;
    NSMutableArray  *curROIImageList;
    
    ViewerController	*curView;
    ROI					*curROI;
    
    float				roiAttrValue = 0;
    
    
    if (viewer == nil)
    {
        displayedViewers = [ViewerController getDisplayed2DViewers];
        
    } else {
        
        displayedViewers = [NSArray arrayWithObject: viewer];
        
    }
    
    NSLog(@"%i", [displayedViewers count]);
    
    for (unsigned int i=0; i< [displayedViewers count]; i++)
    {
        
        curView = [displayedViewers objectAtIndex:i];
        
        NSLog(@"%i", [curView maxMovieIndex]);
        for (unsigned int m = 0; m < [curView maxMovieIndex]; m++)
        {
            
            curROISeriesList = [curView roiList: m];
            
            for (unsigned int j=0; j< [curROISeriesList count]; j++)
            {
                
                curROIImageList = [curROISeriesList objectAtIndex:j];
                
                for (unsigned int k=0; k< [curROIImageList count]; k++)
                {
                    
                    curROI = [curROIImageList objectAtIndex:k];
                    
                    
                    if ([[curROI name] isEqual: roiName])
                    {
                        
                        if ([roiAttr isEqualToString:@"length"])
                        {
                            NSMutableArray *roiPolygonPts		= [ curROI points ];
                            
                            roiAttrValue = [curROI LengthFrom:[[roiPolygonPts objectAtIndex:0] point]
                                                           to:[[roiPolygonPts objectAtIndex:1] point] inPixel:FALSE];
                            
                            roiAttrValue *= 10; // mm -> cm
                            break;
                            
                        } else if ([roiAttr isEqualToString:@"width"])
                        {
                            
                            // only possible for tROI
                            
                            if ([curROI type] == tROI)
                            {
                                DCMPix *curPix = [[curView pixList:m] objectAtIndex: j];
                                NSRect rect = [curROI rect];
                                roiAttrValue = rect.size.width * [curPix pixelSpacingX];
                                
                            }
                            
                            
                        } else if ([roiAttr isEqualToString:@"height"])
                        {
                            
                            // only possible for tROI
                            
                            if ([curROI type] == tROI)
                            {
                                NSRect rect = [curROI rect];
                                roiAttrValue = rect.size.height;
                                
                            }
                            
                            
                        } else if ([roiAttr isEqualToString:@"area"])
                        {
                            
                            roiAttrValue = [curROI roiArea];
                            break;
                            
                        } else if ([roiAttr isEqualToString:@"volume"])
                        {
                            
                            roiAttrValue = [curView computeVolume:curROI points:nil error: nil];
                            
                            break;
                            
                        }  else if ([roiAttr isEqualToString:@"angle"])
                        {
                            
                            NSMutableArray *roiPolygonPts		= [ curROI points ];
                            NSPoint pt1 = [[roiPolygonPts objectAtIndex:0] point];
                            NSPoint pt2 = [[roiPolygonPts objectAtIndex:1] point];
                            NSPoint pt3 = [[roiPolygonPts objectAtIndex:2] point];
                            
                            roiAttrValue = [curROI Angle:pt1 :pt2 :pt3]; // 2,1,3
                            
                            break;
                            
                        } else if ([roiAttr isEqualToString:@"distance"])
                        {
                            
                            
                            /*
                             // Distance berechnen
                             http://www.mathematische-basteleien.de/hoehen.htm
                             
                             Strecken:
                             AC = a
                             AB = b
                             BC = c
                             
                             s=(1/2)(a+b+c)
                             Höhe =(2/a)sqrt[s(s-a)(s-b)(s-c)]
                             
                             
                             // Richtung berechnen
                             
                             radius:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));//Pytagoras
                             winkel=asin(abs(x1-x2));
                             winkel=winkel+90;
                             x2:=x1+sin(winkel)*radius;
                             y2:=y1+cos(winkel)*radius;
                             
                             */
                            
                            
                            NSMutableArray *roiPolygonPts		= [ curROI points ];
                            NSPoint pt1 = [[roiPolygonPts objectAtIndex:0] point];  // A
                            NSPoint pt2 = [[roiPolygonPts objectAtIndex:1] point];  // B
                            NSPoint pt3 = [[roiPolygonPts objectAtIndex:2] point];  // C
                            
                            // alle Angaben in Millimeter
                            float length_AC = [curROI LengthFrom:pt1 to:pt3 inPixel:FALSE];
                            float length_AB = [curROI LengthFrom:pt1 to:pt2 inPixel:FALSE];
                            float length_BC = [curROI LengthFrom:pt2 to:pt3 inPixel:FALSE];
                            float s = 0.5 * (length_AB + length_AC + length_BC);
                            
                            NSPoint	helpPoint = NSMakePoint(pt3.x, pt1.y);  //H
                            
                            float rotWinkel_HAC = [curROI Angle:helpPoint :pt1 :pt3];
                            float rotWinkel_HAB = [curROI Angle:helpPoint :pt1 :pt2];
                            
                            roiAttrValue = (2 / length_AC) * sqrt(s*(s-length_AC)*(s-length_AB)*(s-length_BC));
                            
                            //						NSLog(@"Winkel, AB=%2.3f, AC=%2.3f", rotWinkel_HAB, rotWinkel_HAC);
                            if (rotWinkel_HAB < rotWinkel_HAC)
                            { roiAttrValue = -1 * roiAttrValue; }
                            
                            
                            break;
                            
                        } else if ([roiAttr isEqualToString:@"mean"])
                        {
                            
                            DCMPix *curPix = [[curView pixList:m] objectAtIndex: j];
                            float rmean, rtotal, rdev, rmin, rmax;
                            [curPix computeROI: curROI :&rmean :&rtotal :&rdev :&rmin :&rmax];
                            
                            roiAttrValue = rmean;
                            break;
                            
                            
                        } else if ([roiAttr isEqualToString:@"sd"])
                        {
                            
                            DCMPix *curPix = [[curView pixList:m] objectAtIndex: j];
                            float rmean, rtotal, rdev, rmin, rmax;
                            [curPix computeROI: curROI :&rmean :&rtotal :&rdev :&rmin :&rmax];
                            
                            roiAttrValue = rdev;
                            break;
                            
                        }
                        
                        
                    }
                    
                    if (roiAttrValue != 0) break;
                }
                
            }
            
        }
        
    }
    
    return roiAttrValue;
    
}


+ (void) CopyInformationToClipboard: (NSString*) info
{
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:info forType:NSStringPboardType];
    
}

+ (void) CloseAllOpenViewer
{
    
    // alle offenen 2D Viewer schließen
    while ([[ViewerController getDisplayed2DViewers] count] > 0) {
        [[[[ViewerController getDisplayed2DViewers] objectAtIndex:0] window] close];
    }
    
}

+ (NSString*) GetMetadata:(NSString*) dicomTag Pix:(DCMPix*)curPix
{
    
    NSString		*val = nil;
    
    @try {
        
        NSString        *file_path      = [curPix sourceFile];
        DCMObject       *dcmObj	= [DCMObject objectWithContentsOfFile:file_path decodingPixelData:NO];
        DCMAttributeTag	*tag			= [DCMAttributeTag tagWithName:dicomTag];
        
        if (!tag) tag = [DCMAttributeTag tagWithTagString:dicomTag];
        if (tag && tag.group && tag.element)
        {
            DCMAttribute	*attr = [dcmObj attributeForTag:tag];
            val = [[attr value] description];
        }
        
    }
    @catch (NSException* ex) {
        
        NSLog(@"doSomethingFancy failed: %@",ex);
        NSLog(@"%@", dicomTag);
        
    }
    
    if (val == nil) {
        val = @"Error";
    }
    
    return val;	
}

+ (NSString*) GetUnit: (NSString*) attribute
{
    
    NSString	*res = @"?";
    
    if ([attribute isEqualToString:@"length"])
    { res = @"mm"; }
    if ([attribute isEqualToString:@"width"])
    { res = @"mm"; }
    if ([attribute isEqualToString:@"height"])
    { res = @"mm"; }
    else if ([attribute isEqualToString:@"distance"])
    { res = @"cm"; }
    else if ([attribute isEqualToString:@"area"])
    { res = @"cm2"; }
    else if ([attribute isEqualToString:@"volume"])
    { res = @"cm3"; }
    else if ([attribute isEqualToString:@"angle"])
    { res = @"°"; }
    
    return res;
    
}

+ (void) DirectoryMustExist: (NSString*) path
{
    
    BOOL isDir;
    NSError	*error;
    
    NSFileManager	*manager = [[NSFileManager alloc] init];
    
    if ([manager fileExistsAtPath: path isDirectory:&isDir ] && isDir == YES)
    {
        // folder does already exist, do nothing
        
    } else {
        
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    
    [manager release];
    
}

+ (NSString*) GetDocumentDirectory
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    
    if ([paths count]>0)
    {
        return [paths objectAtIndex:0];
    }
    else
    {
        return @"";
    }
    
    
}

+ (NSString *)InputBox: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %l", button);
        return nil;
    }
}

+ (void) SaveROIs: (NSArray*) list viewer:(ViewerController*)view inFile:(NSString*) path OnlyCurrentSlice:(BOOL) OnlyCurrentSlice
{
    
    int curSlice = [[view imageView] curImage];
    
    NSMutableArray *roisPerMovies = [NSMutableArray  array];
    BOOL rois = NO;
    
    for( int y = 0; y < [view maxMovieIndex]; y++)
    {
        NSMutableArray  *roisPerSeries = [NSMutableArray  array];
        
        for(unsigned int x = 0; x < [[view roiList:y] count]; x++)
        {
            NSMutableArray  *roisPerImages = [NSMutableArray  array];
            
            for(unsigned int i = 0; i < [[[view roiList:y] objectAtIndex: x] count]; i++)
            {
                ROI *curROI = [[[view roiList:y] objectAtIndex: x] objectAtIndex: i];
                
                if (list == nil) {
                    
                    [roisPerImages addObject: curROI];
                    rois = YES;
                    
                } else
                {
                    
                    for (unsigned int j = 0; j < [list count]; j++)
                    {
                        
                        if ([[[curROI name] lowercaseString] isEqualToString: [[list objectAtIndex:j] lowercaseString]]) {
                            
                            if (OnlyCurrentSlice && ( curSlice != (signed int)x)) {
                                break;
                            }
                            
                            [roisPerImages addObject: curROI];
                            rois = YES;
                        }
                        
                    }
                }
                
                /*				if (([[curROI name] isEqualToString:[list objectAtIndex:j]]) && ((int)x == curSlice) || (!is2D) ) {
                 
                 [roisPerImages addObject: curROI];
                 rois = YES;
                 
                 }*/
            }
            [roisPerSeries addObject: roisPerImages];
        }
        [roisPerMovies addObject: roisPerSeries];
    }
    
    if( rois == YES)
    {
        
        // Documents/OsiriXBackup/Proband/Sequenz/SHIP-Projekt/0001.rois_series
        
        NSArray		*AllFiles = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString	*Path_MyDocuments = [AllFiles objectAtIndex: 0];
        
        DCMPix		*Pix =  [[view pixList] objectAtIndex:0];
        
        NSString	*PatientName = [self GetMetadata:@"PatientsName" Pix:Pix];
        PatientName = [PatientName stringByReplacingOccurrencesOfString:@"^" withString:@" "];
        PatientName = [PatientName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        PatientName = [PatientName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        
        NSString	*Sequenz = [self GetMetadata:@"SeriesDescription" Pix:Pix];
        
        NSString	*FullFileName = [Path_MyDocuments stringByAppendingPathComponent:[NSString stringWithFormat:@"Horos_ROI_Backup/%@/%@/%@", PatientName, Sequenz, path]];
        
        [self DirectoryMustExist: FullFileName];
        
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:FullFileName error:nil];
        NSArray *onlyROIs = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @".rois_series"]];
        
        FullFileName = [FullFileName stringByAppendingPathComponent:[NSString stringWithFormat:@"%04u.rois_series", [onlyROIs count]+1]];
        
        [NSArchiver archiveRootObject: roisPerMovies toFile :FullFileName];
        
    }
    
    
}

@end
