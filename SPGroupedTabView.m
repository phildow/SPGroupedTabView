//
//  SPGroupedTabView.m
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

#import "SPGroupedTabView.h"

#define kGroupHeaderHeight 72
#define kTabHeaderHeight 43

#define kGroupCellSize 48

#define kTabCellSpacing 12

#define kGroupGradientShadowLevel 0.5
#define kTabGradientShadowLevel 0.2

#define kContentBorderWhiteAmount 0.7

#pragma mark -


@interface SPGroupedTabViewGroupCell()

@property(readwrite,copy) NSColor *textColor;
@property(readwrite,copy) NSColor *iconColor;

@end

@interface SPGroupedTabViewTabCell()

@property(readwrite,copy) NSColor *textColor;
@property(readwrite,copy) NSColor *borderColor;

@property(readwrite) BOOL mouseOver;

@end

#pragma mark -

@interface SPGroupedTabView()

@property(readwrite,retain) NSViewController *contentViewController;
@property(readwrite,retain) NSView *contentView;

- (SPGroupedTabViewGroupCell*) _newGroupCell;
- (SPGroupedTabViewTabCell*) _newTabCell;

- (NSBezierPath*) _bezierPathForGroupHeader;
- (NSBezierPath*) _bezierPathForTabHeader;
- (NSBezierPath*) _bezierPathForContentBorder;
- (NSBezierPath*) _bezierPathForContent;

- (NSBezierPath*) _bezierPathForGroupSelectionIndicator:(NSUInteger)groupIndex count:(NSUInteger)groupCount;

- (NSRect) _frameOfGroupCell:(NSUInteger)groupIndex count:(NSUInteger)numGroups;
- (NSRect) _frameOfTabCell:(NSUInteger)tabIndex count:(NSUInteger)numTabs;

- (void) _setSelectedGroupIndexesWithBindingsUpdatedCheckingWithDelegate:(NSIndexSet*)inIndexes;
- (void) _setSelectedTabIndexesWithBindingsUpdatedCheckingWithDelegate:(NSIndexSet*)inIndexes;

- (NSIndexSet*) _lastSelectedIndexesForGroup:(NSUInteger)groupIndex;
- (void) _cacheSelectionInfoForGroup:(NSUInteger)groupIndex tabSelection:(NSIndexSet*)inIndexes;

- (void) _rebuildGroupItems;
- (void) _rebuildTabItemsForGroup:(NSUInteger)groupIndex;
- (void) _rebuildContentViewForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;

@end

#pragma mark -

@implementation SPGroupedTabView

@synthesize dataSource;
@synthesize delegate;

@synthesize contentBackgroundColor;
@synthesize groupBackgroundColor;
@synthesize tabBackgroundColor;

@synthesize selectedGroupIndexes;
@synthesize selectedTabIndexes;

@synthesize contentViewController;
@synthesize contentView;

@synthesize preservesSelection;

@synthesize highlightGroupIcons;
@synthesize drawsContentBorder;
@synthesize groupMargin;

#pragma mark -

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		self.contentBackgroundColor = [NSColor colorWithCalibratedWhite:0.96 alpha:1.0];
		self.groupBackgroundColor = [NSColor colorWithCalibratedRed:41.0/255.0 green:68.0/255.0 blue:104.0/255.0 alpha:1.0];
		self.tabBackgroundColor = [NSColor colorWithCalibratedRed:78.0/255.0 green:116.0/255.0 blue:158.0/255.0 alpha:1.0];
		
		self.selectedGroupIndexes = [NSIndexSet indexSet];
		self.selectedTabIndexes = [NSIndexSet indexSet];
		
		self.preservesSelection = NO;
		
		self.highlightGroupIcons = NO;
		self.drawsContentBorder = YES;
		self.groupMargin = 0.0;
		
		_cachedGroupCells = [[NSMutableArray alloc] init];
		_cachedTabCells = [[NSMutableArray alloc] init];
		
		_cachedSelectionInfo = [[NSMutableDictionary alloc] init];
		
		_groupTrackingAreas = [[NSMutableArray alloc] init];
		_tabTrackingAreas = [[NSMutableArray alloc] init];
		_tabHovering = -1;
		
	}
    return self;
}

- (void) dealloc {
	self.dataSource = nil;
	self.delegate = nil;
	
	self.selectedGroupIndexes = nil;
	self.selectedTabIndexes = nil;
	
	self.contentBackgroundColor = nil;
	self.groupBackgroundColor = nil;
	self.tabBackgroundColor = nil;
	
	self.contentViewController = nil;
	self.contentView = nil;
	
	[_cachedGroupCells release], _cachedGroupCells = nil;
	[_cachedTabCells release], _cachedTabCells = nil;
	
	[_groupTrackingAreas release], _groupTrackingAreas = nil;
	[_tabTrackingAreas release], _tabTrackingAreas = nil;
	
	[_cachedSelectionInfo release], _cachedSelectionInfo = nil;
		
	[super dealloc];
}

#pragma mark -
#pragma mark Cell Factory

