//
//  TwoTieredTabViewAppDelegate.m
//  TwoTieredTabView
//
//  Created by Philip Dow on 5/28/11.
//  Copyright 2011 Philip Dow / Sprouted. All rights reserved.
//	phil@phildow.net / phil@getsprouted.com
//

/*
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Basically, you can use the code in your free, commercial, private and public projects
// as long as you include the above notice and attribute the code to Philip Dow / Sprouted
// If you use this code in an app send me a note. I'd love to know how the code is used.

// Icons by Joseph Wain / glyphish.com

#import "TwoTieredTabViewAppDelegate.h"
#import "SPGroupedTabView.h"

@implementation TwoTieredTabViewAppDelegate

@synthesize groupedTabView;
@synthesize window;
@synthesize panel;

@synthesize groupMatrix;
@synthesize tabMatrix;

@synthesize statesView;
@synthesize citiesView;
@synthesize nationsView;
@synthesize planetsView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (void)awakeFromNib {
	
	// A NOTE ON USAGE:
	
	// SPGroupedTabView is understood to be a static rather than dynamic view. Although
	// the main content area will regularly change, the groups and tabs will generally
	// not. The view was designed with the expectation that the group and tab items 
	// will be specified once and then remain for the most part unchanged. 
	
	// This also means that the view is expected to remain a fixed size. There is currently 
	// no support for "extended" group and tab elements, or additional groups and tabs
	// that are not currently visible but can be selected via menu, as is the case with
	// tabbed browsing in modern web browers. If you view is resized so that there is no 
	// longer enough space to display all the groups or all the tabs in a group, the
	// items at the right edge will either clip or simply fall of the view.
		
	NSInteger i;
	
	viewControllers = [[NSMutableArray alloc] init];
	
	dataModel = [[NSArray alloc] initWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
					[NSArray arrayWithObjects:@"Oklahoma", @"California", @"Colorado", nil], @"tabs",
					[NSImage imageNamed:@"states.png"], @"image",
					@"States", @"title",
					nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
					[NSArray arrayWithObjects:@"Albany", @"Austin", @"Butte", @"Oklahoma City", nil], @"tabs",
					[NSImage imageNamed:@"city.png"], @"image",
					@"Cities", @"title",
					nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
					[NSArray arrayWithObjects:@"France", @"Germany", @"Japan", nil], @"tabs",
					[NSImage imageNamed:@"tower.png"], @"image",
					@"Nations", @"title",
					nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
					[NSArray arrayWithObjects:@"Earth", @"Mars", @"Jupiter", @"Mercury", nil], @"tabs",
					[NSImage imageNamed:@"planet.png"], @"image",
					@"Planets", @"title",
					nil],
			nil];
	
	// sync the matrix to the model
	
	for ( i = 0; i < [dataModel count]; i++ )
		[[groupMatrix cellAtRow:0 column:i] setTitle:[[dataModel objectAtIndex:i] objectForKey:@"title"]];
	
	for ( i = 0; i < 4; i++ )
		[[tabMatrix cellAtRow:0 column:i] setTitle:@"-"];
	
	for ( i = 0; i < [[[dataModel objectAtIndex:0] objectForKey:@"tabs"] count]; i++ )
		[[tabMatrix cellAtRow:0 column:i] setTitle:[[[dataModel objectAtIndex:0] objectForKey:@"tabs"] objectAtIndex:i]];
	
	
	groupedTabView.groupMargin = 40.0;
		
		// describes the minimum amount of empty space that will be preserved to the 
		// left and right of the first and last group items
		
	groupedTabView.highlightGroupIcons = YES;
	
		// highlightGroupIcons is NO by default. If you are providing full color images
		// you should leave it that way. But if you are providing image masks, you
		// might set this value to YES to have your image maks given a pleasant gradient
	
	groupedTabView.preservesSelection = YES;
		
		// by default this value is NO and the view resets the tab selection to the 
		// first item whenever a different group is selected. When this value is true
		// the view will try to restore the last selected tab for each group 
	
	[groupedTabView reloadData];
	
		// call this method when the data model is ready to load or when you have
		// changed it and want to update the content of the grouped tab view. It
		// is recommended you call this method prior to setting the group and tab
		// selections
	
	groupedTabView.selectedGroupIndexes = [NSIndexSet indexSetWithIndex:0];
	groupedTabView.selectedTabIndexes = [NSIndexSet indexSetWithIndex:0];
	
		// the grouped tab view assumes that there is at least one group and one 
		// tab and that a group and tab are always selected
		
	// [groupedTabView reloadData];
		
		// It is worth noting what happens if you call reloadData after setting the group
		// and tab selectionIndexes, contrary to the recommended practice. You may comment 
		// out the prior call and uncomment this one.
		
		// The view still loads, but because we are updating the content view in the 
		// delegate methods, and the delegate methods are only called when we set the 
		// selection and not when we reload the data, our content view is initially
		// empty.
		
		// Depending on how you provide content to the view, the order in which you load
		// the data and set the tab and group selections may or may not affect the view
		// content.
		
		// You might also comment out both calls to reloadData just to see what happens:
		// the view shows up but without errors or exceptions but with no groups, tabs or 
		// content. 
	
	// other
	
	[self.planetsView setTextContainerInset:NSMakeSize(5,20)];
}

#pragma mark -
#pragma mark Grouped Tab View Data Source
 
/* You must implement these two methods */

