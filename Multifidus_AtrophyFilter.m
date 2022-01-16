//
//  Multifidus_AtrophyFilter.m
//  Multifidus_Atrophy
//
//  Copyright (c) 2022 René Laqua. All rights reserved.
//

#import "Multifidus_AtrophyFilter.h"
#import "plugin_helper.h"

@implementation Multifidus_AtrophyFilter

NSArray	*Variables, *FilteredVariables, *ROITool;

const int	varCount = 12;
struct		PluginVariable	pVar[varCount-1];
BOOL		exportToClipboard = TRUE;
BOOL		exportToXML = TRUE;  // Benutzer/Documente/ExportXML
NSString	*pluginString = @"Multifidus_Atrophy";
NSString	*UserID_Preset = @"User1";


- (void) initPlugin
{
}

- (IBAction) ChangeDefaultROIName:(id) sender
{
    
    // close Dialog
    
    [window orderOut:sender];
    [NSApp endSheet:window returnCode:[sender tag]];
    
    // get tag of pressed button
    
    NSInteger index = [sender tag];
    
    NSLog(@"change roi tool now!");
    [plugin_helper SetROIName:pVar[index].varName andTool:pVar[index].roiTool];
    
    // show only ROI names
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ROITEXTNAMEONLY"];
    
}