- (SPGroupedTabViewGroupCell*) _newGroupCell {
	
	SPGroupedTabViewGroupCell *aCell = [[SPGroupedTabViewGroupCell alloc] 
			initImageCell:[NSImage imageNamed:@"NSApplicationIcon"]];
	
	[aCell setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
	[aCell setImageScaling:NSImageScaleProportionallyDown];
	
	[aCell setTitle:NSLocalizedString(@"Untitled",@"")];
	[aCell setTextColor:[NSColor colorWithCalibratedWhite:0.7 alpha:1.0]];
	[aCell setFont:[NSFont systemFontOfSize:11.0]];
	
	[aCell setBordered:NO];
	[aCell setBezeled:NO];
	
	return aCell;
}

- (SPGroupedTabViewTabCell*) _newTabCell {
	
	SPGroupedTabViewTabCell *aCell = [[SPGroupedTabViewTabCell alloc] 
			initTextCell:NSLocalizedString(@"Untitled", @"")];
	
	[aCell setTitle:NSLocalizedString(@"Untitled", @"")];
	
	[aCell setTextColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
	[aCell setFont:[NSFont boldSystemFontOfSize:12.0]];
	[aCell setAlignment:NSLeftTextAlignment];
	
	[aCell setBordered:NO];
	[aCell setBezeled:NO];
	
	return aCell;
}

#pragma mark -
#pragma mark Data Management and Display

- (void) setSelectedGroupIndexes:(NSIndexSet *)inIndexSet {
	if ( ![selectedGroupIndexes isEqualToIndexSet:inIndexSet] ) {
		
		[self _cacheSelectionInfoForGroup:[selectedGroupIndexes firstIndex] tabSelection:self.selectedTabIndexes];
		
		if ( [self.delegate respondsToSelector:@selector(groupedTabView:willSelectGroup:)] )
			[self.delegate groupedTabView:self willSelectGroup:[inIndexSet firstIndex]];
				
		[selectedGroupIndexes release];
		selectedGroupIndexes = [inIndexSet copy];
		
		// Rebuild tab row whenever the group selection changes. I check the cell cache because
		// this indicates if content has been provided to the view by calling reloadData
		if ( [_cachedGroupCells count] > 0 ) [self _rebuildTabItemsForGroup:[inIndexSet firstIndex]];
		
		// Whenever the selected group is changed, I must also reset the selected tab
		// I want to force reselection, so I nil out the selected tab index beforehand
		
		[selectedTabIndexes release];
		selectedTabIndexes = nil;
		
		NSIndexSet *lastSelected = [self _lastSelectedIndexesForGroup:[inIndexSet firstIndex]];
		[self _setSelectedTabIndexesWithBindingsUpdatedCheckingWithDelegate:lastSelected];
		
		if ( [self.delegate respondsToSelector:@selector(groupedTabView:didSelectGroup:)] )
			[self.delegate groupedTabView:self didSelectGroup:[inIndexSet firstIndex]];

		[self setNeedsDisplay:YES];
	}
}

- (void) setSelectedTabIndexes:(NSIndexSet *)inIndexSet {
	if ( ![selectedTabIndexes isEqualToIndexSet:inIndexSet] ) {
		
		if ( [self.delegate respondsToSelector:@selector(groupedTabView:willSelectTab:group:)] )
			[self.delegate groupedTabView:self willSelectTab:[inIndexSet firstIndex] group:[self.selectedGroupIndexes firstIndex]];
		
		[selectedTabIndexes release];
		selectedTabIndexes = [inIndexSet copy];
		
		// As in the above method, I check the cell cache because this indicates if
		//  content has been provided to the view by calling reloadData
		if ( [_cachedTabCells count] > 0 ) [self _rebuildContentViewForTab:[inIndexSet firstIndex] group:[self.selectedGroupIndexes firstIndex]];
		
		if ( [self.delegate respondsToSelector:@selector(groupedTabView:didSelectTab:group:)] )
			[self.delegate groupedTabView:self didSelectTab:[inIndexSet firstIndex] group:[self.selectedGroupIndexes firstIndex]];
		
		[self setNeedsDisplay:YES];
	}
}

#pragma mark -

- (void) _rebuildGroupItems {
	
	[_cachedGroupCells removeAllObjects];
	
	NSInteger i;
	NSUInteger groupCount = [self.dataSource numberOfGroupsInGroupedTabView:self];
	for ( i = 0; i < groupCount; i++ ) {
		
		SPGroupedTabViewGroupCell *aGroupCell = [self _newGroupCell];
				
		if ( [self.dataSource respondsToSelector:@selector(groupedTabView:objectValueForGroup:)] ) {
			id objectValue = [self.dataSource groupedTabView:self objectValueForGroup:i];
			if ( objectValue ) {
				[aGroupCell setTitle:[objectValue valueForKey:@"title"]];
				[aGroupCell setImage:[objectValue valueForKey:@"image"]];
			}
		}
		
		// set a default text color for selected and unselected items
		// but the delegate can change these in the willDisplayCell method
		// this is explicitly not recommended, as this view manages those attributes
		
		[aGroupCell setTextColor:[NSColor colorWithCalibratedWhite:i==[self.selectedGroupIndexes firstIndex]?1.0:0.7 alpha:1.0]];
		[aGroupCell setState:( [self.selectedGroupIndexes firstIndex] == i ? NSOnState : NSOffState )];
		[aGroupCell setIconColor:( self.highlightGroupIcons ? ( [self.selectedGroupIndexes firstIndex] == i ? [NSColor whiteColor] : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] ) : nil )];
		
		if ( [self.delegate respondsToSelector:@selector(groupedTabView:willDisplayCell:forGroup:)] )
			[self.delegate groupedTabView:self willDisplayCell:aGroupCell forGroup:i];
		
		[_cachedGroupCells addObject:aGroupCell];
		[aGroupCell release];
	}
	
	[self updateTrackingAreas];
}

- (void) _rebuildTabItemsForGroup:(NSUInteger)groupIndex {
	
	if ( groupIndex == NSNotFound )
		return; // empty selection
	
	[_cachedTabCells removeAllObjects];
	
	if ( [self.selectedGroupIndexes count] != 0 ) {
		
		NSInteger i;
		NSUInteger tabCount = [self.dataSource numberOfTabsInGroupedTabView:self group:[self.selectedGroupIndexes firstIndex]];
		for ( i = 0; i < tabCount; i++ ) {
			
			SPGroupedTabViewTabCell *aTabCell = [self _newTabCell];
		
			if ( [self.dataSource respondsToSelector:@selector(groupedTabView:objectValueForTab:group:)] ) {
				id objectValue = [self.dataSource groupedTabView:self objectValueForTab:i group:[self.selectedGroupIndexes firstIndex]];
				if ( objectValue ) {
					[aTabCell setTitle:[objectValue valueForKey:@"title"]];
				}
			}
			
			// note the selected cell, hover and border color
			[aTabCell setState:( [self.selectedTabIndexes firstIndex] == i ? NSOnState : NSOffState )];
			[aTabCell setBorderColor:self.groupBackgroundColor];
			[aTabCell setMouseOver:(_tabHovering == i)];
			
			// the delegate method must be called prior to calculating cell size
			// as the delegate may change the cell attributes, eg set a title
			
			if ( [self.delegate respondsToSelector:@selector(groupedTabView:willDisplayCell:forTab:group:)] )
				[self.delegate groupedTabView:self willDisplayCell:aTabCell forTab:i group:[self.selectedGroupIndexes firstIndex]];
		
			[_cachedTabCells addObject:aTabCell];
			[aTabCell release];
		}
	}
	
	[self updateTrackingAreas];
}

- (void) _rebuildContentViewForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex {
	
	if ( tabIndex == NSNotFound || groupIndex == NSNotFound )
		return; // empty selection
	
	if ( [self.dataSource respondsToSelector:@selector(groupedTabView:viewForTab:group:)] ) {
		
		NSView *newContent = (NSView*)[self.dataSource groupedTabView:self 
				viewForTab:[self.selectedTabIndexes firstIndex] 
				group:[self.selectedGroupIndexes firstIndex]];
		
		//NSLog(@"%@",[newContent description]);
		
		if ( newContent != self.contentView ) {
			
			[newContent setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
			[newContent setFrame:[self contentViewFrame]];
			
			[self.contentView removeFromSuperview];
			[self addSubview:newContent];
			
			self.contentView = newContent;
		}
	}
	
	else if ( [self.dataSource respondsToSelector:@selector(groupedTabView:viewControllerForTab:group:)] ) {
		
		NSViewController *newController = (NSViewController*)[self.dataSource groupedTabView:self 
				viewControllerForTab:[self.selectedTabIndexes firstIndex] 
				group:[self.selectedGroupIndexes firstIndex]];
		
		//NSLog(@"%@",[newController description]);
		
		if ( newController != self.contentViewController ) {
			
			[[newController view] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
			[[newController view] setFrame:[self contentViewFrame]];
			
			[[self.contentViewController view] removeFromSuperview];
			[self addSubview:[newController view]];
			
			self.contentViewController = newController;
		}
	}
}

#pragma mark -

- (void) reloadData {
	[_cachedSelectionInfo removeAllObjects];
	
	[self _rebuildGroupItems];
	[self _rebuildTabItemsForGroup:[self.selectedGroupIndexes firstIndex]];
	[self _rebuildContentViewForTab:[self.selectedTabIndexes firstIndex] 
			group:[self.selectedGroupIndexes firstIndex]];
	
	[self setNeedsDisplay:YES];
}

- (void) reloadDataForGroup:(NSUInteger)groupIndex {
	
	if ( groupIndex == NSNotFound )
		return; // empty selection
	
	if ( ![self.selectedGroupIndexes containsIndex:groupIndex] )
		return; // cache is unavailable
	
	[self _rebuildTabItemsForGroup:groupIndex];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	
	NSUInteger i;
	
	// draw flat and gradient background colors
	
	if ( self.groupBackgroundColor != nil ) {
		
		NSBezierPath *groupHeader = [self _bezierPathForGroupHeader];
		[self.groupBackgroundColor set];
		[groupHeader fill];
		
		NSGradient *groupGradient = [[[NSGradient alloc] initWithStartingColor:self.groupBackgroundColor 
				endingColor:[self.groupBackgroundColor shadowWithLevel:kGroupGradientShadowLevel]] autorelease];
		
		[groupGradient drawInBezierPath:groupHeader angle:270.0];
	}
	
	if ( self.tabBackgroundColor != nil ) {
	
		NSBezierPath *tabHeader = [self _bezierPathForTabHeader];
		[self.tabBackgroundColor set];
		[tabHeader fill];
		
		NSGradient *tabGradient = [[[NSGradient alloc] initWithStartingColor:self.tabBackgroundColor 
				endingColor:[self.tabBackgroundColor shadowWithLevel:kTabGradientShadowLevel]] autorelease];
		
		[tabGradient drawInBezierPath:tabHeader angle:270.0];
	
	}
	
	if ( self.contentBackgroundColor != nil ) {
	
		NSBezierPath *content = [self _bezierPathForContent];
		[self.contentBackgroundColor set];
		[content fill];
	
	}
	
	// draw the group selection indicator
	
	if ( [self.selectedGroupIndexes count] != 0 ) {
		NSBezierPath *selectionPath = [self _bezierPathForGroupSelectionIndicator:[self.selectedGroupIndexes firstIndex] count:[_cachedGroupCells count]];
		[self.tabBackgroundColor set];
		[selectionPath fill];
	}
	
	// draw the content border
	
	if ( self.drawsContentBorder ) {
		NSBezierPath *border = [self _bezierPathForContentBorder];
		[[NSColor colorWithCalibratedWhite:kContentBorderWhiteAmount alpha:1.0] set];
		[border stroke];
	}
	
	// draw the group items
	
	for ( i = 0; i < [_cachedGroupCells count]; i++ ) {
		
		// set selection dependent information, which, however, overrides delegate changes to the cell textColor
		// the willDisplayGroup delegate method is called when the group items are rebuilt
		
		[[_cachedGroupCells objectAtIndex:i] setIconColor:( self.highlightGroupIcons ? ( [self.selectedGroupIndexes firstIndex] == i ? [NSColor whiteColor] : [NSColor colorWithCalibratedWhite:0.9 alpha:1.0] ) : nil )];
		[[_cachedGroupCells objectAtIndex:i] setTextColor:[NSColor colorWithCalibratedWhite:i==[self.selectedGroupIndexes firstIndex]?1.0:0.7 alpha:1.0]];
		[[_cachedGroupCells objectAtIndex:i] setState:( [self.selectedGroupIndexes firstIndex] == i ? NSOnState : NSOffState )];
	
		[[_cachedGroupCells objectAtIndex:i] drawWithFrame:[self _frameOfGroupCell:i count:[_cachedGroupCells count]] inView:self];
	}
	
	// draw the tab items
	
	if ( [self.selectedGroupIndexes count] != 0 ) {
		
		for ( i = 0; i < [_cachedTabCells count]; i++ ) {
		
			// likewise, the willDisplayTab delegate method is called when the tab items are rebuilt
		
			[[_cachedTabCells objectAtIndex:i] setState:( [self.selectedTabIndexes firstIndex] == i ? NSOnState : NSOffState )];
			[[_cachedTabCells objectAtIndex:i] setMouseOver:(_tabHovering == i)];
						
			[[_cachedTabCells objectAtIndex:i] drawWithFrame:[self _frameOfTabCell:i count:[_cachedTabCells count]] inView:self];
		}
	}
}

#pragma mark -

- (NSBezierPath*) _bezierPathForGroupSelectionIndicator:(NSUInteger)groupIndex count:(NSUInteger)groupCount {
	
	static CGFloat kIndicatorHeight = 11.0;
	
	NSRect bds = [self bounds];
	NSRect groupFrame = [self _frameOfGroupCell:groupIndex count:groupCount];
	NSPoint baseCenter = NSMakePoint( NSMidX(groupFrame), NSMaxY(bds)-kGroupHeaderHeight );
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	[path moveToPoint:NSMakePoint( baseCenter.x - kIndicatorHeight, baseCenter.y )];
	[path lineToPoint:NSMakePoint( baseCenter.x, baseCenter.y + kIndicatorHeight )];
	[path lineToPoint:NSMakePoint( baseCenter.x + kIndicatorHeight, baseCenter.y )];
	[path lineToPoint:NSMakePoint( baseCenter.x - kIndicatorHeight, baseCenter.y )];
	
	[path closePath];
	
	return path;
}

- (NSBezierPath*) _bezierPathForGroupHeader {
	
	static CGFloat kCornerRadius = 5.0;
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect bds = [self bounds];
	
	[path moveToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-kGroupHeaderHeight)];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-kCornerRadius)];
	
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(bds)+kCornerRadius,NSMaxY(bds)-kCornerRadius) 
			radius:kCornerRadius startAngle:180.0 endAngle:90.0 clockwise:YES];
	
	[path lineToPoint:NSMakePoint(NSMaxX(bds)-kCornerRadius, NSMaxY(bds))];
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(bds)-kCornerRadius,NSMaxY(bds)-kCornerRadius) 
			radius:kCornerRadius startAngle:90.0 endAngle:0.0 clockwise:YES];
	
	[path lineToPoint:NSMakePoint(NSMaxX(bds), NSMaxY(bds)-kGroupHeaderHeight)];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-kGroupHeaderHeight)];
	
	[path closePath];
	
	return path;
}