- (NSUInteger) numberOfGroupsInGroupedTabView:(SPGroupedTabView*)aTabView {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	return [dataModel count];
}

- (NSUInteger) numberOfTabsInGroupedTabView:(SPGroupedTabView*)aTabView group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	return [[[dataModel objectAtIndex:groupIndex] objectForKey:@"tabs"] count];
}

#pragma mark -

/* It is not necessary to implement either of the following objectValue methods */

	// If you do, you must return an object that is key-value reading compliant 
	// for the keys "title" and "image" if it is a group and the key "title"
	// if it is a tab.

- (id) groupedTabView:(SPGroupedTabView*)aTabView objectValueForGroup:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	
	// our example data model group array is composed of dictionaries with "title" and "image"
	// values for each group item, so we can just return the dictionary itself and it ensures
	// that valueForKey: is converted to objectForKey: 
	
	return [dataModel objectAtIndex:groupIndex];
}

- (id) groupedTabView:(SPGroupedTabView*)aTabView objectValueForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	return nil;
}

/* You must implement one of the following methods */

/*
- (id) groupedTabView:(SPGroupedTabView*)aTabView viewForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	NSLog(@"**** %s ****",__PRETTY_FUNCTION__);
	
	// In this example, we use a separate view for each group which is shared among the tabs 
	// in that group. The view is then updated in the didSelectTab delegate method.
	
	// You could also share a single view among all of the group and tab items, or provide
	// a unique view for every group / tab combination
	
	switch ( groupIndex ) {
		case 0: // states
			return self.statesView;
			break;
		case 1: // cities
			return self.citiesView;
			break;
		case 2: // nations
			return self.nationsView;
			break;
		case 3: // planets
			return [self.planetsView enclosingScrollView];
			break;
		default:
			return nil;
			break;
	}
}
*/

