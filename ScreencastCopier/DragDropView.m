//
//  DragDropView.m
//  ScreencastCopier
//
//  Created by Fabio Nisci on 09/06/15.
//  Copyright (c) 2015 Fabio Nisci. All rights reserved.
//


#import "DragDropView.h"

@implementation DragDropView


- (id)initWithFrame:(NSRect)frame withAllowedFileTypes:(NSArray *)fileTypes{
	self = [super initWithFrame:frame];
	if (self) {
		_draggedFilenames = [NSMutableArray array];
		_allowedFiletypes = [NSMutableArray arrayWithArray:fileTypes];
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frame{
	return [self initWithFrame:frame withAllowedFileTypes:@[@"txt"]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
	highlight=YES;
	[self setNeedsDisplay: YES];
	
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSColorPboardType] ) {
		if (sourceDragMask & NSDragOperationGeneric) {
			return NSDragOperationGeneric;
		}
	}
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		if (sourceDragMask & NSDragOperationLink) {
			return NSDragOperationLink;
		} else if (sourceDragMask & NSDragOperationCopy) {
			return NSDragOperationCopy;
		}
	}
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
	highlight=NO;
	[self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
	highlight=NO;
	[self setNeedsDisplay: YES];
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
	NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	NSString *draggedExtension = [[draggedFilenames objectAtIndex:0] pathExtension];

	return [_allowedFiletypes containsObject:draggedExtension];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
	[_draggedFilenames removeAllObjects];
	_draggedFilenames = [[[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType]mutableCopy];
	
//	NSLog(@"Dragged files");
//	for (NSString *filename in _draggedFilenames) {
//		NSLog(@"%@",filename);
//	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(dragOperationisOver:)]) {
		[self.delegate dragOperationisOver:self];
	}

	
	//NSString *textDataFile = [NSString stringWithContentsOfFile:[_draggedFilenames objectAtIndex:0] encoding:NSUTF8StringEncoding error:nil];
	//NSLog(@"%@", textDataFile);
}

- (void)drawRect:(NSRect)rect{
	[super drawRect:rect];
	if ( highlight ) {
		[[NSColor grayColor] set];
		[NSBezierPath setDefaultLineWidth: 5];
		[NSBezierPath strokeRect: [self bounds]];
	}
}


/*
- (BOOL)performDragOperation:(id )sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		// Perform operation using the list of files
		NSLog(@"Dragged files");
		int i;
		for (i = 0; i < [files count]; i++) {
			
			NSLog(@"%@",[files objectAtIndex:i]);
		}
	}
	return YES;
}
 */

@end