- (NSBezierPath*) _bezierPathForTabHeader {
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect bds = [self bounds];
	
	[path moveToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-kGroupHeaderHeight)];
	[path lineToPoint:NSMakePoint(NSMaxX(bds), NSMaxY(bds)-kGroupHeaderHeight)];
	[path lineToPoint:NSMakePoint(NSMaxX(bds), NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	
	[path closePath];
	
	return path;
}

- (NSBezierPath*) _bezierPathForContentBorder {
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect bds = [self bounds];
	
	[path moveToPoint:NSMakePoint(NSMinX(bds)+0.5, NSMinY(bds)+0.5)];
	[path lineToPoint:NSMakePoint(NSMinX(bds)+0.5, NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path moveToPoint:NSMakePoint(NSMaxX(bds)-0.5, NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path lineToPoint:NSMakePoint(NSMaxX(bds)-0.5, NSMinY(bds)+0.5)];
	[path lineToPoint:NSMakePoint(NSMinX(bds)+0.5, NSMinY(bds)+0.5)];
	
	[path setLineWidth:1.0];
	
	return path;
}

- (NSBezierPath*) _bezierPathForContent {
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect bds = [self bounds];
	
	[path moveToPoint:NSMakePoint(NSMinX(bds), NSMinY(bds))];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path lineToPoint:NSMakePoint(NSMaxX(bds), NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight))];
	[path lineToPoint:NSMakePoint(NSMaxX(bds), NSMinY(bds))];
	[path lineToPoint:NSMakePoint(NSMinX(bds), NSMinY(bds))];
	
	[path closePath];
	
	return path;
}

#pragma mark -

- (NSRect) _frameOfGroupCell:(NSUInteger)groupIndex count:(NSUInteger)numGroups {
	
	NSRect bds = [self bounds];
	CGFloat itemWidth = floor( ( NSWidth(bds) - (self.groupMargin*2) ) / numGroups );
	//CGFloat cellCenter = floor( itemWidth/2.0 + (groupIndex*itemWidth) );
	
	NSRect cellFrame = NSMakeRect( self.groupMargin + (groupIndex*itemWidth), 
									 floor(NSMaxY(bds) - kGroupHeaderHeight/2.0 - kGroupCellSize/2.0),
									 itemWidth, kGroupCellSize );
	return cellFrame;
}

- (NSRect) _frameOfTabCell:(NSUInteger)tabIndex count:(NSUInteger)numTabs {
	
	// must calculate the size for each one
	
	static CGFloat kLeftTabMargin = 20.0;
	
	CGFloat xPoint = kLeftTabMargin;
	NSRect bds = [self bounds];
	NSSize cellSize;
	NSInteger i;
	
	for ( i = 0; i < [_cachedTabCells count]; i++ ) {
	
		cellSize = [[_cachedTabCells objectAtIndex:i] cellSize];
		
		if ( i == tabIndex )
			break;
		
		xPoint += (cellSize.width+kTabCellSpacing);
	}
	
	NSRect cellFrame = NSMakeRect( xPoint, 
			floor(NSMaxY(bds)-(kGroupHeaderHeight+kTabHeaderHeight/2+cellSize.height/2)),
			cellSize.width, cellSize.height);
	
	return cellFrame;
}

- (NSRect) contentViewFrame {
	
	NSRect contentViewFrame = [self bounds];
	contentViewFrame.size.height -= (kGroupHeaderHeight+kTabHeaderHeight);
	
	// inset adjustment if we draw our own content border
	
	if ( self.drawsContentBorder ) {
		contentViewFrame.origin.x+=1;
		contentViewFrame.size.width-=2;
		
		contentViewFrame.origin.y+=1;
		contentViewFrame.size.height-=1;
	}
	
	return contentViewFrame;
}

#pragma mark -
#pragma mark Event Handling

- (void)mouseDown:(NSEvent *)theEvent {
	
	// mouse down can change the group selection or the tab selection
	// for tab selection, just check the tracking area rects
	
	NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger groupPressed = -1;
	NSInteger tabPressed = -1;
	
	for ( NSTrackingArea *tabArea in _tabTrackingAreas ) {
		if ( [self mouse:viewPoint inRect:[tabArea rect]] ) {
			
			// kill hovering on mouseDown -- only the item over which we're hovering can
			// be pressed and selected (=no longer hovering), and if we release outside it,
			// then (=no longer hovering) as well.
			
			_tabHovering = -1;
			
			// trackMouse hijacks the event loop, we won't return from it until the user
			// releases the mouse button
			
			SPGroupedTabViewTabCell *theTabCell = [_cachedTabCells objectAtIndex:[[[tabArea userInfo] valueForKey:@"tabIndex"] integerValue]];
			[theTabCell trackMouse:theEvent inRect:[tabArea rect] ofView:self untilMouseUp:YES];
			
			// NSCell trackMouse: needs to be called with the untilMouseUp flag set to YES
			// so that tracking continues even if the mouse moves outside the cell frame,
			// but then we cannot rely on the return value because it will be YES even if
			// the mouse is released outside the cell frame, so get the current mouse loc
			
			NSPoint windowPoint = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
			NSPoint currentPoint = [self convertPoint:windowPoint fromView:nil];
			
			if ( [self mouse:currentPoint inRect:[tabArea rect]] )
				tabPressed = [[[tabArea userInfo] valueForKey:@"tabIndex"] integerValue];
			
			break;
		}
	}
	
	if ( tabPressed != -1 ) {
		NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:tabPressed];
		if ( ![newSelection isEqualToIndexSet:self.selectedTabIndexes] )
			[self _setSelectedTabIndexesWithBindingsUpdatedCheckingWithDelegate:newSelection];
		return;
	}
	
	// If we've made it this far, no tab was pressed, and we want to check for group item
	// selections. Again, use the saved tracking rectangles
	
	for ( NSTrackingArea *groupArea in _groupTrackingAreas ) {
		if ( [self mouse:viewPoint inRect:[groupArea rect]] ) {
			
			SPGroupedTabViewGroupCell *theGroupCell = [_cachedGroupCells objectAtIndex:[[[groupArea userInfo] valueForKey:@"groupIndex"] integerValue]];
			[theGroupCell trackMouse:theEvent inRect:[groupArea rect] ofView:self untilMouseUp:YES];
			
			// same issue with NSCell trackMouse: method; check current mouse point for hit
			// I wonder how NSButton actually does it?
			
			NSPoint windowPoint = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
			NSPoint currentPoint = [self convertPoint:windowPoint fromView:nil];
			
			if ( [self mouse:currentPoint inRect:[groupArea rect]] )
				groupPressed = [[[groupArea userInfo] valueForKey:@"groupIndex"] integerValue];
			
			break;
		}
	}
	
	if ( groupPressed != -1 ) {
		NSIndexSet *newSelection = [NSIndexSet indexSetWithIndex:groupPressed];
		if ( ![newSelection isEqualToIndexSet:self.selectedGroupIndexes] )
			[self _setSelectedGroupIndexesWithBindingsUpdatedCheckingWithDelegate:newSelection];
		return;
	}
}