- (id) groupedTabView:(SPGroupedTabView*)aTabView viewControllerForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	
	// Same pattern as if we were using regular views
	
	// Whenever I load a group view controller for the first time, I save it in the 
	// local viewControllers array. I always check for the existing view controller
	// before loading it again.
	
	// So we're saving the view controllers here, which would have the effect of 
	// preserving state information if we weren't always resetting the content in
	// the tab delegate method. 

	// It isn't necessary to save the view controllers locally. If you just want the 
	// view controllers to be one-off, the group tab view retains them as they are 
	// returned from this method and releases them when provided with new controllers
	
	NSString *desiredIdentifier = [[dataModel objectAtIndex:groupIndex] objectForKey:@"title"];
	NSViewController *theController = nil;
	
	if ( desiredIdentifier == nil ) return nil;
	
	for ( NSViewController *aController in viewControllers ) {
		if ( [(NSString*)[aController representedObject] isEqualToString:desiredIdentifier] ) {
			theController = aController;
			break;
		}
	}
	
	if ( theController == nil )  {
		
		NSString *nibName = [NSString stringWithFormat:@"%@Content",desiredIdentifier];
		theController = [[[NSViewController alloc] initWithNibName:nibName bundle:nil] autorelease];
		[theController setRepresentedObject:desiredIdentifier];
		[viewControllers addObject:theController];
		
		// Note that I am overriding local view outlets to correspond to the view controller's
		// content view. Don't do this! It's just an easy cheat that serves the example code
		
		if ( [desiredIdentifier isEqualToString:@"Nations"] )
			nationsView = (WebView*)[theController view];
		else if ( [desiredIdentifier isEqualToString:@"States"] )
			statesView = (NSImageView*)[theController view];
		else if ( [desiredIdentifier isEqualToString:@"Cities"] )
			citiesView = (NSTextField*)[theController view];
		else if ( [desiredIdentifier isEqualToString:@"Planets"] ) {
			planetsView = (NSTextView*)[(NSScrollView*)[theController view] documentView];
			[planetsView setTextContainerInset:NSMakeSize(5,20)];
		}
	}
	
	return theController;
}


#pragma mark -
#pragma mark Grouped Tab View Delegate

/* If you do not implement the objectValue delegate methods, you  should implement these two methods 
	- or nothing will show up */

- (void) groupedTabView:(SPGroupedTabView *)aTabView willDisplayCell:(id)aCell forGroup:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	
	// For this example I have commented out the following two methods in order to show
	// that you can instead return an object value in the corresponding data source method
	
	//[aCell setTitle:[[dataModel objectAtIndex:groupIndex] objectForKey:@"title"]];
	//[aCell setImage:[[dataModel objectAtIndex:groupIndex] objectForKey:@"image"]];
}

- (void) groupedTabView:(SPGroupedTabView*)aTabView willDisplayCell:(id)aCell forTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	
	[aCell setTitle:[[[dataModel objectAtIndex:groupIndex] objectForKey:@"tabs"] objectAtIndex:tabIndex]];
}

#pragma mark -

/* The rest of the methods are optional */

- (BOOL) groupedTabView:(SPGroupedTabView*)aTabView shouldSelectGroup:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	return YES;
}

- (void) groupedTabView:(SPGroupedTabView*)aTabView willSelectGroup:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void) groupedTabView:(SPGroupedTabView*)aTabView didSelectGroup:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	
	NSInteger i;
	
	[groupMatrix selectCellAtRow:0 column:groupIndex];
	
	for ( i = 0; i < 4; i++ )
		[[tabMatrix cellAtRow:0 column:i] setTitle:@""];
	
	for ( i = 0; i < [[[dataModel objectAtIndex:groupIndex] objectForKey:@"tabs"] count]; i++ )
		[[tabMatrix cellAtRow:0 column:i] setTitle:[[[dataModel objectAtIndex:groupIndex] objectForKey:@"tabs"] objectAtIndex:i]];

}

#pragma mark -

- (BOOL) groupedTabView:(SPGroupedTabView*)aTabView shouldSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	return YES;
}

