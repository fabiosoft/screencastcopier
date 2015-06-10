//
//  ViewController.h
//  ScreencastCopier
//
//  Created by Fabio Nisci on 08/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "DDHotKeyCenter.h"
#import "DDHotKeyUtilities.h"
#import "DDHotKeyTextField.h"
#import "DragDropView.h"


@interface ViewController : NSViewController <DragDropViewDelegate>{
	NSPasteboard *pasteboard;
	IBOutlet DragDropView *dropview;
	IBOutlet NSTextField *statusLabel;
	IBOutlet NSTextField *nextBufferedLabel;
}

@property (assign) NSInteger currentBufferPosition; // < 0 no buffer available
@property (strong) NSMutableArray *bufferToPaste;
@property (strong) IBOutlet NSTextField *textField;
@property (strong) IBOutlet NSButton *terminalWindowCheck;
@property (strong) IBOutlet NSButton *globalHotKeyCheck;


- (IBAction)checkHotKeyEnabled:(CGKeyCode)sender;
- (IBAction)browseForFile:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

@end