#pragma mark -

- (void)updateTrackingAreas {
	
	NSInteger i;
	
	[super updateTrackingAreas];
	
	for ( NSTrackingArea *defunctArea in _groupTrackingAreas ) {
		[self removeTrackingArea:defunctArea];
	}
	
	for ( NSTrackingArea *defunctArea in _tabTrackingAreas ) {
		[self removeTrackingArea:defunctArea];
	}
	
	[_groupTrackingAreas removeAllObjects];
	[_tabTrackingAreas removeAllObjects];
	
	// calculate the tracking areas for the tab items, using our already built cache
	// and refactored frame calcuation methods
	
	if ( [self.selectedGroupIndexes count] != 0 ) {
		
		for ( i = 0; i < [_cachedTabCells count]; i++ ) {
			
			NSRect cellFrame = [self _frameOfTabCell:i count:[_cachedTabCells count]];
			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					@"SPGroupedTabViewTabCell", @"cellIdentifier",
					[NSNumber numberWithInteger:i], @"tabIndex",
					nil];
			
			NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:cellFrame
					options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
					owner:self userInfo:userInfo];
			
			[self addTrackingArea:trackingArea];
			[_tabTrackingAreas addObject:trackingArea];
			
			[trackingArea release];
		}
	}
	
	// calculate group item tracking areas, based not on the cell size
	// but on the area within the cell actually used for drawing
	
	for ( i = 0; i < [_cachedGroupCells count]; i++ ) {
		
		// constrain tracking to the used rectangle
		NSRect availableFrame = [self _frameOfGroupCell:i count:[_cachedGroupCells count]];
		NSRect usedFrame = [[_cachedGroupCells objectAtIndex:i] drawingRectForBounds:availableFrame];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				@"SPGroupedTabViewGroupCell", @"cellIdentifier",
				[NSNumber numberWithInteger:i], @"groupIndex",
				nil];
		
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:usedFrame
				options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
				owner:self userInfo:userInfo];
		
		[self addTrackingArea:trackingArea];
		[_groupTrackingAreas addObject:trackingArea];
		
		[trackingArea release];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent {
	
	if ( [[theEvent trackingArea] userInfo] == nil )
		return;
	
	if ( [[[[theEvent trackingArea] userInfo] valueForKey:@"cellIdentifier"] isEqualToString:@"SPGroupedTabViewTabCell"] ) {
		_tabHovering = [[[[theEvent trackingArea] userInfo] valueForKey:@"tabIndex"] integerValue];
		[self setNeedsDisplay:YES]; // constrain rect?
	}
}

