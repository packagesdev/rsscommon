/*
 Copyright (c) 2015, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RSSCollectionViewItem.h"
#import "RSSCollectionViewItemLabel.h"

NSString * const RSSCollectionViewRepresentedObjectThumbnail=@"thumbnail";
NSString * const RSSCollectionViewRepresentedObjectName=@"name";
NSString * const RSSCollectionViewRepresentedObjectTag=@"tag";

@interface RSSCollectionViewItem ()
{
	IBOutlet NSImageView * _thumbnailImageView;
	IBOutlet RSSCollectionViewItemLabel * _nameLabelView;
}

@property (nonatomic,readwrite) NSString * thumbnail;
@property (nonatomic,readwrite) NSString * name;

@property (readwrite) NSInteger tag;

@end

@implementation RSSCollectionViewItem

- (void)awakeFromNib
{
	[self setThumbnail:_thumbnail];
	
	[self setName:_name];
	
	[self setSelected:[self isSelected]];
}

#pragma mark -

- (void)setThumbnail:(NSString *)inThumbnail
{
	_thumbnail=inThumbnail;
	
	if (_thumbnail!=nil)
		[_thumbnailImageView setImage:[[NSBundle bundleForClass:[self class]] imageForResource:_thumbnail]];
	else
		[_thumbnailImageView setImage:nil];
}

- (void)setName:(NSString *)inName
{
	_name=inName;
	
	if (_name!=nil)
		[_nameLabelView setStringValue:_name];
	else
		[_nameLabelView setStringValue:@""];
}

- (void)setSelected:(BOOL)inSelected
{
	[super setSelected:inSelected];
	
	[_nameLabelView setSelected:inSelected];
}

#pragma mark -

- (void)setRepresentedObject:(id)inRepresentedObject
{
	[super setRepresentedObject:inRepresentedObject];
	
	if ([inRepresentedObject isKindOfClass:[NSDictionary class]]==YES)
	{
		NSDictionary * tDictionary=(NSDictionary *)inRepresentedObject;
		
		self.thumbnail=tDictionary[RSSCollectionViewRepresentedObjectThumbnail];
		
		self.name=tDictionary[RSSCollectionViewRepresentedObjectName];
		
		NSNumber * tNumber=tDictionary[RSSCollectionViewRepresentedObjectTag];
		
		if (tNumber!=nil)
			self.tag=[tNumber integerValue];
	}
}

@end
