/*
 Copyright (c) 2015, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RSSRefafactor.h"

@interface RSSRefafactor ()
{
	NSArray * _refactorableClasses;
	NSArray * _renamableFiles;
}

- (BOOL)refactorBinary;
- (BOOL)refactorResources;

- (id)refactoredObject:(id)inObject;
- (BOOL)refactorNibAtPath:(NSString *)inPath;
- (BOOL)renameFileNamed:(NSString *) inFileName inDirectory:(NSString *)inDirectoryPath;

@end

@implementation RSSRefafactor

- (id)init
{
	self=[super init];
	
	if (self!=nil)
	{
		_refactorableClasses=@[@"RSSAboutBoxWindowController",
							   @"RSSConfigurationWindowController",
							   @"RSSLightGrayBackgroundView",
							   @"RSSSecondaryBox",
							   @"RSSSettings",
							   @"RSSWindow"];
		
		_renamableFiles=@[@"RSSAboutBoxWindowController.nib"];
	}
	
	return self;
}

#pragma mark -

- (id)refactoredObject:(id)inObject
{
	if (inObject!=nil)
	{
		if ([inObject isKindOfClass:[NSMutableArray class]]==YES)
		{
			NSMutableArray * tMutableArray=(NSMutableArray *)inObject;
			NSMutableArray * tRefactoredArray=[NSMutableArray array];
			
			[tMutableArray enumerateObjectsUsingBlock:^(id bObject,NSUInteger bIndex,BOOL *bOutStop){
				
				if ([bObject isKindOfClass:[NSString class]]==YES)
				{
					NSString * tString=(NSString *)bObject;
					BOOL tFound=NO;
					
					for(NSString * tClassName in _refactorableClasses)
					{
						if ([tClassName isEqualToString:tString]==YES)
						{
							NSString * tReplacementClassName=[self.prefix stringByAppendingString:[tClassName substringFromIndex:[self.prefix length]]];
							
							tFound=YES;
							
							[tRefactoredArray addObject:tReplacementClassName];
							
							break;
						}
					}
					
					if (tFound==NO)
						[tRefactoredArray addObject:tString];
				}
				else
				{
					[tRefactoredArray addObject:[self refactoredObject:bObject]];
				}
			}];
			
			return tRefactoredArray;
		}
		else if ([inObject isKindOfClass:[NSMutableDictionary class]]==YES)
		{
			NSMutableDictionary * tMutableDictionary=(NSMutableDictionary *)inObject;
			NSMutableDictionary * tRefactoredDictionary=[NSMutableDictionary dictionary];
			
			[tMutableDictionary enumerateKeysAndObjectsUsingBlock:^(id bKey,id bObject,BOOL *bOutStop){
			
				if ([bObject isKindOfClass:[NSString class]]==YES)
				{
					NSString * tString=(NSString *)bObject;
					BOOL tFound=NO;
					
					for(NSString * tClassName in _refactorableClasses)
					{
						if ([tClassName isEqualToString:tString]==YES)
						{
							NSString * tReplacementClassName=[self.prefix stringByAppendingString:[tClassName substringFromIndex:[self.prefix length]]];
							
							tFound=YES;
							
							[tRefactoredDictionary setObject:tReplacementClassName forKey:bKey];
							
							break;
						}
					}
					
					if (tFound==NO)
						[tRefactoredDictionary setObject:bObject forKey:bKey];
				}
				else
				{
					[tRefactoredDictionary setObject:[self refactoredObject:bObject] forKey:bKey];
				}
			}];
			
			return tRefactoredDictionary;
		}
	}
	
	return inObject;
}

- (BOOL)refactorNibAtPath:(NSString *)inPath
{
	if (inPath!=nil)
	{
		NSData * tData=[NSData dataWithContentsOfFile:inPath];
		
		if (tData==nil)
		{
			return NO;
		}
		
		NSPropertyListFormat tFormat;
		NSError * tError;
		
		id tObject=[NSPropertyListSerialization propertyListWithData:tData
															 options:NSPropertyListMutableContainersAndLeaves
															  format:&tFormat
															   error:&tError];
		
		if (tObject==nil)
		{
			return NO;
		}
		
		id tRefactoreObject=[self refactoredObject:tObject];
		
		tData=[NSPropertyListSerialization dataWithPropertyList:tRefactoreObject
														 format:tFormat
														options:0
														  error:&tError];
		
		if (tData==nil)
		{
			return NO;
		}
		
		if ([tData writeToFile:inPath options:NSDataWritingAtomic error:&tError]==NO)
		{
			NSLog(@"Error when writing refactored nib at path: %@",inPath);
			
			return NO;
		}
		
		return YES;
	}
	
	return NO;
}

- (BOOL)renameFileNamed:(NSString *) inFileName inDirectory:(NSString *)inDirectoryPath
{
	NSString * tNewName=[self.prefix stringByAppendingString:[inFileName substringFromIndex:[self.prefix length]]];
	NSError * tError;
	
	if ([[NSFileManager defaultManager] moveItemAtPath:[inDirectoryPath stringByAppendingPathComponent:inFileName]
											toPath:[inDirectoryPath stringByAppendingPathComponent:tNewName]
											 error:&tError]==NO)
	{
		// A COMPLETER
		
		return NO;
	}
	
	return YES;
}

#pragma mark -

- (BOOL)refactorBinary
{
	NSString * tExecutablePath=[self.bundle executablePath];
	
	if (tExecutablePath!=nil)
	{
		NSUInteger tNumberOfChanges=0;
		NSError * tError;
		NSMutableData * tMutableData=[NSMutableData dataWithContentsOfFile:tExecutablePath
																   options:NSDataReadingMappedIfSafe error:&tError];
		
		if (tMutableData!=nil)
		{
			
			
			NSData * tPrefixData=[self.prefix dataUsingEncoding:NSASCIIStringEncoding];
			
			for(NSString * tClassName in _refactorableClasses)
			{
				NSRange tSearchRange=NSMakeRange(0, [tMutableData length]);
				
				NSData * tClassData=[tClassName dataUsingEncoding:NSASCIIStringEncoding];
				
				NSRange tFoundRange;
				
				do
				{
					tFoundRange=[tMutableData rangeOfData:tClassData options:0 range:tSearchRange];
					
					if (tFoundRange.location!=NSNotFound)
					{
						tNumberOfChanges++;
						
						[tMutableData replaceBytesInRange:NSMakeRange(tFoundRange.location,[tPrefixData length])
												withBytes:[tPrefixData bytes]
												   length:[tPrefixData length]];
						
						tSearchRange.location=tFoundRange.location;
						tSearchRange.length=[tMutableData length]-tSearchRange.location;
					}
				
				}
				while (tFoundRange.location!=NSNotFound);
			}
		}
		
		// Replace executable if needed
		
		if (tNumberOfChanges==0)
			return YES;
		
		if ([tMutableData writeToFile:tExecutablePath options:NSDataWritingAtomic error:&tError]==YES)
			return YES;
		
		NSLog(@"%@",[tError localizedDescription]);
	}
	else
	{
		// A COMPLETER
	}
	
	return NO;
}

- (BOOL)refactorResources
{
	NSString * tResourcesPath=[self.bundle resourcePath];
	
	NSArray * tArray=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:tResourcesPath error:nil];
	
	if (tArray!=nil)
	{
		for(NSString * tItem in tArray)
		{
			NSString * tExtension=[tItem pathExtension];
			
			if ([tExtension caseInsensitiveCompare:@"lproj"]==NSOrderedSame)
			{
				NSString * tLocalizedResourcesFolder=[tResourcesPath stringByAppendingPathComponent:tItem];
				
				NSArray * tLocalizedResourcesArray=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:tLocalizedResourcesFolder error:nil];
				
				for(NSString * tLocalizedItem in tLocalizedResourcesArray)
				{
					tExtension=[tLocalizedItem pathExtension];
					
					if ([tExtension caseInsensitiveCompare:@"nib"]==NSOrderedSame)
					{
						[self refactorNibAtPath:[tLocalizedResourcesFolder stringByAppendingPathComponent:tLocalizedItem]];
					}
					
					for(NSString * tFileName in _renamableFiles)
					{
						if ([tLocalizedItem caseInsensitiveCompare:tFileName]==NSOrderedSame)
						{
							if ([self renameFileNamed:tLocalizedItem inDirectory:tLocalizedResourcesFolder]==NO)
								return NO;
						}
					}
				}
			}
			else if ([tExtension caseInsensitiveCompare:@"nib"]==NSOrderedSame)
			{
				[self refactorNibAtPath:[tResourcesPath stringByAppendingPathComponent:tItem]];
				
				for(NSString * tFileName in _renamableFiles)
				{
					if ([tItem caseInsensitiveCompare:tFileName]==NSOrderedSame)
					{
						if ([self renameFileNamed:tItem inDirectory:tResourcesPath]==NO)
							return NO;
					}
				}
			}
		}
	}
	else
	{
		// A COMPLETER
	}
	
	return NO;
}

#pragma mark -

- (BOOL)run
{
	if ([self refactorBinary]==YES)
		return [self refactorResources];
	
	return NO;
}

@end