- (void)mouseExited:(NSEvent *)theEvent {
	
	if ( [[theEvent trackingArea] userInfo] == nil )
		return;
	
	if ( [[[[theEvent trackingArea] userInfo] valueForKey:@"cellIdentifier"] isEqualToString:@"SPGroupedTabViewTabCell"] ) {
		_tabHovering = -1;
		[self setNeedsDisplay:YES];
	}
}

#pragma mark -

- (void) _setSelectedGroupIndexesWithBindingsUpdatedCheckingWithDelegate:(NSIndexSet*)inIndexes {
	
	// callers should check if the selection is identical beforehand
	// if ( [inIndexes isEqualToIndexSet:self.selectedGroupIndexes] )
	//	return;
	
	if ( [self.delegate respondsToSelector:@selector(groupedTabView:shouldSelectGroup:)] ) {
		if ( [self.delegate groupedTabView:self shouldSelectGroup:[inIndexes firstIndex]] == NO )
			return;
	}
	
	// willSelect and didSelection delegate methods are called from
	// within the setter itself.
	
	self.selectedGroupIndexes = inIndexes; // also causes the selectedTabIndexes to update
	
	NSDictionary *info = [self infoForBinding:@"selectedGroupIndexes"];
	[[info objectForKey:NSObservedObjectKey] 
			setValue:self.selectedGroupIndexes 
			forKeyPath:[info objectForKey:NSObservedKeyPathKey]];
	
	[self setNeedsDisplay:YES];
}

