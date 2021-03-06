//
//  ViewController.m
//  ScreencastCopier
//
//  Created by Fabio Nisci on 08/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	_bufferToPaste = [NSMutableArray array];
	_currentBufferPosition = -1; //no buffer available
	pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
	[nextBufferedLabel setStringValue:@"Drag and drop code file here"];

	[self checkHotKeyEnabled:kVK_ANSI_V];
	
	dropview = [[DragDropView alloc]initWithFrame:CGRectMake(20, 20, 440, 205) withAllowedFileTypes:@[@"txt",@"c",@"mm"]];
//	dropview = [[DragDropView alloc]init];
//	NSArray *allowedTypes = @[@"txt",@"c",@"mm"];
//	[dropview setAllowedFiletypes:[allowedTypes mutableCopy]];
	[dropview setDelegate:self];
	[self.view addSubview:dropview];
}

- (IBAction)checkHotKeyEnabled:(CGKeyCode)keycode{
	if(_globalHotKeyCheck.state == TRUE){
		//register for cmd+v
		[self registerHotKey:kVK_ANSI_V];
	}else{
		//unregister hotkey
		[[DDHotKeyCenter sharedHotKeyCenter]unregisterAllHotKeys];
	}
}

//register global hotkey is pressed
-(DDHotKey *)registerHotKey:(CGKeyCode)keyCode{
	return [[DDHotKeyCenter sharedHotKeyCenter] registerHotKeyWithKeyCode:keyCode modifierFlags:NSCommandKeyMask task:^(NSEvent *event) {
		//step forward in the buffer
		_currentBufferPosition++;
		if(_currentBufferPosition < _bufferToPaste.count){
			//play ok pasted sound
			NSString *currentLine = (NSString *)_bufferToPaste[_currentBufferPosition];
			if(_terminalWindowCheck.state == FALSE){
				currentLine = [currentLine stringByAppendingString:[NSString stringWithFormat:@"%c",NSNewlineCharacter]];
			}
			
			//next line
			NSString *nextBuffer = @"";
			@try {nextBuffer = (NSString *)_bufferToPaste[_currentBufferPosition+1];}
			@catch (NSException *exception) {nextBuffer = @"---";}
			@finally {[nextBufferedLabel setStringValue:nextBuffer];}
			//
			
			[pasteboard setString:currentLine forType:NSPasteboardTypeString];
		}else{
			//play done sound
			_currentBufferPosition = -1;
			[pasteboard setString:@"" forType:NSPasteboardTypeString];
			[_bufferToPaste removeAllObjects];
		}
		//even the buffer is empty
		//invoke cmd+v for real
		//so if you copy something else after the buffered text you can use the OS clipboard as usual
		[self keyPress:keyCode includingCommandKey:YES];
	}];
}

//cmd-v for real
-(void)keyPress:(CGKeyCode)keycode includingCommandKey:(BOOL)includeCommandkey{
	//context
	CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
	//key down
	CGEventRef keyCommandDown = CGEventCreateKeyboardEvent(source, keycode, YES);
	if(includeCommandkey){
		//include "cmd" key
		CGEventSetFlags(keyCommandDown, kCGEventFlagMaskCommand);
	}
	//key up
	CGEventRef keyCommandUp = CGEventCreateKeyboardEvent(source, keycode, NO);
	
	//push and release key
	CGEventPost(kCGAnnotatedSessionEventTap, keyCommandDown);
	CGEventPost(kCGAnnotatedSessionEventTap, keyCommandUp);
	
	//free up
	CFRelease(keyCommandUp);
	CFRelease(keyCommandDown);
	CFRelease(source);
}

//user dragged a file on the drop zone
-(void)dragOperationisOver:(DragDropView *)dropView{
//	NSLog(@"Dragged files");
//	for (NSString *filename in dropView.draggedFilenames) {
//		NSLog(@"%@",filename);
//	}
	NSURL *textFileURL = [NSURL URLWithString:[dropView.draggedFilenames.firstObject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[self bufferizeTheFile:textFileURL];
	
}


//choose file from system dialog
- (IBAction)browseForFile:(id)sender {
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
 
	openPanel.title = @"Choose a code file";
	openPanel.showsResizeIndicator = YES;
	openPanel.showsHiddenFiles = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canCreateDirectories = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = [[dropview allowedFiletypes]copy];
 
	if ([openPanel runModal] == NSModalResponseOK) {
		NSURL *textFileURL = [[openPanel URLs]firstObject];
		//TODO: verify before bufferize if it's a code file
		[self bufferizeTheFile:textFileURL];
	}
	
}

//prepare the text file to be bufferized each line to clipboard
-(void)bufferizeTheFile:(NSURL *)textFileURL{
	NSString* filepath = [textFileURL.path stringByResolvingSymlinksInPath];
	[statusLabel setStringValue:[NSString stringWithFormat:@"Loaded: %@", filepath]];
	
	NSError *error = nil;
	NSString *words = [[NSString alloc] initWithContentsOfFile:filepath
													  encoding:NSUTF8StringEncoding error:&error];
	_bufferToPaste = [[words componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]mutableCopy];
	if(_bufferToPaste.count > 0){
		//first line
		[nextBufferedLabel setStringValue:_bufferToPaste.firstObject];
	}
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	
	// Update the view, if already loaded.
}

//utility (non used) methods
- (IBAction)copy:(id)sender {
	
	BOOL success = [pasteboard setString:_textField.stringValue forType:NSPasteboardTypeString];
	if(success){
		NSLog(@"copied = %@", _textField.stringValue);
	}else{
		NSLog(@"not successfully copied");
	}
}

- (IBAction)paste:(id)sender {
	NSLog(@"pasted: %@",[pasteboard stringForType:NSPasteboardTypeString]);
}

@end
