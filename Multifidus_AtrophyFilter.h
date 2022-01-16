//
//  Multifidus_AtrophyFilter.h
//  Multifidus_Atrophy
//
//  Copyright (c) 2022 René Laqua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Horos/PluginFilter.h>

@interface Multifidus_AtrophyFilter : PluginFilter {
    IBOutlet	NSWindow		*window;
    IBOutlet	NSTextField		*txtDefaultROIName;
}

- (long) filterImage:(NSString*) menuName;
- (IBAction) ChangeDefaultROIName:(id) sender;
- (IBAction) ExportValues:(id) sender;

@end