- (void) _setSelectedTabIndexesWithBindingsUpdatedCheckingWithDelegate:(NSIndexSet*)inIndexes {
	
	// callers should check if the selection is identical beforehand
	// if ( [inIndexes isEqualToIndexSet:self.selectedTabIndexes] )
	//	return;
	
	if ( [self.delegate respondsToSelector:@selector(groupedTabView:shouldSelectTab:group:)] ) {
		if ( [self.delegate groupedTabView:self shouldSelectTab:[inIndexes firstIndex] 
			group:[self.selectedGroupIndexes firstIndex]] == NO )
			return;
	}
	
	// willSelect and didSelection delegate methods are called from
	// within the setter itself.
	
	self.selectedTabIndexes = inIndexes;
	
	NSDictionary *info = [self infoForBinding:@"selectedGroupIndexes"];
	[[info objectForKey:NSObservedObjectKey] 
			setValue:self.selectedTabIndexes 
			forKeyPath:[info objectForKey:NSObservedKeyPathKey]];
	
	[self setNeedsDisplay:YES];
}

#pragma mark -

- (NSIndexSet*) _lastSelectedIndexesForGroup:(NSUInteger)groupIndex {
	// This method should only be used from within the setSelectedGroupIndexes method
	// So that I can cache the previously selected index for a given group
	// and automatically reselect it when clicking back to that group.
	
	if ( groupIndex == NSNotFound ) // empty selection
		return [NSIndexSet indexSet];
	
	if ( self.preservesSelection ) {
		NSIndexSet *lastSelection = [_cachedSelectionInfo objectForKey:[NSNumber numberWithUnsignedInteger:groupIndex]];
		return ( lastSelection ? lastSelection : [NSIndexSet indexSetWithIndex:0] );
	}
	else {
		return [NSIndexSet indexSetWithIndex:0];
	}
}

