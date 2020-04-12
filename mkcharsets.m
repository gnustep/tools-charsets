/* mkcharsets.m: A utility to create bitmaps for the standard character sets.
   Copyright (C) 2001,2006 Free Software Foundation, Inc.

   Written by:  Jonathan Gapen  <jagapen@home.com>
   Date: March 2001
   Update by: Richard Frith-Macdonald <rfm@gnu.org>

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
#import <libgnustep-ucsdata/GSUnicodeData.h>
#import <libgnustep-ucsdata/GSUniChar.h>

@implementation	NSCharacterSet (String)
- (NSString*) stringRepresentation
{
  NSMutableString	*m = [NSMutableString stringWithCapacity: 128];
  unichar		c;

  for (c = 0; c < 128; c++)
    {
      if ([self characterIsMember: c])
	{
	  NSString	*s;

	  s = [[NSString alloc] initWithCharacters: &c length: 1];
	  [m appendString: s];
	  RELEASE(s);
	}
    }
  return m;
}
@end

int main(int argc, char *argv[])
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  GSUnicodeData *ud;
  NSEnumerator *enumerator;
  GSUniChar *ucdEntry;
  NSMutableCharacterSet *alnumSet, *controlSet, *dDigitSet, *decompSet;
  NSMutableCharacterSet *illegalSet, *letterSet, *lCaseSet, *nonBaseSet;
  NSMutableCharacterSet *puncSet, *symbolSet, *tCaseSet, *uCaseSet;
  NSMutableCharacterSet *whiteSet, *newlineSet;
  NSCharacterSet *u;
  NSString *decompMap;
  NSData *bitmap;
 
  /* First we can generate well known charactersets which use only ascii
   * and don't require unicode data.
   */
  u = [NSCharacterSet characterSetWithCharactersInString: @"i!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLFragmentAllowedCharSet.dat" atomically: NO];
 
  u = [NSCharacterSet characterSetWithCharactersInString: @"!$&'()*+,-.0123456789:;=ABCDEFGHIJKLMNOPQRSTUVWXYZ[]_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLHostAllowedCharSet.dat" atomically: NO];
 
  u = [NSCharacterSet characterSetWithCharactersInString: @"!$&'()*+,-.0123456789;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLPasswordAllowedCharSet.dat" atomically: NO];
 
  u = [NSCharacterSet characterSetWithCharactersInString: @"!$&'()*+,-./0123456789:=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLPathAllowedCharSet.dat" atomically: NO];
 
  u = [NSCharacterSet characterSetWithCharactersInString: @"!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLQueryAllowedCharSet.dat" atomically: NO];
 
  u = [NSCharacterSet characterSetWithCharactersInString: @"!$&'()*+,-.0123456789;=ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"];
  bitmap = [u bitmapRepresentation];
  [bitmap writeToFile: @"URLUserAllowedCharSet.dat" atomically: NO];
 
  ud = [GSUnicodeData dataWithContentsOfFile: @"UnicodeData.txt"];
  if (ud == nil)
    {
      ud = [GSUnicodeData unicodeData];
    }
  if (ud == nil)
    {
      NSLog(@"Error getting Unicode database object.");
      [arp release];
      exit(0);
    }

  alnumSet = [NSMutableCharacterSet new];
  controlSet = [NSMutableCharacterSet new];
  dDigitSet = [NSMutableCharacterSet new];
  decompSet = [NSMutableCharacterSet new];
  illegalSet = [NSMutableCharacterSet new];
  [illegalSet invert];
  letterSet = [NSMutableCharacterSet new];
  lCaseSet = [NSMutableCharacterSet new];
  nonBaseSet = [NSMutableCharacterSet new];
  puncSet = [NSMutableCharacterSet new];
  symbolSet = [NSMutableCharacterSet new];
  uCaseSet = [NSMutableCharacterSet new];
  tCaseSet = [NSMutableCharacterSet new];
  whiteSet = [NSMutableCharacterSet new];
  newlineSet = [NSMutableCharacterSet new];

  enumerator = [ud objectEnumerator];
  while ((ucdEntry = [enumerator nextObject]))
    {
      NSRange range = [ucdEntry range];
      UCDGeneralCategory category = [ucdEntry generalCategory];

      /* If it's an assigned character, remove it from the illegal set.
       */
      if (category != UCDNotAssignedCategory)
        {
          [illegalSet removeCharactersInRange: range];
	}

      switch (category)
        {
          case UCDLetterUppercaseCategory:
            [uCaseSet addCharactersInRange: range];
            break;
          case UCDLetterLowercaseCategory:
            [lCaseSet addCharactersInRange: range];
            break;
          case UCDLetterTitlecaseCategory:
            [tCaseSet addCharactersInRange: range];
            break;
          case UCDLetterModifierCategory:
          case UCDMarkNonSpacingCategory:
          case UCDMarkSpacingCombiningCategory:
          case UCDMarkEnclosingCategory:
            [nonBaseSet addCharactersInRange: range];
            break;
          case UCDNumberLetterCategory:
          case UCDNumberOtherCategory:
            [letterSet addCharactersInRange: range];
            break;
          case UCDSeparatorSpaceCategory:
          case UCDSeparatorLineCategory:
          case UCDSeparatorParagraphCategory:
            [whiteSet addCharactersInRange: range];
            break;
          case UCDControlCategory:
          case UCDFormatCategory:
            [controlSet addCharactersInRange: range];
            break;
          case UCDNumberDecimalDigitCategory:
            [dDigitSet addCharactersInRange: range];
            break;
          case UCDLetterOtherCategory:
            [letterSet addCharactersInRange: range];
            break;
          case UCDPunctuationConnectorCategory:
          case UCDPunctuationDashCategory:
          case UCDPunctuationOpenCategory:
          case UCDPunctuationCloseCategory:
          case UCDPunctuationInitialQuoteCategory:
          case UCDPunctuationFinalQuoteCategory:
          case UCDPunctuationOtherCategory:
            [puncSet addCharactersInRange: range];
            break;
          case UCDSymbolMathCategory:
          case UCDSymbolCurrencyCategory:
          case UCDSymbolModifierCategory:
          case UCDSymbolOtherCategory:
            [symbolSet addCharactersInRange: range];
            break;
	  case UCDSurrogateCategory:
	  case UCDPrivateUseCategory:
	  case UCDNotAssignedCategory:
	    break;
        }

      decompMap = [ucdEntry decompositionMapping];
      if ([decompMap isEqualToString: @""] == NO)
        [decompSet addCharactersInRange: range];
    }

  [letterSet formUnionWithCharacterSet: lCaseSet];
  [letterSet formUnionWithCharacterSet: uCaseSet];
  [letterSet formUnionWithCharacterSet: tCaseSet];
  [letterSet formUnionWithCharacterSet: nonBaseSet];

  [alnumSet formUnionWithCharacterSet: letterSet];
  [alnumSet formUnionWithCharacterSet: dDigitSet];

  bitmap = [alnumSet bitmapRepresentation];
  [bitmap writeToFile: @"alphanumericCharSet.dat" atomically: NO];

  bitmap = [controlSet bitmapRepresentation];
  [bitmap writeToFile: @"controlCharSet.dat" atomically: NO];

  bitmap = [dDigitSet bitmapRepresentation];
  [bitmap writeToFile: @"decimalDigitCharSet.dat" atomically: NO];

  bitmap = [decompSet bitmapRepresentation];
  [bitmap writeToFile: @"decomposableCharSet.dat" atomically: NO];

  bitmap = [illegalSet bitmapRepresentation];
  [bitmap writeToFile: @"illegalCharSet.dat" atomically: NO];

  bitmap = [letterSet bitmapRepresentation];
  [bitmap writeToFile: @"letterCharSet.dat" atomically: NO];

  bitmap = [lCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"lowercaseLetterCharSet.dat" atomically: NO];

  bitmap = [nonBaseSet bitmapRepresentation];
  [bitmap writeToFile: @"nonBaseCharSet.dat" atomically: NO];

  bitmap = [puncSet bitmapRepresentation];
  [bitmap writeToFile: @"punctuationCharSet.dat" atomically: NO];

  bitmap = [symbolSet bitmapRepresentation];
  [bitmap writeToFile: @"symbolAndOperatorCharSet.dat" atomically: NO];

  bitmap = [uCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"uppercaseLetterCharSet.dat" atomically: NO];

  bitmap = [tCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"titlecaseLetterCharSet.dat" atomically: NO];

  // Unicode calls tab a control character; we call it whitespace
  [whiteSet addCharactersInRange: NSMakeRange(0x09, 1)];
  // Unicode calls zero-width-space a control character; we call it whitespace
  [whiteSet addCharactersInRange: NSMakeRange(0x200B, 1)];

  bitmap = [whiteSet bitmapRepresentation];
  [bitmap writeToFile: @"whitespaceCharSet.dat" atomically: NO];

  // Add lines breaks: CR, VT, FF and LF
  [newlineSet addCharactersInRange: NSMakeRange(0x0A, 4)];
  // Also nextline
  [newlineSet addCharactersInRange: NSMakeRange(0x85, 1)];

  bitmap = [newlineSet bitmapRepresentation];
  [bitmap writeToFile: @"newlineCharSet.dat" atomically: NO];

  [whiteSet formUnionWithCharacterSet: newlineSet];

  bitmap = [whiteSet bitmapRepresentation];
  [bitmap writeToFile: @"whitespaceAndNlCharSet.dat" atomically: NO];

  [arp release];
  return 0;
}
