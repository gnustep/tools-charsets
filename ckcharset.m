/* ckcharset.m: A utility to print the names of characters in a character set.
   Copyright (C) 2001 Free Software Foundation, Inc.

   Written by:  Jonathan Gapen  <jagapen@home.com>
   Date: March 2001

   This file is part of GNUstep.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>
#include <stdio.h>
#import "GSUnicodeData.h"
#import "GSUniChar.h"

int main(int argc, char *argv[])
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  NSArray *args;
  GSUnicodeData *ud;
  GSUniChar *ucdEntry;
  NSCharacterSet *charSet;
  unichar ch;

  args = [processInfo arguments];
  if ([args count] != 2)
    {
      NSLog(@"Usage: %@ [NSCharacterSet.bitmap]", [args objectAtIndex: 0]);
      [arp release];
      exit(0);
    }

  ud = [GSUnicodeData unicodeData];
  if (ud == nil)
    {
      NSLog(@"ERROR: Unable to get Unicode data object.");
      [arp release];
      exit(0);
    }

  charSet = [NSCharacterSet characterSetWithContentsOfFile: [args objectAtIndex: 1]];
  for (ch = 0; ch < 0xffff; ch++)
    {
      if ([charSet characterIsMember: ch])
        {
          GSUniChar *ucdEntry = [ud entryForCharacter: ch];
          printf("%s\n", [[ucdEntry name] cString]);
        }
    }

  [arp release];
  return 0;
}
