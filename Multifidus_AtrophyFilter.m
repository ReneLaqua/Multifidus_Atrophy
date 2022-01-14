//
//  Multifidus_AtrophyFilter.m
//  Multifidus_Atrophy
//
//  Copyright (c) 2022 René Laqua. All rights reserved.
//

#import "Multifidus_AtrophyFilter.h"

@implementation Multifidus_AtrophyFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
	ViewerController	*new2DViewer;
	
	// In this plugin, we will simply duplicate the current 2D window!
	
	new2DViewer = [self duplicateCurrent2DViewerWindow];
	
	if( new2DViewer) return 0; // No Errors
	else return -1;
}

@end
