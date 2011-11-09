//
//  TwoTieredTabViewAppDelegate.h
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

// Images for example purposes only and are copyright their respective copyright holders.

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "SPGroupedTabView.h"

@interface TwoTieredTabViewAppDelegate : NSObject <NSApplicationDelegate,SPGroupedTabViewDataSource,SPGroupedTabViewDelegate> {
   
	// outlets
	NSWindow *window;
	NSPanel *panel;
	SPGroupedTabView *groupedTabView;
	
	NSMatrix *groupMatrix;
	NSMatrix *tabMatrix;
	
	// content views
	NSImageView *statesView;
	NSTextField *citiesView;
	WebView *nationsView;
	NSTextView *planetsView;
	
	NSMutableArray *viewControllers;
	
	// iVars
	NSArray *dataModel;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *panel;
@property (assign) IBOutlet SPGroupedTabView *groupedTabView;

@property (assign) IBOutlet NSMatrix *groupMatrix;
@property (assign) IBOutlet NSMatrix *tabMatrix;

@property (assign) IBOutlet NSImageView *statesView;
@property (assign) IBOutlet NSTextField *citiesView;
@property (assign) IBOutlet WebView *nationsView;
@property (assign) IBOutlet NSTextView *planetsView;

- (IBAction) showPanel:(id)sender;
- (IBAction) setSelectedGroup:(id)sender;
- (IBAction) setSelectedTab:(id)sender;

@end