- (void) _cacheSelectionInfoForGroup:(NSUInteger)groupIndex tabSelection:(NSIndexSet*)inIndexes {
	
	if ( groupIndex == NSNotFound )
		return; // empty selection
	
	[_cachedSelectionInfo setObject:inIndexes forKey:[NSNumber numberWithUnsignedInteger:groupIndex]];
}

@end

#pragma mark -

@interface SPGroupedTabViewGroupCell()

- (NSImage*) _highlightedImage:(NSImage*)inImage withColor:(NSColor*)inColor;

@end

#pragma mark -

@implementation SPGroupedTabViewGroupCell

@synthesize textColor;
@synthesize iconColor;

#pragma mark -

- (void) dealloc {
	self.textColor = nil;
	self.iconColor = nil;
	
	[super dealloc];
}

#pragma mark -

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	//[[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] set];
	//NSFrameRect([self drawingRectForBounds:cellFrame]);
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	if ( [self title] != nil ) {
		
		NSRect titleFrame = [self titleRectForBounds:cellFrame];
		NSString *title = [self title];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				[self textColor], NSForegroundColorAttributeName,
				[self font], NSFontAttributeName,
				nil];
		
		[title drawInRect:titleFrame withAttributes:attributes];
	}
	
	if ( [self image] != nil ) {
		
		NSRect imageFrame = [self imageRectForBounds:cellFrame];
		NSImage *theImage = [self _highlightedImage:[self image] withColor:self.iconColor];
		
		[self drawImage:theImage withFrame:imageFrame inView:controlView];
	}
}

#pragma mark -

- (NSImage*) _highlightedImage:(NSImage*)inImage withColor:(NSColor*)inColor {
	
	static CGFloat kGradientShadowLevel = 0.25;
	static CGFloat kGradientAngle = 270.0;
	
	if ( inColor ) {
		
		BOOL avoidGradient = ( [self state] == NSOnState );
		NSRect targetRect = NSMakeRect(0,0,[inImage size].width, [inImage size].height);
		
		NSImage *target = [[[NSImage alloc] initWithSize:[inImage size]] autorelease];
		NSGradient *gradient = ( avoidGradient ? nil : [[[NSGradient alloc] initWithStartingColor:self.iconColor 
				endingColor:[self.iconColor shadowWithLevel:kGradientShadowLevel]] autorelease] );
		
		[target lockFocus];
		if ( avoidGradient ) { [inColor set]; NSRectFill(targetRect); }
		else [gradient drawInRect:targetRect angle:kGradientAngle];
		[inImage drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeDestinationIn fraction:1.0];
		[target unlockFocus];
		
		return target;
	}
	else {
		return inImage;
	}
}

#pragma mark -

- (NSSize) cellSize {
	return [self cellSizeForBounds:NSMakeRect(0,0,10000,10000)];
}

