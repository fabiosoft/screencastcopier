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


	[self checkHotKeyEnabled:kVK_ANSI_V];
	
	DragDropView *dropview = [[DragDropView alloc]initWithFrame:CGRectMake(20, 75, 420, 112)];
	[dropview setDelegate:self];
	[self.view addSubview:dropview];
}

- (IBAction)checkHotKeyEnabled:(CGKeyCode)keycode{
	if(_globalHotKeyCheck.state == TRUE){
		//register for cmd+v
		NSLog(@"reg");
		[self registerHotKey:kVK_ANSI_V];
	}else{
		//unregister hotkey
		NSLog(@"unreg");
		[[DDHotKeyCenter sharedHotKeyCenter]unregisterAllHotKeys];
	}
}

//register global hotkey
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
			[pasteboard setString:currentLine forType:NSPasteboardTypeString];
			//invoke cmd+v for real
			[self keyPress:keyCode includingCommandKey:YES];
		}else{
			//play done sound
			_currentBufferPosition = -1;
			[_bufferToPaste removeAllObjects];
		}
	}];
}

//cmd-v for real
-(void)keyPress:(CGKeyCode)keycode includingCommandKey:(BOOL) includeCommandkey{
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

-(void)dragOperationisOver:(DragDropView *)dropView{
//	NSLog(@"Dragged files");
//	for (NSString *filename in dropView.draggedFilenames) {
//		NSLog(@"%@",filename);
//	}
	NSURL *textFileURL = [NSURL URLWithString:dropView.draggedFilenames[0]];
	[self bufferizeTheFile:textFileURL];
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];
	
	// Update the view, if already loaded.
}

- (IBAction)browseForFile:(id)sender {
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
 
	openPanel.title = @"Choose a .TXT file";
	openPanel.showsResizeIndicator = YES;
	openPanel.showsHiddenFiles = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canCreateDirectories = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = @[@"txt"];
 
	if ([openPanel runModal] == NSModalResponseOK) {
		NSURL *textFileURL = [[openPanel URLs] objectAtIndex:0];
		[self bufferizeTheFile:textFileURL];
	}
	
}

-(void)bufferizeTheFile:(NSURL *)textFileURL{
	NSString* filepath = [textFileURL.path stringByResolvingSymlinksInPath];
	
	NSError *error = nil;
	NSString *words = [[NSString alloc] initWithContentsOfFile:filepath
													  encoding:NSUTF8StringEncoding error:&error];
	_bufferToPaste = [[words componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]mutableCopy];
	//NSLog(@"%@",_bufferToPaste);
}


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
