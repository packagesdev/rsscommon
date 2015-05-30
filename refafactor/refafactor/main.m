/*
 Copyright (c) 2015, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

#import "RSSRefafactor.h"

#include <getopt.h>

#define BUNDLE_OPT				"bundle"
#define PREFIX_OPT				"prefix"
#define HELP_OPT				"help"

void usage(void)
{
	(void)fprintf(stderr, "%s\n","Usage: refafactor [ <option> ] --bundle path --prefix prefix\n\n"
				  "\t<options> are any of:\n"
				  "\t--help                 print full usage\n");
}

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		char * tCBundlePath=NULL;
		char * tCPrefix=NULL;
		BOOL tShowUsage=NO;
		
		static const struct option long_options[]=
		{
			{BUNDLE_OPT, required_argument,NULL,0},
			{PREFIX_OPT	, required_argument,NULL,0},
			{HELP_OPT	, no_argument,NULL,0},
			{NULL, 0, NULL, 0} /* End of array need by getopt_long do not delete it*/
		};
		
		while (1)
		{
			int c;
			int option_index = 0;
			const char * tShortOptions="";
			
			c = getopt_long_only(argc, (char * const *) argv, tShortOptions,long_options, &option_index);
			
			if (c== EOF)
				break;

			if (c==0)
			{
				const char * tOptionName;
				
				tOptionName=long_options[option_index].name;
				
				if (strncmp(BUNDLE_OPT,tOptionName,strlen(BUNDLE_OPT))==0)
					tCBundlePath=strdup(optarg);
				else if (strncmp(PREFIX_OPT,tOptionName,strlen(PREFIX_OPT))==0)
					tCPrefix=strdup(optarg);
				else if (strncmp(HELP_OPT,tOptionName,strlen(HELP_OPT))==0)
					tShowUsage=YES;
			}
		}
		
		if (tCBundlePath==NULL || tCPrefix==NULL || tShowUsage==YES)
		{
			usage();
			
			free(tCPrefix);
			free(tCBundlePath);
			
			return 0;
		}
		
		RSSRefafactor * tRefafactor=[[RSSRefafactor alloc] init];
		
		tRefafactor.bundle=[NSBundle bundleWithPath:[[NSFileManager defaultManager] stringWithFileSystemRepresentation:tCBundlePath length:strlen(tCBundlePath)]];
		
		if (tRefafactor.bundle==nil)
		{
			(void)fprintf(stderr, "No bundle at path %s\n",tCBundlePath);
			
			return -1;
		}
		
		tRefafactor.prefix=[NSString stringWithUTF8String:tCPrefix];
		
		if ([tRefafactor run]==NO)
			return -1;
	}
	
    return 0;
}
