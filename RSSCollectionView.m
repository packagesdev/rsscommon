/*
 Copyright (c) 2015, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RSSCollectionView.h"

NSString * const RSSCollectionViewSelectionDidChangeNotification=@"RSSCollectionViewSelectionDidChangeNotification";

@implementation RSSCollectionView

- (void)RSS_selectItemAtIndex:(NSUInteger)inIndex
{
	[super setSelectionIndexes:[NSIndexSet indexSetWithIndex:inIndex]];
	
	// Make sure the item is visible
	
	NSRect tFrame=[self frameForItemAtIndex:inIndex];
	
	[self scrollRectToVisible:tFrame];
}

- (void)setSelectionIndexes:(NSIndexSet *)inIndexSet
{
    if ([[self delegate] respondsToSelector:@selector(RSS_selectionShouldChangeInCollectionView:)]==YES)
    {
        BOOL tSelectionShouldChange=[(id<RSSCollectionViewDelegate>) [self delegate] RSS_selectionShouldChangeInCollectionView:self];
        
        if (tSelectionShouldChange==NO)
            return;
    }
    
    __block NSMutableIndexSet * tMutableIndexSet=[NSMutableIndexSet indexSet];
        
	[inIndexSet enumerateIndexesUsingBlock:^(NSUInteger bIndex, BOOL * bOutStop){
	
		if ([[self delegate] respondsToSelector:@selector(RSS_collectionView:shouldSelectItemAtIndex:)]==YES)
		{
			if ([(id<RSSCollectionViewDelegate>) [self delegate] RSS_collectionView:self shouldSelectItemAtIndex:bIndex]==YES)
				[tMutableIndexSet addIndex:bIndex];
		}
	}];
	
	inIndexSet=[tMutableIndexSet copy];
	
	if ([inIndexSet count]==0)
		return;
    
    [super setSelectionIndexes:inIndexSet];
    
    if ([[self delegate] respondsToSelector:@selector(RSS_collectionViewSelectionDidChange:)]==YES)
    {
        NSNotification * tNotification=[NSNotification notificationWithName:RSSCollectionViewSelectionDidChangeNotification
																	 object:self];
        
        [(id<RSSCollectionViewDelegate>) [self delegate] RSS_collectionViewSelectionDidChange:tNotification];
    }
}

- (void)mouseDown:(NSEvent *)inEvent
{
    NSPoint tPoint = [self convertPoint:inEvent.locationInWindow fromView:nil];
    
    for(NSView * tView in [self subviews])
    {
        if (NSPointInRect(tPoint, tView.frame)==YES)
        {
            [super mouseDown:inEvent];
            
            return;
        }
    }
}

@end
