//
//  SPGroupedTabView.h
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

#import <Cocoa/Cocoa.h>

@protocol SPGroupedTabViewDataSource;
@protocol SPGroupedTabViewDelegate;

@class SPGroupedTabViewGroupCell;
@class SPGroupedTabViewTabCell;

@interface SPGroupedTabView : NSView {
	
	id<SPGroupedTabViewDataSource> dataSource;
	id<SPGroupedTabViewDelegate> delegate;
	
	NSIndexSet *selectedGroupIndexes;
	NSIndexSet *selectedTabIndexes;
	
	NSColor *contentBackgroundColor;
	NSColor *groupBackgroundColor;
	NSColor *tabBackgroundColor;
	
	BOOL preservesSelection;
	BOOL highlightGroupIcons;
	BOOL drawsContentBorder;
	CGFloat groupMargin;
	
	NSViewController *contentViewController;
	NSView *contentView;
	
	@private
	NSMutableArray *_cachedGroupCells;
	NSMutableArray *_cachedTabCells;
	
	NSMutableDictionary *_cachedSelectionInfo;
	
	NSMutableArray *_groupTrackingAreas;
	NSMutableArray *_tabTrackingAreas;
	NSInteger _tabHovering;
}

@property(readwrite,assign) id<SPGroupedTabViewDataSource> dataSource;
@property(readwrite,assign) id<SPGroupedTabViewDelegate> delegate;

@property(readwrite,copy) NSColor *contentBackgroundColor;
@property(readwrite,copy) NSColor *groupBackgroundColor;
@property(readwrite,copy) NSColor *tabBackgroundColor;
	
	// You may set a nil background color for any of these properties to avoid
	// drawing a background for that section. This is not recommended
	// except in the case of the contentBackgroundColor

@property(readwrite) BOOL highlightGroupIcons;

	// If highlightGroupIcons is YES, the view highlights the icon using a slight 
	// gradient, similar to iPhone's tab view. You might use this option if you 
	// are providing image masks. This value is NO by default. You should set 
	// this value prior to loading data into the view.

@property(readwrite,copy) NSIndexSet *selectedGroupIndexes;
@property(readwrite,copy) NSIndexSet *selectedTabIndexes;

	// Multiple group and tab selection is not supported and likely never will be; it 
	// does not make sense given the context. But you may want to bind these
	// values to an array controller, and some bindings support for group and
	// tab content, rather than the data source pattern, is planned.
	
	// Empty group and tab selection is also not supported. Once data is loaded into
	// the view, the code internally assumes that one and only one group and one
	// and only one tab are always selected. If you set an empty selection for
	// either the group or the tab the view will exhibit unspecified behavior.

@property(readonly,retain) NSViewController *contentViewController;
@property(readonly,retain) NSView *contentView;

@property(readwrite) BOOL preservesSelection;

	// By default this value is NO and the view resets the tab selection to the 
	// first item whenever a different group is selected. When this value is YES
	// the view will try to restore the last selected tab for each group. 

@property(readwrite) BOOL drawsContentBorder;
@property(readwrite) CGFloat groupMargin;

#pragma mark -

- (void) reloadData;
	
	// Call this method when you are ready to populate the tab view from your
	// data source. It rebuilds the group content. Tab content is rebuilt as
	// the selected group changes. It is recommended you call this method 
	// before setting the group and tab selection indexes.

- (void) reloadDataForGroup:(NSUInteger)groupIndex;

	// Call this method to rebuild the visible tabs for the given group index.
	// Because tabs are always reconstructed when the group selection changes,
	// and their contents are otherwise not cached, this method has no effect
	// unless groupIndex is one of the selectedGroupIndexes.

- (NSRect) contentViewFrame;
	
	// Returns the space available for the content view, or the view that is 
	// associated with a selected group and tab. Normally you implement the 
	// viewForTab or viewControllerForTab delegate method to return a view
	// and everything else is handled internally.

@end

#pragma mark -

@protocol SPGroupedTabViewDataSource <NSObject>

@required
- (NSUInteger) numberOfGroupsInGroupedTabView:(SPGroupedTabView*)aTabView;
- (NSUInteger) numberOfTabsInGroupedTabView:(SPGroupedTabView*)aTabView group:(NSUInteger)groupIndex;
	
	// It is currently assumed that the data source will return a count of at least 1
	// for the number of groups and for the number of tabs in a given group