- (NSSize) cellSizeForBounds:(NSRect)theRect {
	return [self drawingRectForBounds:theRect].size;
}

- (NSRect) drawingRectForBounds:(NSRect)theRect {
	
	return NSUnionRect([self titleRectForBounds:theRect], [self imageRectForBounds:theRect]);
}

- (NSRect) titleRectForBounds:(NSRect)theRect {
	
	// center the title at the lower end of the cell frame
	
	static CGFloat kTitleMargin = 4.0;
	
	NSString *title = [self title];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			[self textColor], NSForegroundColorAttributeName,
			[self font], NSFontAttributeName,
			nil];
	
	NSSize size = [title sizeWithAttributes:attributes];
	NSRect titleFrame = NSMakeRect( floor(NSMidX(theRect) - size.width/2.0),
									NSMinY(theRect) + kTitleMargin,
									size.width, size.height );

	return titleFrame;
}

- (NSRect) imageRectForBounds:(NSRect)theRect {
	
	// center the image above the title frame
	// which means I am calling this method twice during a draw iteration
	// this method returns a square frame
	
	static CGFloat kImageMargin = 2.0;
	
	NSRect titleFrame = [self titleRectForBounds:theRect];
	CGFloat imageBottom = NSMaxY(titleFrame) + kImageMargin;
	CGFloat availableHeight = NSMaxY(theRect) - imageBottom;
	
	NSRect imageFrame = NSMakeRect( floor( NSMidX(theRect) - availableHeight/2.0 ),
									imageBottom,
									availableHeight, availableHeight );
	
	return imageFrame;
}

@end

#pragma mark -

#define kTabCellHorMargin 8.0
#define kTabCellVerMargin 2.0

#pragma mark -

@interface SPGroupedTabViewTabCell()

- (NSBezierPath*) _bezierPathForTabSelectionIndicator:(NSRect)cellFrame;

@end

#pragma mark -

@implementation SPGroupedTabViewTabCell

@synthesize textColor;
@synthesize borderColor;
@synthesize mouseOver = _mouseOver;

#pragma mark -

- (void) dealloc {
	self.textColor = nil;
	self.borderColor = nil;
	
	[super dealloc];
}

#pragma mark -

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
		
	//[[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] set];
	//NSFrameRect(cellFrame);
	
	if ( [self isHighlighted] ) {
		NSBezierPath *selectionPath = [self _bezierPathForTabSelectionIndicator:cellFrame];
		[[self.borderColor shadowWithLevel:kGroupGradientShadowLevel*4.0/3.0] set];
		[selectionPath fill];
	}
	else if ( [self state] == NSOnState ) {
		NSBezierPath *selectionPath = [self _bezierPathForTabSelectionIndicator:cellFrame];
		[[self.borderColor shadowWithLevel:kGroupGradientShadowLevel*2.0/3.0] set];
		[selectionPath fill];
	}
	else if ( self.mouseOver ) {
		NSBezierPath *selectionPath = [self _bezierPathForTabSelectionIndicator:cellFrame];
		[self.borderColor set];
		[selectionPath fill];
	}
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	if ( [self title] != nil ) {
		
		NSRect titleFrame = [self titleRectForBounds:cellFrame];
		NSString *title = [self title];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
				[self textColor], NSForegroundColorAttributeName,
				[self font], NSFontAttributeName,
				nil];
		
		[title drawInRect:titleFrame withAttributes:attributes];
	}
}

- (NSBezierPath*) _bezierPathForTabSelectionIndicator:(NSRect)cellFrame {
	
	static CGFloat kCornerRadius = 12.0;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame 
			xRadius:kCornerRadius yRadius:kCornerRadius];
		
	return path;
}

#pragma mark -

- (NSSize)cellSize {
	
	NSSize cellSize = [super cellSize];
	cellSize.height += (kTabCellVerMargin*2);
	cellSize.width += (kTabCellHorMargin*2);
	
	return cellSize;
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
	
	NSRect titleRect = [super titleRectForBounds:theRect];
	titleRect.origin.x += kTabCellHorMargin;
	titleRect.origin.y -= kTabCellVerMargin;
	
	return titleRect;
}

#pragma mark -

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView 
		untilMouseUp:(BOOL)untilMouseUp {
	
	// I keep track of the cell frame to check the mouse location during tracking
	// curious that the cell frame isn't passed to the following methods.
	// The following methods hijack the otherwise unused isHighlighted to track
	// whether the mouse is down inside the cell frame
	
	_trackingFrame = cellFrame;
	
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
	
	[self setHighlighted:[controlView mouse:startPoint inRect:_trackingFrame]];
	[controlView setNeedsDisplayInRect:_trackingFrame];
	
	[super startTrackingAt:startPoint inView:controlView];
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
	
	[self setHighlighted:[controlView mouse:currentPoint inRect:_trackingFrame]];
	[controlView setNeedsDisplayInRect:_trackingFrame];
	
	[super continueTracking:lastPoint at:currentPoint inView:controlView];
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
	
	[self setHighlighted:NO];
	//[self setState:( flag && [controlView mouse:stopPoint inRect:_trackingFrame] ? NSOnState : NSOffState )];
	[controlView setNeedsDisplayInRect:_trackingFrame];
	
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}

@end