- (void) groupedTabView:(SPGroupedTabView*)aTabView willSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void) groupedTabView:(SPGroupedTabView*)aTabView didSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	//NSLog(@"%s",__PRETTY_FUNCTION__);
	
	[tabMatrix selectCellAtRow:0 column:tabIndex];
	
	// Our example uses unique views for each group but then updates what is displayed
	// in that view whenever the tab selection changes. Normally you would rely on 
	// your data model to provide the appropriate content.
	
	NSString *imageName = nil;
	NSString *searchString = nil;
	NSString *planetText = nil;
	
	switch ( groupIndex ) {
		case 0: // states
			switch ( tabIndex ) {
				case 0: // oklahoma
					imageName = @"states-oklahoma.jpg";
					break;
				case 1: // california
					imageName = @"states-california.jpg";
					break;
				case 2: // colorado
					imageName = @"states-colorado.jpg";
					break;
				default:
					imageName = @"NSApplicationIcon";
					break;
			}
			
			[self.statesView setImage:[NSImage imageNamed:imageName]];
			
			break;
		
		case 1: //cities
			switch ( tabIndex ) {
				case 0:
					[self.citiesView setStringValue:@"\n\n\nAlbany"];
					break;
				case 1:
					[self.citiesView setStringValue:@"\n\n\nAustin"];
					break;
				case 2:
					[self.citiesView setStringValue:@"\n\n\nButte"];
					break;
				case 3:
					[self.citiesView setStringValue:@"\n\n\nOklahoma City"];
					break;
				default:
					[self.citiesView setStringValue:@""];
					break;
			}
			
			break;
		
		case 2: // nations
			switch ( tabIndex ) {
				case 0: // france
					searchString = @"france";
					break;
				case 1: // germany
					searchString = @"germany";
					break;
				case 2: // japan
					searchString = @"japan";
					break;
				default:
					searchString = @"";
					break;
			}
			
			NSString *googleString = [NSString stringWithFormat:@"http://news.google.com/news/search?aq=f&pz=1&cf=all&ned=us&hl=en&q=%@&btnmeta_news_search=Search+News",searchString];
			[[self.nationsView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:googleString]]];
		
			break;
		
		case 3: // planets
			switch ( tabIndex ) {
				case 0: // earth
					planetText = @"Wikipedia: Earth (or the Earth) is the third planet from the Sun and the densest and fifth-largest of the eight planets in the Solar System. It is also the largest of the Solar System's four terrestrial planets. It is sometimes referred to as the World, the Blue Planet,[20] or by its Latin name, Terra.[note 6]";
					break;
				case 1: // mars
					planetText = @"Wikipedia: Mars is the fourth planet from the Sun in the Solar System. The planet is named after the Roman god of war, Mars. It is often described as the \"Red Planet\", as the iron oxide prevalent on its surface gives it a reddish appearance.[13] Mars is a terrestrial planet with a thin atmosphere, having surface features reminiscent both of the impact craters of the Moon and the volcanoes, valleys, deserts, and polar ice caps of Earth.";
					break;
				case 2: // jupiter
					planetText = @"Wikipedia: Jupiter is the fifth planet from the Sun and the largest planet within the Solar System.[13] It is a gas giant with a mass slightly less than one-thousandth of the Sun but is two and a half times the mass of all the other planets in our Solar System combined.";
					break;
				case 3: // mercury
					planetText = @"Wikipedia: Mercury is the innermost and smallest planet in the Solar System,[a] orbiting the Sun once every 87.969 Earth days. The orbit of Mercury has the highest eccentricity of all the Solar System planets, and it has the smallest axial tilt. It completes three rotations about its axis for every two orbits.";
					break;
				default:
					planetText = @"";
					break;
			}
			
			[self.planetsView setString:planetText];
			break;
		
		default:
			break;
	}
}

#pragma mark -
#pragma mark Matrix Actions

// demonstrating how to set the grouped tab view selection programmatically
// The matrix is visible via the View > Show Panel menu

- (IBAction) showPanel:(id)sender {
	if ( [panel isVisible] ) [panel orderOut:self];
	else [panel makeKeyAndOrderFront:self];
}

- (IBAction) setSelectedGroup:(id)sender {
	
	NSInteger selection = [sender selectedColumn];
	[groupedTabView setSelectedGroupIndexes:[NSIndexSet indexSetWithIndex:selection]];
}

- (IBAction) setSelectedTab:(id)sender {
	
	NSInteger selection = [sender selectedColumn];
	[groupedTabView setSelectedTabIndexes:[NSIndexSet indexSetWithIndex:selection]];
}

@end