@optional
- (id) groupedTabView:(SPGroupedTabView*)aTabView objectValueForGroup:(NSUInteger)groupIndex;
- (id) groupedTabView:(SPGroupedTabView*)aTabView objectValueForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
	
	// It is not necessary to implement either of these methods. However, if you do, you 
	// must return an object that is key-value coding compliant for the keys "title" and 
	// "image" if it is a group and the key "title" if it is a tab. Refer to the 
	// addtional protocols below to see what methods your objects must implement.
	
	// If you provide an object value for the group and tabs then you do not need to
	// implement the willDisplay delegate methods below. 

- (id) groupedTabView:(SPGroupedTabView*)aTabView viewForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
- (id) groupedTabView:(SPGroupedTabView*)aTabView viewControllerForTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
	
	// Your data source should implement one of these methods to provide views as the 
	// group and tab selection changes. The view is automatically resized to fit the
	// available content frame and is set to resize horizontally and vertically.

@end

#pragma mark -

@protocol SPGroupedTabViewDelegate <NSObject>

@optional
- (void) groupedTabView:(SPGroupedTabView*)aTabView willDisplayCell:(id)aCell forGroup:(NSUInteger)groupIndex;
- (void) groupedTabView:(SPGroupedTabView*)aTabView willDisplayCell:(id)aCell forTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
	
	// Implement to customize the cell's appearance prior to display. Two custom cell classes
	// are used to display the group and tab items, once cell for every item to display them
	// and for mouse tracking. See cell classes below for methods you may call on them.
	// You will generally be setting an image and title for the group cell and a title 
	// for the tab cell.

- (BOOL) groupedTabView:(SPGroupedTabView*)aTabView shouldSelectGroup:(NSUInteger)groupIndex;
- (void) groupedTabView:(SPGroupedTabView*)aTabView willSelectGroup:(NSUInteger)groupIndex;
- (void) groupedTabView:(SPGroupedTabView*)aTabView didSelectGroup:(NSUInteger)groupIndex;

- (BOOL) groupedTabView:(SPGroupedTabView*)aTabView shouldSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
- (void) groupedTabView:(SPGroupedTabView*)aTabView willSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;
- (void) groupedTabView:(SPGroupedTabView*)aTabView didSelectTab:(NSUInteger)tabIndex group:(NSUInteger)groupIndex;

	// You may use the shouldSelect methods to deny selection changes that are accomplished
	// internally, eg in response to user events. These shouldSelect methods are not called
	// if you change the selection programmatically.

@end

#pragma mark -

	// The following two protocols declare the methods which SPGroupedTabView uses to 
	// access the contents of a group or tab data object as returned by the
	// objectValueForGroup and objectValueForTab data source methods.

@protocol SPGroupedTabViewGroupItem <NSObject>

@optional
@property(readonly) NSString *title;
@property(readonly) NSImage *image;

@end

#pragma mark -

@protocol SPGroupedTabViewTabItem <NSObject>

@optional
@property(readonly) NSString *title;

@end

#pragma mark -

// For the most part the following cell classes should be considered private.
// They are used internally by SPGroupedTabView to display the group and tab
// items and for mouse tracking. Custom attributes such as textColor, iconColor 
// and borderColor are managed by the grouped tab view. Currently there is no 
// support for changing these values from the delegate.

// The cells are passed to the willDisplay delegate methods, and you may modify
// supported attributes there. At the least, you should set the cell's title in 
// this delegate method as well as the image if it is a group cell.

@interface SPGroupedTabViewGroupCell : NSButtonCell {
	
	// title, font handled by NSCell
	
	NSColor *textColor;
	NSColor *iconColor;
}

@property(readonly,copy) NSColor *textColor;
@property(readonly,copy) NSColor *iconColor;

@end

#pragma mark -

@interface SPGroupedTabViewTabCell : NSButtonCell {
	
	// title, font handled by NSCell
	
	NSColor *textColor;
	NSColor *borderColor;
	
	NSRect _trackingFrame;
	BOOL _mouseOver;
}

@property(readonly,copy) NSColor *borderColor;
@property(readonly,copy) NSColor *textColor;

@property(readonly) BOOL mouseOver;

@end