- (IBAction) ExportValues:(id) sender
{
    
    // close dialog window
    
    [window orderOut:sender];
    [NSApp endSheet:window returnCode:[sender tag]];
    NSInteger index = [sender tag];
    
    if (index == 0) return;
    
    // Preparation before Value Export
    
    NSLog(@"Start Export");
    
 //   [self InitExport];
    
    // start export to clipboard and in XML file
    
    NSMutableString		*Line_VarName	= [[NSMutableString alloc] initWithString: @""];
    NSMutableString		*Line_VarValues = [[NSMutableString alloc] initWithString: @""];
    
    NSMutableString		*XMLFileContent	= [[NSMutableString alloc] init];
    NSString			*XMLStringFormat = @"<VARIABLE NAME=\"%@\" VALUE=\"%@\" TYPE=\"NUMBER\" />\n";
    //	NSString			*XMLStringFormat = @"<VARIABLE NAME=\"%@\" VALUE=\"%@\" />\n";
    NSString			*XMLFileFormat	= @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<SHIP>\n<TABLE NAME=\"%@\" VERSION=\"1\">\n%@</TABLE>\n</SHIP>";
    NSString			*XMLFilePath	= @"";
    
    // patient name
    
    DCMPix		*firstPix = [[viewerController pixList] objectAtIndex:0];
    
    //    NSString	*patientName = [plugintools GetMetadata: @"PatientsName" Pix: firstPix ];
    NSString	*patientName = [plugin_helper GetMetadata: @"PatientID" Pix: firstPix ];
    
    NSString	*patientSex = [plugin_helper GetMetadata: @"PatientsSex" Pix: firstPix ];
    NSString	*patientAge = [plugin_helper GetMetadata: @"PatientsAge" Pix: firstPix ];
    NSString	*patientWeight = [plugin_helper GetMetadata: @"PatientsWeight" Pix: firstPix ];
    patientWeight = [patientWeight stringByReplacingOccurrencesOfString:@"." withString:@","];
    NSString	*patientSize = [plugin_helper GetMetadata: @"PatientsSize" Pix: firstPix ];
    patientSize = [patientSize stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    //    if ([patientName length] >= 13)
    //    {
    //        NSRange		range = NSMakeRange (7, 6);

    //        patientName = [patientName substringWithRange:range];
    //    }
    
    [Line_VarName   appendString: [NSString stringWithFormat: @"%@\t%@\t%@\t%@\t%@", @"Name", @"Geschlecht", @"Alter", @"Gewicht", @"Groesse"  ]];
    [Line_VarValues appendString: [NSString stringWithFormat: @"%@\t%@\t%@\t%@\t%@", patientName, patientSex, patientAge, patientWeight, patientSize ]];
    
    [XMLFileContent appendFormat: XMLStringFormat, @"prob_id", patientName];
    NSMutableString *XMLFile = [[NSMutableString alloc] init];
    
    // other Variables
    
    for (signed int i=0; i < varCount; i++)
    {
        
        float varValue = [plugin_helper GetROIAttribute:pVar[i].varAttribute
                                              roiName:pVar[i].varName
                                               viewer:nil];
        
        [Line_VarName appendString: [NSString stringWithFormat: @"\t%@ [%@]",
                                     pVar[i].varName, [plugin_helper GetUnit: pVar[i].varAttribute] ]];
        
        
        [Line_VarValues appendString: [NSString localizedStringWithFormat:@"\t%2.5f", varValue ]];
        
        [XMLFileContent appendFormat: XMLStringFormat, pVar[i].varName, [NSString stringWithFormat:@"%2.5f", varValue] ];
        
        
    }
    
    // do the export
    
    if (exportToClipboard)
    {
        
        NSString *string = [NSString stringWithFormat:@"%@\n%@", Line_VarName, Line_VarValues];
        
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
        [pasteBoard setString:string forType:NSStringPboardType];
        
    }
    
    
    if (exportToXML)
    {
        
        NSString	*XMLStringFormat2 = @"<VARIABLE NAME=\"%@\" VALUE=\"%@\" TYPE=\"DATETIME\" />\n";
        
        [XMLFileContent appendFormat: XMLStringFormat2, @"mrt_shoulder_osdate", [[NSDate date] description]];
        
        // aquire User ID
        NSString	*XMLStringFormat3 = @"<VARIABLE NAME=\"%@\" VALUE=\"%@\" TYPE=\"STRING\" />\n";
        
        NSString *UserID = [plugin_helper InputBox:@"Bitte Benutzer-ID eingeben." defaultValue: UserID_Preset];
        [XMLFileContent appendFormat: XMLStringFormat3, @"usnr", UserID];
        
        // finalize XML-File
        
        XMLFile = [NSString stringWithFormat: XMLFileFormat, @"t_mrt_multifidus_data", XMLFileContent ];
        
        XMLFilePath = [[plugin_helper GetDocumentDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"XMLExport/%@/%@.xml", pluginString, patientName]];
        [plugin_helper DirectoryMustExist: [XMLFilePath stringByDeletingLastPathComponent]];
        
        [XMLFile writeToFile:XMLFilePath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
        
    }
    
    // Release Memory
    
    [Line_VarName release];
    [Line_VarValues release];
    [XMLFileContent release];
    //	[XMLFile release];
    
    // Save ROIs
    
    // Benutzer/Horos_ROI_Backup/
    [plugin_helper SaveROIs:nil viewer:viewerController inFile:pluginString OnlyCurrentSlice:FALSE];
    
    
    // Close all open Windows
    
    // [plugintools CloseAllOpenViewer];
    
    
}


- (long) filterImage:(NSString*) menuName
{
    
    // Init Variables
    // Number of Variables ("varCount") is defined at the beginning of this document
    
    pVar[0].varName = @"mrt_falmm_ta_L3_r";
    pVar[0].roiTool = @"tplain";
    pVar[0].varAttribute = @"area";
    
    pVar[1].varName = @"mrt_falmm_pfa_L3_r";
    pVar[1].roiTool = @"tplain";
    pVar[1].varAttribute = @"area";
    
    pVar[2].varName = @"mrt_falmm_ta_L3_l";
    pVar[2].roiTool = @"tplain";
    pVar[2].varAttribute = @"area";
    
    pVar[3].varName = @"mrt_falmm_pfa_L3_l";
    pVar[3].roiTool = @"tplain";
    pVar[3].varAttribute = @"area";
    
    pVar[4].varName = @"mrt_falmm_ta_L4_r";
    pVar[4].roiTool = @"tplain";
    pVar[4].varAttribute = @"area";
    
    pVar[5].varName = @"mrt_falmm_pfa_L4_r";
    pVar[5].roiTool = @"tplain";
    pVar[5].varAttribute = @"area";
    
    pVar[6].varName = @"mrt_falmm_ta_L4_l";
    pVar[6].roiTool = @"tplain";
    pVar[6].varAttribute = @"area";
    
    pVar[7].varName = @"mrt_falmm_pfa_L4_l";
    pVar[7].roiTool = @"tplain";
    pVar[7].varAttribute = @"area";
    
    pVar[8].varName = @"mrt_falmm_ta_L5_r";
    pVar[8].roiTool = @"tplain";
    pVar[8].varAttribute = @"area";
    
    pVar[9].varName = @"mrt_falmm_pfa_L5_r";
    pVar[9].roiTool = @"tplain";
    pVar[9].varAttribute = @"area";
    
    pVar[10].varName = @"mrt_falmm_ta_L5_l";
    pVar[10].roiTool = @"tplain";
    pVar[10].varAttribute = @"area";
    
    pVar[11].varName = @"mrt_falmm_pfa_L5_l";
    pVar[11].roiTool = @"tplain";
    pVar[11].varAttribute = @"area";
    

  
    // Open Modal Window
    [NSBundle loadNibNamed:@"SettingsDialog_Multifidus_Atrophy" owner:self];
    
    [NSApp beginSheet: window modalForWindow:[NSApp keyWindow]
        modalDelegate:self didEndSelector:nil contextInfo:nil];
    

    return 0; // no errors
    
}



@end
